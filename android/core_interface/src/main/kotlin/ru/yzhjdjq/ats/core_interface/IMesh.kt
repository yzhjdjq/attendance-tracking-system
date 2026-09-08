package ru.yzhjdjq.ats.core_interface

import android.util.Log

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
     * Возвращает список PermissionStatus, описывая все необходимые разрешения
     */
    fun getPermissionsState(): List<PermissionStatus>

    /**
     * Отправляет сообщение по BLE Mesh каналу
     */
    fun sendMessage(): SendResult
}

class StubMesh : IMesh {
    override fun isImplemented(): Boolean = false
    override fun getPermissionsState(): List<PermissionStatus> =
        listOf(PermissionStatus(name = Permissions.NOT_IMPLEMENTED, granted = false, required = false))
    override fun sendMessage(): SendResult = SendResult.NOT_IMPLEMENTED
}

object MeshFactory {
    private var TAG: String = "MeshFactory"
    private var instance: IMesh? = null

    fun setInstance(mesh: IMesh) {
        instance = mesh
    }

    fun resetInstance() {
        instance = null
    }

    fun create(): IMesh {
        instance?.let { return it }

        return try {
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
    }

    fun hasImplementation(): Boolean {
        return try {
            Class.forName("ru.yzhjdjq.ats.core.Mesh")
            true
        } catch (e: ClassNotFoundException) {
            false
        }
    }
}
