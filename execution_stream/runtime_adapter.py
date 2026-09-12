"""
Arvin Execution Stream Runtime Adapter

Central interface for connecting orchestrator, workers, tests and recovery
systems to the Execution Stream event layer.
"""

from datetime import datetime, timezone


class ExecutionStreamAdapter:
    def __init__(self, project="Arvin"):
        self.project = project

    def emit(self, event_type, component, message, status="running", metadata=None):
        return {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "project": self.project,
            "event_type": event_type,
            "component": component,
            "status": status,
            "message": message,
            "metadata": metadata or {},
        }

    def task_started(self, task_id):
        return self.emit("task_started", "orchestrator", f"Task {task_id} started")

    def worker_started(self, worker):
        return self.emit("worker_started", worker, "Worker execution started")

    def test_result(self, result):
        return self.emit("test_completed", "test_pipeline", result, "success")

    def recovery_event(self, message):
        return self.emit("recovery", "recovery_system", message)
