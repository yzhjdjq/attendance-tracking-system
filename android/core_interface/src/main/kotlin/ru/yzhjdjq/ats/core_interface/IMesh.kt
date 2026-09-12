package ru.yzhjdjq.ats.core_interface

import android.content.Context
import android.util.Log
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf

/**
 * Список используемых разрешений
 */
enum class Permissions
{
    NOT_IMPLEMENTED,
    BLUETOOTH,
    BLUETOOTH_ADMIN,
    BLUETOOTH_SCAN,
    BLUETOOTH_CONNECT,
    BLUETOOTH_ADVERTISE,
    ACCESS_FINE_LOCATION,
    ACCESS_COARSE_LOCATION,
    POST_NOTIFICATIONS;

    fun toChannelValue(): String = this.name.lowercase()
}

/**
 * Список возможных результатов отправки сообщения
 */
enum class SendResult
{
    NOT_IMPLEMENTED,
    SUCCESS,
    ERROR;

    fun toChannelValue(): String = this.name.lowercase()
}

/**
 * Класс, описывающий статус разрешения
 */
data class PermissionStatus(
    val name: Permissions,
    val granted: Boolean,
    val required: Boolean = true
)


interface IMesh {
    /**
     * Возвращает true, если BLE Mesh реализован
     */
    fun isImplemented(): Boolean

    /**
     * Запускает BLE MeshForegroundService
     *
     * @param applicationContext контекст приложения
     * @param userId идентификатор пользователя
     */
    fun initMeshForegroundService(applicationContext: Context, userId: String)

    /**
     * Возвращает true, если BLE MeshForegroundService запущен
     */
    fun isMeshForegroundServiceRunning(): Boolean

    /**
     * Останавливает BLE MeshForegroundService
     *
     * @param applicationContext контекст приложения
     */
    fun stopMeshForegroundService(applicationContext: Context)

    /**
     * Возвращает поток состояний BLE MeshForegroundService'а
     */
    fun serviceStateFlow(): Flow<Boolean>

    /**
     * Устанавливает идентификатор пользователя
     *
     * Если идентификатор пользователя не установлен (null),
     * то MeshService будет остановлен.
     *
     * @param applicationContext контекст приложения
     * @param userId идентификатор пользователя
     */
    fun setUserId(applicationContext: Context, userId: String?)

    /**
     * Возвращает поток полученных сообщений
     */
    fun receiveMessageFlow(): Flow<String>

    /**
     * Возвращает список PermissionStatus, описывая все необходимые разрешения
     */
    fun getPermissionsState(): List<PermissionStatus>

    /**
     * Возвращает количество участников сети
     *
     * На текущий момент возвращает количество BLE соединений
     * вместо количества соединений с другими userId-узлами.
     */
    fun getNumberOfNetworkMembers(): Int

    /**
     * Отправляет сообщение по BLE Mesh каналу
     */
    fun sendMessage(message: String): SendResult
}

class StubMesh : IMesh {
    override fun isImplemented(): Boolean = false
    override fun initMeshForegroundService(applicationContext: Context, userId: String) = Unit
    override fun isMeshForegroundServiceRunning(): Boolean = false
    override fun stopMeshForegroundService(applicationContext: Context) = Unit
    override fun serviceStateFlow(): Flow<Boolean> = flowOf(false)
    override fun setUserId(applicationContext: Context, userId: String?): Unit = Unit
    override fun receiveMessageFlow(): Flow<String> = flowOf("Not implemented")
    override fun getPermissionsState(): List<PermissionStatus> =
        listOf(PermissionStatus(name = Permissions.NOT_IMPLEMENTED, granted = false, required = false))
    override fun getNumberOfNetworkMembers(): Int = 0
    override fun sendMessage(message: String): SendResult = SendResult.NOT_IMPLEMENTED
}

object MeshFactory {
    private var TAG: String = "MeshFactory"
    private var instance: IMesh? = null

    fun create(): IMesh {
        instance?.let { return it }

        instance = try {
            Log.d(TAG, "Loading implementation...")
            val clazz = Class.forName("ru.yzhjdjq.ats.core.Mesh")
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

    fun hasImplementation(): Boolean {
        return try {
            Class.forName("ru.yzhjdjq.ats.core.Mesh")
            true
        } catch (_: ClassNotFoundException) {
            false
        }
    }
}
