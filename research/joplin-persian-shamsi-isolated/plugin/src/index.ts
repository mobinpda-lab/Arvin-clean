import joplin from 'api';
import { ContentScriptType } from 'api/types';

joplin.plugins.register({
  onStart: async function() {
    const rendererId = 'joplin-persian-shamsi-markdown';
    await joplin.contentScripts.register(
      ContentScriptType.MarkdownItPlugin,
      rendererId,
      './markdownItPlugin.js',
    );

    const editorId = 'joplin-persian-shamsi-editor';
    await joplin.contentScripts.register(
      ContentScriptType.CodeMirrorPlugin,
      editorId,
      './editorPlugin.js',
    );

    console.info('[Joplin Persian Shamsi] renderer and editor registered');
  },
});
