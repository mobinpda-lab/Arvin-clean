const path = require('path');
const crypto = require('crypto');
const fs = require('fs-extra');
const chalk = require('chalk');
const CopyPlugin = require('copy-webpack-plugin');
const tar = require('tar');
const glob = require('glob');
const execSync = require('child_process').execSync;

const rootDir = path.resolve(__dirname);
const userConfigFilename = './plugin.config.json';
const userConfigPath = path.resolve(rootDir, userConfigFilename);
const distDir = path.resolve(rootDir, 'dist');
const srcDir = path.resolve(rootDir, 'src');
const publishDir = path.resolve(rootDir, 'publish');
const userConfig = { extraScripts: [], ...(fs.pathExistsSync(userConfigPath) ? require(userConfigFilename) : {}) };
const manifestPath = path.resolve(srcDir, 'manifest.json');
const packageJsonPath = path.resolve(rootDir, 'package.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const pluginArchiveFilePath = path.resolve(publishDir, `${manifest.id}.jpl`);
const pluginInfoFilePath = path.resolve(publishDir, `${manifest.id}.json`);

function fileSha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}
function currentGitInfo() {
  try {
    const branch = execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
    const commit = execSync('git rev-parse HEAD').toString().trim();
    return `${branch}:${commit}`;
  } catch (_) {
    return '';
  }
}
function createPluginArchive(sourceDir, destPath) {
  const distFiles = glob.sync(`${sourceDir}/**/*`, { nodir: true, windowsPathsNoEscape: true })
    .map(f => f.substr(sourceDir.length + 1));
  if (!distFiles.length) throw new Error('dist is empty');
  fs.removeSync(destPath);
  tar.create({ strict: true, portable: true, file: destPath, cwd: sourceDir, sync: true }, distFiles);
}
function onBuildCompleted() {
  fs.removeSync(path.resolve(publishDir, 'index.js'));
  createPluginArchive(distDir, pluginArchiveFilePath);
  const info = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  info._publish_hash = `sha256:${fileSha256(pluginArchiveFilePath)}`;
  info._publish_commit = currentGitInfo();
  fs.writeFileSync(pluginInfoFilePath, JSON.stringify(info, null, 2));
}
const baseConfig = {
  mode: 'production',
  target: 'node',
  stats: 'errors-only',
  module: { rules: [{ test: /\.tsx?$/, use: 'ts-loader', exclude: /node_modules/ }] },
  resolve: {
    alias: { api: path.resolve(__dirname, 'api') },
    extensions: ['.js', '.tsx', '.ts', '.json'],
  },
};
const pluginConfig = {
  ...baseConfig,
  entry: './src/index.ts',
  output: { filename: 'index.js', path: distDir },
  plugins: [new CopyPlugin({
    patterns: [
      {
        from: '**/*',
        context: srcDir,
        to: distDir,
        globOptions: { ignore: ['**/*.ts', '**/*.tsx'] },
      },
      {
        from: 'node_modules/vazirharf/fonts/ttf/Vazirharf[wght].ttf',
        to: 'fonts/Vazirharf[wght].ttf',
      },
    ],
  })],
};
const createArchiveConfig = {
  stats: 'errors-only',
  entry: './dist/index.js',
  output: { filename: 'index.js', path: publishDir },
  plugins: [{ apply(compiler) { compiler.hooks.done.tap('archiveOnBuildListener', onBuildCompleted); } }],
};
function resolveExtraScriptPath(name) {
  const relativePath = `./src/${name}`;
  const fullPath = path.resolve(rootDir, relativePath);
  if (!fs.pathExistsSync(fullPath)) throw new Error(`Missing extra script: ${name}`);
  const parts = name.split('.');
  parts.pop();
  return {
    entry: relativePath,
    output: { filename: `${parts.join('.')}.js`, path: distDir, library: 'default', libraryTarget: 'commonjs', libraryExport: 'default' },
  };
}
function buildExtraScriptConfigs() {
  return userConfig.extraScripts.map(name => {
    const p = resolveExtraScriptPath(name);
    return { ...baseConfig, entry: p.entry, output: p.output };
  });
}
function increaseVersion(version) {
  const parts = version.split('.');
  parts[parts.length - 1] = String(Number(parts[parts.length - 1]) + 1);
  return parts.join('.');
}
function updateVersion() {
  const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  pkg.version = increaseVersion(pkg.version);
  manifest.version = increaseVersion(manifest.version);
  fs.writeFileSync(packageJsonPath, JSON.stringify(pkg, null, 2) + '\n');
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
}
module.exports = env => {
  const name = env['joplin-plugin-config'];
  if (name === 'updateVersion') { updateVersion(); return []; }
  if (name === 'buildMain') {
    fs.removeSync(distDir); fs.removeSync(publishDir); fs.mkdirpSync(publishDir);
    return [pluginConfig];
  }
  if (name === 'buildExtraScripts') return buildExtraScriptConfigs();
  if (name === 'createArchive') return [createArchiveConfig];
  throw new Error('Unknown joplin-plugin-config: ' + name);
};
