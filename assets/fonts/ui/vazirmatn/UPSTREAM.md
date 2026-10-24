# Vazirmatn UI asset provenance

- Upstream: https://github.com/rastikerdar/vazirmatn
- Pinned source revision: `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7`
- Variant: UI + Farsi Digits (UI-FD)
- Source files: `misc/UI-Farsi-Digits/fonts/ttf/Vazirmatn-UI-FD-{Thin,ExtraLight,Light,Regular,Medium,SemiBold,Bold,ExtraBold,Black}.ttf`
- License: SIL Open Font License 1.1; see [upstream OFL.txt](https://github.com/rastikerdar/vazirmatn/blob/6e553e33489a8f9dfaccc76860a2e3f3c1e66de7/OFL.txt) and local `LICENSE.txt`.
- Complete family weights: Thin 100, ExtraLight 200, Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700, ExtraBold 800, Black 900.
- Main role mapping in Arvin: Regular 400 for body text, Light 300 for secondary text, Medium 500 for menus/buttons, Bold 700 for headings, SemiBold 600 for important emphasis. The other four weights are available when a real design need calls for them; they do not need to appear everywhere.

The local filenames omit the upstream `UI-FD` suffix for stable Flutter asset paths. Each binary is sourced from the pinned upstream snapshot, not renamed or substituted from another weight.
