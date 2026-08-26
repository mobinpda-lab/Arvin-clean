package com.example.arvin

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Native boundary for routing Android Widget task taps into Flutter. */
class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    private var pendingWidgetTaskId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingWidgetTaskId = intent?.getStringExtra(EXTRA_TASK_ID)
        widgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )
        widgetChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CONSUME_TASK_ID -> {
                    val taskId = pendingWidgetTaskId
                        ?: intent?.getStringExtra(EXTRA_TASK_ID)
                    pendingWidgetTaskId = null
                    intent?.removeExtra(EXTRA_TASK_ID)
                    result.success(taskId)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val taskId = intent.getStringExtra(EXTRA_TASK_ID) ?: return
        pendingWidgetTaskId = taskId
        widgetChannel?.invokeMethod(METHOD_TASK_SELECTED, taskId)
    }

    companion object {
        const val CHANNEL_NAME = "arvin/widget_task"
        const val EXTRA_TASK_ID = "arvin_task_id"
        const val METHOD_CONSUME_TASK_ID = "consumeWidgetTaskId"
        const val METHOD_TASK_SELECTED = "widgetTaskSelected"
    }
}
