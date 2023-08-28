package com.example.position_sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

class PositionStreamHandler(sensor: Sensor, sensorManager: SensorManager, delay: Int): EventChannel.StreamHandler {
    private val _sensorManager = sensorManager
    private val _sensor = sensor
    private val _delay = delay
    private lateinit var _eventListener: SensorEventListener

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        _eventListener = createEventListener(events)
        _sensorManager.registerListener(_eventListener, _sensor, _delay)
    }

    override fun onCancel(arguments: Any?) {
        _sensorManager.unregisterListener(_eventListener)
    }

    private fun createEventListener(events: EventChannel.EventSink?): SensorEventListener {
        return object : SensorEventListener {
            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
            override fun onSensorChanged(event: SensorEvent) {
                val values = event.values.map { it.toDouble() }
                events?.success(values)
            }
        }
    }

}