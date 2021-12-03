package com.example.faceunity_plugin

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import com.faceunity.core.callback.OperateCallback
import com.faceunity.core.entity.FURenderInputData
import com.faceunity.core.entity.FURenderOutputData
import com.faceunity.core.enumeration.CameraFacingEnum
import com.faceunity.core.enumeration.FUExternalInputEnum
import com.faceunity.core.enumeration.FUInputTextureEnum
import com.faceunity.core.enumeration.FUTransformMatrixEnum
import com.faceunity.core.faceunity.FURenderKit
import com.faceunity.core.faceunity.FURenderManager
import com.faceunity.core.utils.FULogger
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener
import kotlin.math.abs

/**
 * @description
 * @author Qinyu on 2021-11-05
 */
class FUVideoProcessor(application: Context) : TRTCCloudListener.TRTCVideoFrameListener {
    /**传感器**/
    private var mSensorManager: SensorManager
    private var mSensor: Sensor
    private var deviceOrientation = 90//手机设备朝向

    init {
        FURenderManager.registerFURender(application, authpack.A(), object : OperateCallback {
            override fun onSuccess(code: Int, msg: String) {
                Log.d("registerFURender", "success:$msg")
            }

            override fun onFail(errCode: Int, errMsg: String) {
                Log.e("registerFURender", "errCode:$errCode   errMsg:$errMsg")
            }
        })
        FURenderManager.setKitDebug(FULogger.LogLevel.DEBUG)
        mSensorManager = application.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    }


    override fun onGLContextCreated() {
        mSensorManager.registerListener(mSensorEventListener, mSensor, SensorManager.SENSOR_DELAY_NORMAL)
        FURenderKit.getInstance().setUseTexAsync(true)
    }

    /**
     * srcFrame	用于承载 TRTC 采集到的摄像头画面
     * dstFrame	用于接收第三方美颜处理过的视频画面
     */
    override fun onProcessVideoFrame(srcFrame: TRTCCloudDef.TRTCVideoFrame?, dstFrame: TRTCCloudDef.TRTCVideoFrame?): Int {
        val input : FURenderInputData = FURenderInputData(srcFrame!!.width, srcFrame.height)
                .apply {
                    texture = FURenderInputData.FUTexture(FUInputTextureEnum.FU_ADM_FLAG_COMMON_TEXTURE, srcFrame.texture.textureId)
                    renderConfig.apply {
                        externalInputType = FUExternalInputEnum.EXTERNAL_INPUT_TYPE_CAMERA
                        inputOrientation = 180
                        cameraFacing = CameraFacingEnum.CAMERA_FRONT
                        inputTextureMatrix = FUTransformMatrixEnum.CCROT0
                        outputMatrix = FUTransformMatrixEnum.CCROT0_FLIPVERTICAL
                        deviceOrientation = this@FUVideoProcessor.deviceOrientation
                    }
                }
        val output: FURenderOutputData = FURenderKit.getInstance().renderWithInput(input)
        dstFrame!!.width = output.texture!!.width
        dstFrame.height = output.texture!!.height
        dstFrame.texture.textureId = output.texture!!.texId
        return 0
    }

    override fun onGLContextDestory() {
        FURenderKit.getInstance().release()
        mSensorManager.unregisterListener(mSensorEventListener)
    }

    /**
     * 内置陀螺仪
     */
    private val mSensorEventListener = object : SensorEventListener {
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

        override fun onSensorChanged(event: SensorEvent?) {
            if (event!!.sensor.type == Sensor.TYPE_ACCELEROMETER) {
                val x = event.values[0]
                val y = event.values[1]
                if (abs(x) > 3 || abs(y) > 3) {
                    deviceOrientation = if (abs(x) > abs(y)) {
                        if (x > 0) 0 else 180
                    } else {
                        if (y > 0) 90 else 270
                    }
                }
            }
        }
    }
}