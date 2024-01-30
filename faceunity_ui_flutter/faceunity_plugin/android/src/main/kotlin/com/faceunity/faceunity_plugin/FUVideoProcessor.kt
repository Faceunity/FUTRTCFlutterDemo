package com.faceunity.faceunity_plugin

import android.content.Context
import android.opengl.EGL14
import android.util.Log
import com.faceunity.core.entity.FURenderInputData
import com.faceunity.core.enumeration.CameraFacingEnum
import com.faceunity.core.enumeration.FUExternalInputEnum
import com.faceunity.core.enumeration.FUInputTextureEnum
import com.faceunity.core.enumeration.FUTransformMatrixEnum
import com.faceunity.core.faceunity.FUAIKit
import com.faceunity.core.faceunity.FURenderKit
import com.faceunity.core.model.facebeauty.FaceBeautyBlurTypeEnum
import com.tencent.trtc.TRTCCloud
import com.tencent.trtc.TRTCCloudDef
import com.tencent.trtc.TRTCCloudListener

/**
 *
 * @author benyq
 * @date 12/5/2023
 *
 */
class FUVideoProcessor(private val context: Context) : TRTCCloudListener.TRTCVideoFrameListener {
    companion object {
        private const val TAG = "FUVideoProcessor"
    }
    private var deviceOrientation = 270//手机设备朝向
    private var enableRender = false
    private var highLeveDeice = false
    private val trtcCloud = TRTCCloud.sharedInstance(context)

    override fun onGLContextCreated() {
        Log.d(TAG, "onGLContextCreated: ${EGL14.eglGetCurrentContext()}")
    }

    /**
     * srcFrame	用于承载 TRTC 采集到的摄像头画面
     * dstFrame	用于接收第三方美颜处理过的视频画面
     */
    override fun onProcessVideoFrame(srcFrame: TRTCCloudDef.TRTCVideoFrame?, dstFrame: TRTCCloudDef.TRTCVideoFrame?): Int {
        if (!enableRender) return 0
        if (highLeveDeice) {
            cheekFaceNum()
        }
        srcFrame?.let {
            dstFrame?.let {
                val input : FURenderInputData = FURenderInputData(srcFrame.width, srcFrame.height)
                    .apply {
                        texture = FURenderInputData.FUTexture(FUInputTextureEnum.FU_ADM_FLAG_COMMON_TEXTURE, srcFrame.texture.textureId)
                        renderConfig.apply {
                            externalInputType = FUExternalInputEnum.EXTERNAL_INPUT_TYPE_CAMERA
                            deviceOrientation = this@FUVideoProcessor.deviceOrientation
                            inputOrientation = srcFrame.rotation
                            if (trtcCloud.deviceManager.isFrontCamera) {
                                inputTextureMatrix = FUTransformMatrixEnum.CCROT0_FLIPHORIZONTAL
                                inputBufferMatrix = FUTransformMatrixEnum.CCROT0_FLIPHORIZONTAL
                                outputMatrix = FUTransformMatrixEnum.CCROT180
                                cameraFacing = CameraFacingEnum.CAMERA_FRONT
                            }else {
                                inputTextureMatrix = FUTransformMatrixEnum.CCROT0
                                inputBufferMatrix = FUTransformMatrixEnum.CCROT0
                                outputMatrix = FUTransformMatrixEnum.CCROT0_FLIPVERTICAL
                                cameraFacing = CameraFacingEnum.CAMERA_BACK
                            }
                        }
                    }
                val texture = FURenderKit.getInstance().renderWithInput(input).texture ?:return 0
                dstFrame.width = texture.width
                dstFrame.height = texture.height
                dstFrame.texture.textureId =texture.texId
            }
        }
        return 0
    }

    override fun onGLContextDestory() {
        Log.d(TAG, "onGLContextDestory: ${EGL14.eglGetCurrentContext()}")
        FURenderKit.getInstance().release()
    }

    private fun cheekFaceNum() {
        //根据有无人脸 + 设备性能 判断开启的磨皮类型
        val faceProcessorGetConfidenceScore =
            FUAIKit.getInstance().getFaceProcessorGetConfidenceScore(0)
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

    fun enableRender(enable: Boolean) {
        enableRender = enable
    }

    fun setDeviceOrientation(deviceOrientation: Int) {
        this.deviceOrientation = (deviceOrientation + 180) % 360
    }

    fun setHighLeveDeice(highLeveDeice: Boolean) {
        this.highLeveDeice = highLeveDeice
    }
}