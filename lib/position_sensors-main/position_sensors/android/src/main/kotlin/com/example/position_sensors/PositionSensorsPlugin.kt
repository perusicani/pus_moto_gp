package com.example.position_sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

class PositionSensorsPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var methodChannel : MethodChannel
  private lateinit var sensorManager: SensorManager
  private val sensorNames = mapOf(
    Sensor.TYPE_ROTATION_VECTOR to "rotation",
    Sensor.TYPE_GAME_ROTATION_VECTOR to "gameRotation",
    Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR to "magneticRotation",
    Sensor.TYPE_MAGNETIC_FIELD to "magneticField",
    Sensor.TYPE_MAGNETIC_FIELD_UNCALIBRATED to "uncalibratedMagneticField",
    Sensor.TYPE_PROXIMITY to "proximity"
  )
  private var delay = SensorManager.SENSOR_DELAY_NORMAL
  private lateinit var eventChannels: List<EventChannel>
  private lateinit var messenger: BinaryMessenger

  private fun setupEventChannels(messenger: BinaryMessenger) {
    eventChannels = sensorNames.filter {
      sensorManager.getDefaultSensor(it.key) != null
    }.map {
      val sensor = sensorManager.getDefaultSensor(it.key)
      sensor.maximumRange
      sensor.maximumRange
      val streamHandler = PositionStreamHandler(sensor, sensorManager, delay)
      val sensorChannel = EventChannel(messenger, "position_sensors/${it.value}")
      sensorChannel.setStreamHandler(streamHandler)
      sensorChannel
    }
  }

  private fun tearDownEventChannels() {
    eventChannels.forEach {
      it.setStreamHandler(null)
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    messenger = flutterPluginBinding.binaryMessenger
    methodChannel = MethodChannel(messenger, "position_sensors")
    methodChannel.setMethodCallHandler(this)
    val context = flutterPluginBinding.applicationContext
    sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    setupEventChannels(messenger)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        "getSupportedSensors" -> {
          val sensors = sensorNames.entries.filter {
            sensorManager.getDefaultSensor(it.key) !== null
          }.map {
            it.value
          }
          result.success(sensors)
        }
        "getProximityFarValue" -> {
          val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)
          if (sensor == null) {
            result.error(
              "SENSOR_NOT_SUPPORTED",
              "The proximity sensor is not available in this device.",
              null)
          } else {
            result.success(sensor.maximumRange)
          }

        }
        "setDelay" -> {
          val argument = call.arguments<Int?>()
          if(argument != null) {
            delay = argument
            setupEventChannels(messenger)
            result.success(null)
          } else {
            result.error("ARGUMENT_NOT_SUPPLIED", "Specify a integer delay type.", null)
          }
        }
        "getDelay" -> {
          result.success(delay)
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    tearDownEventChannels()
  }
}
