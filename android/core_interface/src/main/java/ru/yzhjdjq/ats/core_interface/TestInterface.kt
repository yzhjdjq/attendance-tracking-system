package ru.yzhjdjq.ats.core_interface

import android.util.Log

enum class SendResult
{
    NOT_IMPLEMENTED,
    SUCCESS,
    ERROR
}

interface TestInterface {
    fun IsImplemented(): Boolean
    fun SendMessage(): SendResult
}

class StubTestInterface : TestInterface {
    override fun IsImplemented(): Boolean = false
    override fun SendMessage(): SendResult = SendResult.NOT_IMPLEMENTED
}

object TestInterfaceFactory {
    private var instance: TestInterface? = null

    fun setInstance(testInterface: TestInterface) {
        instance = testInterface
    }

    fun resetInstance() {
        instance = null
    }

    fun create(): TestInterface {
        instance?.let { return it }

        return try {
            Log.d("TestInterfaceFactory", "Loading real implementation...")
            val clazz = Class.forName("ru.yzhjdjq.ats.core.RealTestInterface")
            Log.d("TestInterfaceFactory", "Found class: ${clazz.name}")
            clazz.getDeclaredConstructor().newInstance() as TestInterface
        } catch (e: ClassNotFoundException) {
            Log.e("TestInterfaceFactory", "Real implementation NOT found, using stub", e)
            StubTestInterface()
        } catch (e: Exception) {
            Log.e("TestInterfaceFactory", "Error loading real implementation, using stub", e)
            StubTestInterface()
        }
    }

    fun hasRealImplementation(): Boolean {
        return try {
            Class.forName("ru.yzhjdjq.ats.core.RealTestInterface")
            true
        } catch (e: ClassNotFoundException) {
            false
        }
    }
}
