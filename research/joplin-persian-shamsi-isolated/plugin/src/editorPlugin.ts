const VAZIRHARF_FONT = '"VazirHarf", Tahoma, sans-serif';

export default function(_context: { contentScriptId: string; postMessage: any }) {
  return {
    plugin: (codeMirrorWrapper: any) => {
      // Joplin's CodeMirror 6 content script receives a CodeMirrorControl
      // wrapper. The actual EditorView is in .editor.
      const editorView = codeMirrorWrapper?.editor;
      const contentDOM = editorView?.contentDOM;
      const editorDOM = editorView?.dom;

      if (contentDOM?.style) {
        contentDOM.style.setProperty('font-family', VAZIRHARF_FONT, 'important');
      }

      if (editorDOM?.style) {
        editorDOM.style.setProperty('font-family', VAZIRHARF_FONT, 'important');
      }

      // Keep the editable surface correct if Joplin/CodeMirror recreates it.
      if (contentDOM && typeof MutationObserver !== 'undefined') {
        const observer = new MutationObserver(() => {
          contentDOM.style.setProperty('font-family', VAZIRHARF_FONT, 'important');
        });
        observer.observe(contentDOM, { childList: true, subtree: true });
      }
    },
    assets: () => [{ name: './editor.css' }],
  };
};
