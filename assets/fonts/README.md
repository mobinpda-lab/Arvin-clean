# Font asset policy

## Canonical public/default application font

Arvin's only official/default application font is **Vazirmatn**.

- Upstream project: https://github.com/rastikerdar/vazirmatn
- License: SIL Open Font License 1.1; the complete `LICENSE.txt` is bundled beside the font files.
- Flutter family: `Vazirmatn`
- Required local weights: Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700.
- Runtime and PDF rendering must use these locally bundled assets; network font loading is prohibited.

The only optional user preference is **System Default**. It is an accessibility/platform choice, not an alternative Arvin brand font.

## Historical VazirHarf assets

VazirHarf is not the official or default font. Any retained VazirHarf files or provenance records are historical evidence only and must not be registered, loaded, or packaged as the active application font. Do not delete historical files without a separate compatibility and evidence review.

## Licensing

Keep the full SIL OFL 1.1 license with the Vazirmatn assets. Verify the upstream source revision and SHA-256 checksums of all distributed binary files before final acceptance.
