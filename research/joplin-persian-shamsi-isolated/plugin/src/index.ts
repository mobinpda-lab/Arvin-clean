import joplin from 'api';
import { ContentScriptType, SettingItemType, ToolbarButtonLocation } from 'api/types';

export const EDITOR_FONT_SETTING = 'editorFontFamily';
export const EDITOR_FONT_COMMAND = 'joplin-persian-shamsi-set-editor-font';
export const VAZIRHARF_FONT = '"VazirHarf", Tahoma, sans-serif';
export const DEFAULT_EDITOR_FONT = 'default';

joplin.plugins.register({
  onStart: async function() {
    await joplin.settings.registerSection('joplinPersianShamsi', {
      label: 'Joplin Persian Shamsi',
      iconName: 'fas fa-font',
    });

    await joplin.settings.registerSetting(EDITOR_FONT_SETTING, {
      value: DEFAULT_EDITOR_FONT,
      type: SettingItemType.String,
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
      ToolbarButtonLocation.EditorToolbar,
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
