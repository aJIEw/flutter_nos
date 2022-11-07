package com.shimi.flutter_nos

import android.content.Context
import android.text.format.DateUtils
import androidx.annotation.NonNull
import com.netease.cloud.nos.android.core.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File


/** FlutterNosPlugin */
class FlutterNosPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private lateinit var context: Context

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_nos")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_nos_event")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                var config: Map<String, Any> = emptyMap()
                if (call.arguments as Map<String, Any>? != null) {
                    config = call.arguments as Map<String, Any>
                }
                initNosSdk(config)
            }
            "uploadImage" -> {
                val map: Map<String, Any> = call.arguments as Map<String, Any>
                val bucketName: String = map["bucketName"] as String
                val objName: String = map["objName"] as String
                val uploadToken: String = map["uploadToken"] as String
                val imagePath: String = map["imagePath"] as String
                uploadImage(bucketName, objName, uploadToken, imagePath)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initNosSdk(config: Map<String, Any>) {
        val conf = AcceleratorConf()

        config["chunkSize"]?.let {
            // default 1024 * 32
            conf.chunkSize = it as Int
        }
        config["retryCount"]?.let {
            // default 2
            conf.chunkRetryCount = it as Int
        }
        config["connectionTimeout"]?.let {
            // default 1000 * 10
            conf.connectionTimeout = it as Int
        }
        config["socketTimeout"]?.let {
            // default 1000 * 30
            conf.soTimeout = it as Int
        }
        config["lbsConnectionTimeout"]?.let {
            // default 1000 * 10
            conf.lbsConnectionTimeout = it as Int
        }
        config["lbsSoTimeout"]?.let {
            // default 1000 * 10
            conf.lbsSoTimeout = it as Int
        }
        config["refreshInterval"]?.let {
            // default 2 hours, in milliseconds
            conf.refreshInterval = it as Long
        }
        config["monitorInterval"]?.let {
            // default 120 * 1000
            conf.monitorInterval = it as Long
        }
        config["monitorThread"]?.let {
            // default false
            conf.setMonitorThread(it as Boolean)
        }

        WanAccelerator.setConf(conf)
    }

    private fun uploadImage(
        bucketName: String,
        objName: String,
        uploadToken: String,
        imagePath: String
    ) {
        val wanNOSObject = WanNOSObject()
        wanNOSObject.nosBucketName = bucketName
        wanNOSObject.nosObjectName = objName
        wanNOSObject.contentType = "image/jpeg"
        wanNOSObject.uploadToken = uploadToken

        val file = File(imagePath)
        WanAccelerator.putFileByHttp(context, file, file.absoluteFile, null, wanNOSObject, object : Callback {
            override fun onUploadContextCreate(p0: Any?, p1: String?, p2: String?) {
            }

            override fun onProcess(p0: Any?, p1: Long, p2: Long) {
            }

            override fun onSuccess(p0: CallRet?) {
                val map = mapOf("method" to "onSuccess", "message" to p0?.response)
                eventSink?.success(map)
            }

            override fun onFailure(p0: CallRet?) {
                val map = mapOf("method" to "onFailure", "message" to p0?.response)
                eventSink?.success(map)
            }

            override fun onCanceled(p0: CallRet?) {
            }

        })
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {

    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
