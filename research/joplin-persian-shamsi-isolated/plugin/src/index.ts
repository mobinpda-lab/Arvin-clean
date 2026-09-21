import joplin from 'api';
import { ContentScriptType } from 'api/types';

joplin.plugins.register({
  onStart: async function() {
    const contentScriptId = 'joplin-persian-shamsi-markdown';
    await joplin.contentScripts.register(
      ContentScriptType.MarkdownItPlugin,
      contentScriptId,
      './markdownItPlugin.js',
    );
    console.info('[Joplin Persian Shamsi] isolated renderer registered');
  },
});
