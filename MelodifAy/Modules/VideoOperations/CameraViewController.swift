//
//  CameraViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.10.2024.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var movieOutput = AVCaptureMovieFileOutput()
    var isRecording = false
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.plain()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
        config.image = largeImage
        config.baseForegroundColor = .darkGray
        config.background.backgroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button.configuration = config

        button.anchor(width: 30, height: 30)
            
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .systemRed
        
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.heightAnchor.constraint(equalToConstant: 70).isActive = true

        button.layer.cornerRadius = 35
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
    
        button.clipsToBounds = true
        
        return button
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular, scale: .large)
        let largeImage = UIImage(systemName: "pause.circle", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.isHidden = true
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        setupCamera()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButton_Clicked), for: .touchUpInside)
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }
    
    @objc func cameraButton_Clicked() {
        if isRecording {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
            cameraButton.setImage(largeImage, for: .normal)
            cameraButton.tintColor = .systemRed
            
            movieOutput.stopRecording()
            isRecording = false
            pauseButton.isHidden = true
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "stop.fill", withConfiguration: largeConfig)
            cameraButton.setImage(largeImage, for: .normal)
            cameraButton.tintColor = .systemRed
            
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            isRecording = true
            pauseButton.isHidden = false
        }
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        }
        
        if captureSession?.canAddOutput(movieOutput) == true {
            captureSession?.addOutput(movieOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.insertSublayer(previewLayer!, at: 0)
        
        captureSession?.startRunning()
    }

}

extension CameraViewController {
    func configureWithExt() {
        view.backgroundColor = .white
        
        view.addViews(dismissButton, cameraButton, pauseButton)
        
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        cameraButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, centerX: view.centerXAnchor, paddingBottom: 10)
        pauseButton.anchor(left: view.leftAnchor, centerY: cameraButton.centerYAnchor, paddingLeft: 10)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("video kaydedildi: \(outputFileURL)")
        }
    }
}
