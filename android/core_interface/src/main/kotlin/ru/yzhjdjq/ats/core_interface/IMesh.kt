package ru.yzhjdjq.ats.core_interface

import android.content.Context
import android.util.Log
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf

interface IMesh {
  /**
   * Возвращает true, если BLE Mesh реализован.
   */
  fun isImplemented(): Boolean

  /**
   * Запускает BLE MeshForegroundService.
   */
  fun initMeshForegroundService(applicationContext: Context, userId: String)

  /**
   * Возвращает true, если BLE MeshForegroundService запущен.
   */
  fun isMeshForegroundServiceRunning(): Boolean

  /**
   * Останавливает BLE MeshForegroundService.
   */
  fun stopMeshForegroundService(applicationContext: Context)

  /**
   * Возвращает поток состояний BLE MeshForegroundService'а.
   */
  fun serviceStateFlow(): Flow<Boolean>

  /**
   * Устанавливает идентификатор пользователя.
   *
   * Если идентификатор не установлен (`null`), MeshService будет остановлен.
   */
  fun setUserId(applicationContext: Context, userId: String?)

  /**
   * Возвращает поток полученных сообщений в формате Dart-DTO.
   */
  fun receiveMessageFlow(): Flow<Map<String, Any?>>

  /**
   * Возвращает количество соседних участников сети.
   */
  fun getNumberOfNeighboringNetworkMembers(): Int

  /**
   * Возвращает поток количества соседних участников сети.
   */
  fun neighboringNetworkMembersFlow(): Flow<Int>

  /**
   * Отправляет сообщение по BLE Mesh.
   *
   * @param message Dart-DTO сообщения.
   */
  fun sendMessage(message: Map<String, Any?>): DeliveryStatus
}

/**
 * Заглушка для случая, когда core-библиотека отсутствует.
 */
class StubMesh : IMesh {
  override fun isImplemented(): Boolean = false

  override fun initMeshForegroundService(applicationContext: Context, userId: String) = Unit

  override fun isMeshForegroundServiceRunning(): Boolean = false

  override fun stopMeshForegroundService(applicationContext: Context) = Unit

  override fun serviceStateFlow(): Flow<Boolean> = flowOf(false)

  override fun setUserId(applicationContext: Context, userId: String?) = Unit

  override fun receiveMessageFlow(): Flow<Map<String, Any?>> = flowOf()

  override fun getNumberOfNeighboringNetworkMembers(): Int = 0

  override fun neighboringNetworkMembersFlow(): Flow<Int> = flowOf()

  override fun sendMessage(message: Map<String, Any?>): DeliveryStatus =
    DeliveryStatus.NOT_IMPLEMENTED
}

object MeshFactory {
  private const val TAG = "MeshFactory"
  private const val IMPL_CLASS = "ru.yzhjdjq.ats.core.Mesh"

  private var instance: IMesh? = null

  fun create(): IMesh {
    instance?.let { return it }

    instance = try {
      Log.d(TAG, "Loading implementation...")
      val clazz = Class.forName(IMPL_CLASS)
      Log.d(TAG, "Found class: ${clazz.name}")
      clazz.getDeclaredConstructor().newInstance() as IMesh
    } catch (e: ClassNotFoundException) {
      Log.e(TAG, "Implementation NOT found, using stub", e)
      StubMesh()
    } catch (e: Exception) {
      Log.e(TAG, "Error loading implementation, using stub", e)
      StubMesh()
    }

    return instance!!
  }

  @Suppress("UNUSED")
  fun hasImplementation(): Boolean {
    return try {
      Class.forName(IMPL_CLASS)
      true
    } catch (_: ClassNotFoundException) {
      false
    }
  }
}
