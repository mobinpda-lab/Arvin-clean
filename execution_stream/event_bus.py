"""
Arvin Execution Stream Event Bus

Central event entry point for future Orchestrator, Worker, Test and Recovery integrations.
"""

from datetime import datetime, timezone


class ExecutionEventBus:
    def __init__(self):
        self.events = []

    def emit(self, event_type, component, message, status="running", metadata=None):
        event = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "event_type": event_type,
            "component": component,
            "status": status,
            "message": message,
            "metadata": metadata or {},
        }
        self.events.append(event)
        return event

    def history(self):
        return self.events
