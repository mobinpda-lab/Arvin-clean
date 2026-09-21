import { convertDateText, gregorianToJalali } from './markdownItPlugin';

const assertEqual = (actual: unknown, expected: unknown, label: string) => {
  if (actual !== expected) throw new Error(`${label}: expected ${expected}, got ${actual}`);
};

assertEqual(gregorianToJalali(2026, 3, 21).join('/'), '1405/1/1', 'Nowruz 1405');
assertEqual(gregorianToJalali(2026, 9, 21).join('/'), '1405/6/30', '2026-09-21');
assertEqual(convertDateText('2026-09-21'), '۱۴۰۵/۰۶/۳۰', 'numeric date');
assertEqual(convertDateText('Date: 2026/09/21'), 'Date: ۱۴۰۵/۰۶/۳۰', 'embedded date');
assertEqual(convertDateText('2026-13-40'), '2026-13-40', 'invalid date');

console.info('Jalali verification cases passed');
