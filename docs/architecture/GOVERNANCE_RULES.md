# Arvin Governance Rules

## Documentation
- Canonical documents define current decisions.
- Audit and migration history documents remain valuable but are not decision authority.

## Code
- Avoid duplicate models.
- Avoid duplicate storage paths.
- Keep migrations incremental and reversible.

## Validation
Required before merging architectural changes:
- flutter analyze
- flutter test
- flutter build apk --release

## Migration Gate
Home migration starts only after contract ownership is clear.
