package com.example.faceunity_plugin

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import com.example.faceunity_plugin.data.BundlePathConfig
import com.example.faceunity_plugin.utils.FuDeviceUtils
import com.faceunity.core.callback.OperateCallback
import com.faceunity.core.entity.FURenderInputData
import com.faceunity.core.entity.FURenderOutputData
import com.faceunity.core.enumeration.CameraFacingEnum
import com.faceunity.core.enumeration.FUExternalInputEnum
import com.faceunity.core.enumeration.FUInputTextureEnum
import com.faceunity.core.enumeration.FUTransformMatrixEnum
import com.faceunity.core.faceunity.FUAIKit
import com.faceunity.core.faceunity.FURenderKit
import com.faceunity.core.faceunity.FURenderManager
import com.faceunity.core.model.facebeauty.FaceBeautyBlurTypeEnum
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener
import kotlin.math.abs

/**
 * @description
 * @author Qinyu on 2021-11-05
 */
class FUVideoProcessor(application: Context, renderListener: RenderListener?) : TRTCCloudListener.TRTCVideoFrameListener {
    /**传感器**/
    private var mSensorManager: SensorManager
    private var mSensor: Sensor
    private var deviceOrientation = 90//手机设备朝向
    private var renderListener: RenderListener? = null

    init {
        mSensorManager = application.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        this.renderListener = renderListener
    }


    override fun onGLContextCreated() {
        mSensorManager.registerListener(mSensorEventListener, mSensor, SensorManager.SENSOR_DELAY_NORMAL)
        FURenderKit.getInstance().setUseTexAsync(true)
        renderListener?.onGLContextCreated()
    }

    /**
     * srcFrame	用于承载 TRTC 采集到的摄像头画面
     * dstFrame	用于接收第三方美颜处理过的视频画面
     */
    override fun onProcessVideoFrame(srcFrame: TRTCCloudDef.TRTCVideoFrame?, dstFrame: TRTCCloudDef.TRTCVideoFrame?): Int {

        if (BundlePathConfig.DEVICE_LEVEL > FuDeviceUtils.DEVICE_LEVEL_MID) {
            //高性能设备
            cheekFaceNum()
        }

        val input : FURenderInputData = FURenderInputData(srcFrame!!.width, srcFrame.height)
            .apply {
                texture = FURenderInputData.FUTexture(FUInputTextureEnum.FU_ADM_FLAG_COMMON_TEXTURE, srcFrame.texture.textureId)
                renderConfig.apply {
                    externalInputType = FUExternalInputEnum.EXTERNAL_INPUT_TYPE_CAMERA
                    inputOrientation = 180
                    cameraFacing = CameraFacingEnum.CAMERA_FRONT
                    inputTextureMatrix = FUTransformMatrixEnum.CCROT0_FLIPVERTICAL
                    inputBufferMatrix = FUTransformMatrixEnum.CCROT0_FLIPVERTICAL
                    outputMatrix = FUTransformMatrixEnum.CCROT0
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

    private fun cheekFaceNum() {
        //根据有无人脸 + 设备性能 判断开启的磨皮类型
        val faceProcessorGetConfidenceScore = FUAIKit.getInstance().getFaceProcessorGetConfidenceScore(0)
        if (faceProcessorGetConfidenceScore >= 0.95) {
            //高端手机并且检测到人脸开启均匀磨皮，人脸点位质

            FURenderKit.getInstance().faceBeauty?.let {
                if (it.blurType != FaceBeautyBlurTypeEnum.EquallySkin) {
                    it.blurType = FaceBeautyBlurTypeEnum.EquallySkin
                    it.enableBlurUseMask = true
                }
            }
        } else {
            FURenderKit.getInstance().faceBeauty?.let {
                if (it.blurType != FaceBeautyBlurTypeEnum.FineSkin) {
                    it.blurType = FaceBeautyBlurTypeEnum.FineSkin
                    it.enableBlurUseMask = false
                }
            }
        }
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

    fun interface RenderListener {
        fun onGLContextCreated()
    }
}