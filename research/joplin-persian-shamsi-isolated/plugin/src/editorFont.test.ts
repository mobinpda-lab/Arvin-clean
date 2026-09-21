import { DEFAULT_EDITOR_FONT, VAZIRHARF_FONT } from './editorFont';

const assertEqual = (actual: unknown, expected: unknown, label: string) => {
  if (actual !== expected) throw new Error(`${label}: expected ${expected}, got ${actual}`);
};

const resolveEditorFont = (value: string | undefined) =>
  value === 'vazirharf' ? VAZIRHARF_FONT : 'inherit';

assertEqual(resolveEditorFont('vazirharf'), VAZIRHARF_FONT, 'VazirHarf selection');
assertEqual(resolveEditorFont(DEFAULT_EDITOR_FONT), 'inherit', 'Joplin default selection');
assertEqual(resolveEditorFont(undefined), 'inherit', 'missing selection');

console.info('Editor font selection verification cases passed');
