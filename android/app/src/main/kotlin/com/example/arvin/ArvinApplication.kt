package com.example.arvin

import android.app.Application
import android.os.Process
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStreamWriter
import java.nio.charset.StandardCharsets

/**
 * Records uncaught JVM exceptions that happen before Flutter has initialized.
 *
 * This does not intercept native process termination (SIGSEGV/SIGABRT), linker
 * failures, or kernel kills. The previous Android runtime handler is always
 * invoked after the best-effort diagnostic write.
 */
class ArvinApplication : Application() {
    override fun onCreate() {
        installNativeUncaughtExceptionRecorder()
        super.onCreate()
    }

    private fun installNativeUncaughtExceptionRecorder() {
        val previousHandler = Thread.getDefaultUncaughtExceptionHandler()
        val dumpFile = File(filesDir, CRASH_DUMP_FILE)

        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                FileOutputStream(dumpFile, true).use { stream ->
                    OutputStreamWriter(stream, StandardCharsets.UTF_8).use { writer ->
                        writer.appendLine("===== ARVIN NATIVE JVM UNCAUGHT EXCEPTION =====")
                        writer.appendLine("timestamp_epoch_ms=${System.currentTimeMillis()}")
                        writer.appendLine("process=${Process.myPid()}")
                        writer.appendLine("thread=${thread.name}")
                        writer.appendLine("exception=${throwable.javaClass.name}")
                        writer.appendLine(throwable.message ?: "(no message)")
                        writer.appendLine("stacktrace:")
                        writer.appendLine(throwable.stackTraceToString())
                        writer.appendLine("===== END ARVIN CRASH DUMP =====")
                        writer.flush()
                    }
                    stream.fd.sync()
                }
            } catch (writeFailure: Throwable) {
                // Do not replace or suppress the original fatal exception.
                Log.e(TAG, "Could not persist native crash diagnostics", writeFailure)
                Log.e(TAG, "Original uncaught exception", throwable)
            }

            // Preserve Android's normal fatal-process handling and crash reporting.
            if (previousHandler != null) {
                previousHandler.uncaughtException(thread, throwable)
            } else {
                Process.killProcess(Process.myPid())
                kotlin.system.exitProcess(10)
            }
        }
    }

    private companion object {
        const val TAG = "ArvinCrashRecorder"
        const val CRASH_DUMP_FILE = "crash_dump.txt"
    }
}
