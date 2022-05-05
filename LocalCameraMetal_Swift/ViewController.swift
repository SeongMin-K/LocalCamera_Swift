//
//  ViewController.swift
//  LocalCameraMetal_Swift
//
//  Created by SeongMinK on 2022/04/29.
//

import UIKit
import MetalKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var preview: MTKView!
    @IBOutlet weak var cameraToggleBtn: UIButton!
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    var captureSession: AVCaptureSession!
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        preview.contentMode = .scaleAspectFit
        
        device = MTLCreateSystemDefaultDevice()
        preview.device = device
        
        commandQueue = preview.device?.makeCommandQueue()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        setupLivePreview()
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            backCameraInput = try AVCaptureDeviceInput(device: backCamera)
            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            let photoOutput = AVCapturePhotoOutput()
            photoOutput.isHighResolutionCaptureEnabled = true
            
            if captureSession.canAddInput(backCameraInput), captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(backCameraInput)
                captureSession.addOutput(photoOutput)
            }
        } catch {
            print(error.localizedDescription)
        }

        startCaptureSession()
    }
    
    private func render() {
        guard let renderPassDescriptor = preview.currentRenderPassDescriptor else { return }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        guard let currentDrawable = preview.currentDrawable else { return }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    private func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        preview.layer.insertSublayer(videoPreviewLayer, at: 0)
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.preview.bounds
        }
    }
    
    private func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    @IBAction func onCameraToggleBtnClicked(_ sender: UIButton) {
        captureSession.beginConfiguration()
        
        if captureSession.inputs[0] == backCameraInput {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
        } else if captureSession.inputs[0] == frontCameraInput {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
        }
        
        captureSession.commitConfiguration()
    }
}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render()
    }
}
