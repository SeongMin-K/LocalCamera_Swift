//
//  ViewController.swift
//  LocalCameraMetal_Swift
//
//  Created by SeongMinK on 2022/04/29.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var cameraToggleBtn: UIButton!
    
    var captureSession: AVCaptureSession!
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
