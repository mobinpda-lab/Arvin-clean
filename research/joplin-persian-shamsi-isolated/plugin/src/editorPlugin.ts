const VAZIRHARF_FONT = '"VazirHarf", Tahoma, sans-serif';

export default function(_context: unknown) {
  return {
    plugin: (editor: any) => {
      // CodeMirror 6 exposes the editable DOM through contentDOM.
      // Apply the font directly so Android edit mode does not depend
      // on CSS selector matching alone.
      const contentDOM = editor?.contentDOM;

      if (contentDOM?.style) {
        contentDOM.style.fontFamily = VAZIRHARF_FONT;
      }

      // Keep the editor root aligned with the editable content.
      const editorDOM = editor?.dom;
      if (editorDOM?.style) {
        editorDOM.style.fontFamily = VAZIRHARF_FONT;
      }
    },
    // Keep the CSS asset as a fallback for editor elements that are
    // recreated by Joplin/CodeMirror.
    assets: () => [{ name: './editor.css' }],
  };
};
