import joplin from 'api';

const VAZIRHARF_FONT = '"VazirHarf", Tahoma, sans-serif';

export default function(_context: { contentScriptId: string; postMessage: any }) {
  return {
    plugin: (codeMirrorWrapper: any) => {
      // Use Joplin's own CodeMirror 6 instance and install a native CM6 theme.
      // This avoids relying on DOM styles alone in the Android WebView.
      const editorView = codeMirrorWrapper?.editor;
      if (!editorView) return;

      const { EditorView } = joplin.require('@codemirror/view');

      editorView.dispatch({
        effects: EditorView.theme({
          '.cm-content': {
            fontFamily: VAZIRHARF_FONT,
          },
          '.cm-line': {
            fontFamily: VAZIRHARF_FONT,
          },
        }),
      });

      // Keep a direct DOM fallback for Android/WebView.
      const contentDOM = editorView.contentDOM;
      const editorDOM = editorView.dom;

      contentDOM?.style?.setProperty('font-family', VAZIRHARF_FONT, 'important');
      editorDOM?.style?.setProperty('font-family', VAZIRHARF_FONT, 'important');
    },
    assets: () => [{ name: './editor.css' }],
  };
};
