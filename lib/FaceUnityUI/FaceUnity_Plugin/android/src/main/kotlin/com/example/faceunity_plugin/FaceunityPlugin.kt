package com.example.faceunity_plugin

import android.util.Log
import androidx.annotation.NonNull
import com.example.faceunity_plugin.impl.FUBeautyPlugin
import com.example.faceunity_plugin.impl.FUMakeupPlugin
import com.example.faceunity_plugin.impl.FUStickerPlugin
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FaceunityPlugin */
class FaceunityPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        private const val TAG = "FaceunityPlugin"
        private const val viewModelManagerPlugin = "viewModelManagerPlugin"
    }

    lateinit var trtcCloud: TRTCCloud

    private val fuBeautyPlugin: FUBeautyPlugin by lazy { FUBeautyPlugin() }
    private val fuStickerPlugin: FUStickerPlugin by lazy { FUStickerPlugin() }
    private val fuMakeupPlugin: FUMakeupPlugin by lazy { FUMakeupPlugin() }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "faceunity_plugin")
        channel.setMethodCallHandler(this)

        trtcCloud = TRTCCloud.sharedInstance(flutterPluginBinding.applicationContext)
        trtcCloud.setLocalVideoProcessListener(
            TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D,
            TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE,
            FUVideoProcessor(flutterPluginBinding.applicationContext)
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            FUBeautyPlugin.method -> {
                fuBeautyPlugin.methodCall(this, call, result)
            }
            FUStickerPlugin.method -> {
                fuStickerPlugin.methodCall(this, call, result)
            }
            FUMakeupPlugin.method -> {
                fuMakeupPlugin.methodCall(this, call, result)
            }
            viewModelManagerPlugin -> {
                methodCall(call)
            }
            else -> result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun methodCall(call: MethodCall) {
        val arguments = call.arguments as? Map<*, *>?
        Log.i("faceunity", "methodCall: ${arguments?.get("method") as String?}")
        when (arguments?.get("method") as String?) {
            "compatibleClickBeautyItem" -> {
                val value = arguments?.get("value") as Int
                fuBeautyPlugin.faceBeautyDataFactory?.beautyIndex = value
            }
            "switchOn" -> {
                val bizType = arguments?.get("bizType") as Int
                val isOn = arguments["value"] as Boolean
                fuBeautyPlugin.switchOn(isOn, bizType)
            }
        }
    }
}
