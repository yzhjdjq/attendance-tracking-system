package ru.yzhjdjq.ats.core

import android.util.Log
import ru.yzhjdjq.ats.core_interface.*

class RealTestInterface : TestInterface {
    override fun IsImplemented(): Boolean {
        return true
    }

    override fun SendMessage(): SendResult {
        Log.d("RealTestInfoProvider", "SendMessage function call processed.")
        return SendResult.SUCCESS
    }
}