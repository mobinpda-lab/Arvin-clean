
const toPersianDigits = (value: string): string => value.replace(/[0-9]/g, (d) => '۰۱۲۳۴۵۶۷۸۹'[Number(d)]);

const div = (a: number, b: number): number => Math.floor(a / b);

export const gregorianToJalali = (gy: number, gm: number, gd: number): [number, number, number] => {
  const gdm = [0,31,28,31,30,31,30,31,31,30,31,30,31];
  const jdm = [0,31,31,31,31,31,30,30,30,30,30,29];
  let gy2 = gy - 1600;
  let dayNo = 365 * gy2 + div(gy2 + 3, 4) - div(gy2 + 99, 100) + div(gy2 + 399, 400);
  let gDay = gd - 1;
  for (let i = 1; i < gm; i++) gDay += gdm[i];
  if (gm > 2 && ((gy % 4 === 0 && gy % 100 !== 0) || gy % 400 === 0)) gDay += 1;
  dayNo += gDay;
  let jDayNo = dayNo - 79;
  let jy = 979 + 33 * div(jDayNo, 12053);
  jDayNo %= 12053;
  if (jDayNo >= 366) {
    jy += 4 * div(jDayNo, 1461);
    jDayNo %= 1461;
    if (jDayNo > 365) {
      jy += div(jDayNo - 1, 365);
      jDayNo = (jDayNo - 1) % 365;
    }
  }
  let jm = 1;
  while (jm <= 11 && jDayNo >= jdm[jm]) {
    jDayNo -= jdm[jm];
    jm++;
  }
  return [jy, jm, jDayNo + 1];
};

const convertDateText = (text: string): string => text.replace(/(19|20)\d{2}[-/]([01]?\d)[-/]([0-3]?\d)\b/g, (full, ys, ms, ds) => {
  const y = Number(ys), m = Number(ms), d = Number(ds);
  if (m < 1 || m > 12 || d < 1 || d > 31) return full;
  const [jy, jm, jd] = gregorianToJalali(y, m, d);
  return toPersianDigits(jy + '/' + String(jm).padStart(2, '0') + '/' + String(jd).padStart(2, '0'));
});

export default function(_context: unknown) {
  return {
    plugin: (markdownIt: any) => {
      markdownIt.core.ruler.push('jps-jalali-display', (state: any) => {
        const visit = (tokens: any[]) => {
          for (const token of tokens) {
            if (token.type === 'inline' && token.children) {
              for (const child of token.children) {
                if (child.type === 'text' && child.content) {
                  child.content = convertDateText(child.content);
                }
              }
            }
          }
        };
        visit(state.tokens);
      });
      const defaultRender = markdownIt.renderer.render;
      markdownIt.renderer.render = function(tokens: any[], options: any, env: any) {
        const html = defaultRender.call(this, tokens, options, env);
        return '<div class="jps-note" dir="rtl" lang="fa">' + html + '</div>';
      };
    },
    assets: { css: ['./style.css'] },
  };
};
