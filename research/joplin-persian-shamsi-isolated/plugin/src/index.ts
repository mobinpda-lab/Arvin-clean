import joplin from 'api';
import { ContentScriptType } from 'api/types';

const SETTING_STRING_TYPE = 2;
const EDITOR_TOOLBAR_LOCATION = 'editorToolbar';

import {
  DEFAULT_EDITOR_FONT,
  EDITOR_FONT_COMMAND,
  EDITOR_FONT_SETTING,
} from './editorFont';

joplin.plugins.register({
  onStart: async function() {
    await joplin.settings.registerSection('joplinPersianShamsi', {
      label: 'Joplin Persian Shamsi',
      iconName: 'fas fa-font',
    });

    await joplin.settings.registerSetting(EDITOR_FONT_SETTING, {
      value: DEFAULT_EDITOR_FONT,
      type: SETTING_STRING_TYPE,
      section: 'joplinPersianShamsi',
      isEnum: true,
      public: true,
      label: 'Editor font',
      description: 'Font used by the Markdown editor. VazirHarf is bundled with this plugin.',
      options: {
        [DEFAULT_EDITOR_FONT]: 'Joplin default',
        vazirharf: 'VazirHarf',
      },
    });

    await joplin.contentScripts.register(
      ContentScriptType.MarkdownItPlugin,
      'joplin-persian-shamsi-markdown',
      './markdownItPlugin.js',
    );

    await joplin.contentScripts.register(
      ContentScriptType.CodeMirrorPlugin,
      'joplin-persian-shamsi-editor',
      './editorPlugin.js',
    );

    await joplin.commands.register({
      name: EDITOR_FONT_COMMAND,
      label: 'Set Joplin editor font',
      execute: async (font: string = DEFAULT_EDITOR_FONT) => {
        await joplin.commands.execute('editor.execCommand', {
          name: EDITOR_FONT_COMMAND,
          args: [font],
        });
      },
    });

    await joplin.views.toolbarButtons.create(
      'joplinPersianShamsiFont',
      EDITOR_FONT_COMMAND,
      EDITOR_TOOLBAR_LOCATION,
    );

    await joplin.settings.onChange(async (event) => {
      if (event.keys?.includes(EDITOR_FONT_SETTING)) {
        const font = await joplin.settings.value(EDITOR_FONT_SETTING);
        await joplin.commands.execute('editor.execCommand', {
          name: EDITOR_FONT_COMMAND,
          args: [font],
        });
      }
    });

    console.info('[Joplin Persian Shamsi] renderer, editor and font control registered');
  },
});
