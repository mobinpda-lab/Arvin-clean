import json
from datetime import datetime, timezone
from pathlib import Path

BASE = Path('.execution-stream')
EVENTS = BASE / 'events.json'


def log_event(event_type, message, status='running', component='arvin'):
    BASE.mkdir(exist_ok=True)
    events = []
    if EVENTS.exists():
        events = json.loads(EVENTS.read_text())

    events.append({
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'type': event_type,
        'component': component,
        'status': status,
        'message': message
    })

    EVENTS.write_text(json.dumps(events, indent=2))
