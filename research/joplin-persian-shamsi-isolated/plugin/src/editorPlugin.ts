export default function(_context: unknown) {
  return {
    plugin: (_editor: any) => {
      // The editor behaviour is intentionally untouched.
      // CSS-only styling keeps this content script low-risk.
    },
    assets: () => [{ name: './editor.css' }],
  };
};
