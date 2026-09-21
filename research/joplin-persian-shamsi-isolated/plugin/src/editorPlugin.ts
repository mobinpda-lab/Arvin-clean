import joplin from 'api';

import {
  DEFAULT_EDITOR_FONT,
  EDITOR_FONT_COMMAND,
  EDITOR_FONT_SETTING,
  VAZIRHARF_FONT,
} from './editorFont';

function applyFont(editorView: any, font: string) {
  const fontFamily = font === 'vazirharf' ? VAZIRHARF_FONT : 'inherit';

  const { EditorView: RuntimeEditorView } = joplin.require('@codemirror/view');
  editorView.dispatch({
    effects: RuntimeEditorView.theme({
      '.cm-content': { fontFamily },
      '.cm-line': { fontFamily },
    }),
  });

  if (font === 'vazirharf') {
    editorView.contentDOM?.style?.setProperty('font-family', VAZIRHARF_FONT, 'important');
    editorView.dom?.style?.setProperty('font-family', VAZIRHARF_FONT, 'important');
  } else {
    editorView.contentDOM?.style?.removeProperty('font-family');
    editorView.dom?.style?.removeProperty('font-family');
  }
}

export default function(_context: { contentScriptId: string; postMessage: any }) {
  return {
    plugin: (codeMirrorWrapper: any) => {
      const editorView = codeMirrorWrapper?.editor;
      if (!editorView) return;

      codeMirrorWrapper.registerCommand(EDITOR_FONT_COMMAND, (font: string) => {
        applyFont(editorView, font);
      });

      void joplin.settings.value(EDITOR_FONT_SETTING).then((font: string) => {
        applyFont(editorView, font || DEFAULT_EDITOR_FONT);
      });
    },
    assets: () => [{ name: './editor.css' }],
  };
}
