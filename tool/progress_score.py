#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

SCORECARD = Path('docs/progress_scorecard.json')
EXPECTED_IDS = set(range(1, 20))
ALLOWED_STAGES = {0, 10, 25, 40, 55, 70, 85, 100}
WAVE_X1 = {1, 2, 3, 6, 7, 10, 11, 17}


def rounded_percent(points: int, maximum: int) -> float:
    return round(points / maximum * 100, 1)


def load_scorecard() -> dict:
    return json.loads(SCORECARD.read_text(encoding='utf-8'))


def validate(data: dict) -> dict:
    errors = []
    features = data.get('features', [])
    ids = [feature.get('id') for feature in features]

    if len(features) != 19:
        errors.append(f'expected 19 features, found {len(features)}')
    if set(ids) != EXPECTED_IDS:
        errors.append(f'feature ids must be exactly 1..19, found {sorted(set(ids))}')
    if len(ids) != len(set(ids)):
        errors.append('feature ids must be unique')

    for feature in features:
        stage = feature.get('stage')
        if stage not in ALLOWED_STAGES:
            errors.append(
                f"feature {feature.get('id')} has invalid stage {stage}; "
                f'allowed={sorted(ALLOWED_STAGES)}'
            )
        evidence = feature.get('evidence')
        if stage and (not isinstance(evidence, list) or not evidence):
            errors.append(
                f"feature {feature.get('id')} has progress credit but no evidence"
            )

    points = sum(feature.get('stage', 0) for feature in features)
    x1_points = sum(
        feature.get('stage', 0)
        for feature in features
        if feature.get('id') in WAVE_X1
    )
    calculated = {
        'overall_percent': rounded_percent(points, 19 * 100),
        'wave_x1_percent': rounded_percent(x1_points, len(WAVE_X1) * 100),
        'features_at_core_or_better': sum(
            1 for feature in features if feature.get('stage', 0) >= 40
        ),
        'features_started': sum(
            1 for feature in features if feature.get('stage', 0) > 0
        ),
        'features_done': sum(
            1 for feature in features if feature.get('stage', 0) == 100
        ),
    }

    reported = data.get('reported_metrics', {})
    for key, value in calculated.items():
        if reported.get(key) != value:
            errors.append(
                f'reported_metrics.{key}={reported.get(key)!r} '
                f'does not match calculated value {value!r}'
            )

    declared_allowed = set(data.get('allowed_stages', []))
    if declared_allowed != ALLOWED_STAGES:
        errors.append(
            f'allowed_stages must be {sorted(ALLOWED_STAGES)}, '
            f'found {sorted(declared_allowed)}'
        )

    declared_x1 = set(data.get('wave_x1_feature_ids', []))
    if declared_x1 != WAVE_X1:
        errors.append(
            f'wave_x1_feature_ids must be {sorted(WAVE_X1)}, '
            f'found {sorted(declared_x1)}'
        )

    if errors:
        raise SystemExit('Progress scorecard validation failed:\n- ' + '\n- '.join(errors))

    return calculated


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--check',
        action='store_true',
        help='validate the committed scorecard and reported metrics',
    )
    args = parser.parse_args()

    calculated = validate(load_scorecard())
    print(f"Arvin roadmap progress: {calculated['overall_percent']:.1f}%")
    print(f"Wave X1 progress: {calculated['wave_x1_percent']:.1f}%")
    print(
        'Features: '
        f"started={calculated['features_started']}/19, "
        f"core+={calculated['features_at_core_or_better']}/19, "
        f"done={calculated['features_done']}/19"
    )

    if args.check:
        print('Scorecard validation: OK')


if __name__ == '__main__':
    main()
