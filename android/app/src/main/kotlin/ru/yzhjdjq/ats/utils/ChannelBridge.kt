package ru.yzhjdjq.ats.utils

import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.coroutines.cancellation.CancellationException

/**
 * Мост между нативным Flow и Flutter EventSink.
 * Жизненный цикл равен циклу подписки на EventChannel,
 * что позволяет удобно управлять job'ами корутин.
 */
class ChannelBridge<T>(
  private val scope: CoroutineScope,
  private val flow: Flow<T>,
  private val initialValue: suspend () -> T? = { null },
) {
  private var job: Job? = null

  fun attach(sink: EventChannel.EventSink, onError: (Throwable) -> Unit = {}) {
    detach()
    job = scope.launch {
      try {
        initialValue()?.let { withContext(Dispatchers.Main) { sink.success(it) } }
        flow.collect { value ->
          withContext(Dispatchers.Main) { sink.success(value) }
        }
      } catch (e: CancellationException) {
        throw e
      } catch (e: Throwable) {
        onError(e)
        withContext(Dispatchers.Main) { sink.error("CHANNEL_ERROR", e.message, null) }
      }
    }
  }

  fun detach() {
    job?.cancel()
    job = null
  }
}
