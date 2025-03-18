//
//  CameraViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.10.2024.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
        
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00.00"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let pauseLabel: UILabel = {
        let label = UILabel()
        label.text = "DURAKLATILDI"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
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
    
    private let changeCameraPositionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let largeImage = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    private let flashButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let largeImage = UIImage(systemName: "bolt.slash.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        
        button.tintColor = .white
        
        return button
    }()
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var movieOutput = AVCaptureMovieFileOutput()
    var currentCameraPosition: AVCaptureDevice.Position = .back
    private var isRecording = false
    private var currentVideoURL: URL?
    private var isFlashOn = false
    private var isAutoFlashEnabled = false
    
    private var doubleTapGesture = UITapGestureRecognizer()
    
    private var timer: Timer?
    private var elapsedTime: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        setupCamera()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButton_Clicked), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButton_Clicked), for: .touchUpInside)
        changeCameraPositionButton.addTarget(self, action: #selector(toggleCameraPosition), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(flashButton_Clicked), for: .touchUpInside)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCameraPosition))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func flashButton_Clicked() {
        isAutoFlashEnabled.toggle()
        let flashIconName = isAutoFlashEnabled ? "bolt.circle.fill" : "bolt.slash.circle.fill"
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let largeImage = UIImage(systemName: flashIconName, withConfiguration: largeConfig)
        flashButton.setImage(largeImage, for: .normal)
    }
    
    func toggleFlash(isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
            isFlashOn = isOn
        } catch {
            print("el feneri ayarlanamadı")
        }
    }
        
    @objc func toggleCameraPosition() {
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        }
        
        captureSession.commitConfiguration()
    }
    
    @objc func pauseButton_Clicked() {
        if pauseButton.tag == 0 {
            pauseButton.tag = 1
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)
            pauseButton.setImage(largeImage, for: .normal)
            pauseButton.tintColor = .systemRed
            
            pauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
            pauseButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

            pauseButton.layer.cornerRadius = 35
            pauseButton.layer.borderWidth = 3
            pauseButton.layer.borderColor = UIColor.white.cgColor
        
            pauseButton.clipsToBounds = true
            
            pauseLabel.isHidden = false
            timerLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            
            movieOutput.pauseRecording()
            timer?.invalidate()
        } else {
            pauseButton.tag = 0
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular, scale: .large)
            let largeImage = UIImage(systemName: "pause.circle", withConfiguration: largeConfig)
            pauseButton.setImage(largeImage, for: .normal)
            pauseButton.tintColor = .white
            
            pauseButton.widthAnchor.constraint(equalToConstant: 40).isActive = false
            pauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = false
            pauseButton.layer.cornerRadius = 0
            pauseButton.layer.borderWidth = 0
            pauseButton.layer.borderColor = UIColor.clear.cgColor
            
            pauseLabel.isHidden = true
            timerLabel.backgroundColor = .systemRed
            movieOutput.resumeRecording()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
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
            
            view.addGestureRecognizer(doubleTapGesture)
            
            movieOutput.stopRecording()
            isRecording = false
            pauseButton.isHidden = true
            timer?.invalidate()
            elapsedTime = 0
            timerLabel.text = "00.00"
            timerLabel.isHidden = true
            pauseLabel.isHidden = true
            changeCameraPositionButton.isHidden = false
            flashButton.isHidden = false
            if isAutoFlashEnabled {
                toggleFlash(isOn: false)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                let vc = EditVideoViewController()
                vc.videoURL = self.currentVideoURL
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "stop.fill", withConfiguration: largeConfig)
            cameraButton.setImage(largeImage, for: .normal)
            cameraButton.tintColor = .systemRed
            
            let largeConfigPause = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular, scale: .large)
            let largeImagePause = UIImage(systemName: "pause.circle", withConfiguration: largeConfigPause)
            pauseButton.setImage(largeImagePause, for: .normal)
            pauseButton.tintColor = .white
            
            pauseButton.widthAnchor.constraint(equalToConstant: 40).isActive = false
            pauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = false
            pauseButton.layer.cornerRadius = 0
            pauseButton.layer.borderWidth = 0
            pauseButton.layer.borderColor = UIColor.clear.cgColor
            
            view.removeGestureRecognizer(doubleTapGesture)
            
            let outputUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".MOV")
            self.currentVideoURL = outputUrl
            movieOutput.startRecording(to: outputUrl, recordingDelegate: self)
            isRecording = true
            pauseButton.isHidden = false
            timerLabel.isHidden = false
            changeCameraPositionButton.isHidden = true
            flashButton.isHidden = true
            
            elapsedTime = 0
            timerLabel.text = "00:00"
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            if isAutoFlashEnabled {
                toggleFlash(isOn: true)
            }
        }
    }
    
    @objc func updateTimer() {
        elapsedTime += 1
        
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
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
        
        guard let audioCaptureDevice = AVCaptureDevice.default(for: .audio) else { return }
        let audioInput: AVCaptureDeviceInput
        
        do {
            audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
        } catch {
            print("Audio input oluşturulamadı: \(error)")
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        }
        
        if captureSession?.canAddInput(audioInput) == true {
            captureSession?.addInput(audioInput)
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
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.isHidden = true
        
        view.addViews(dismissButton, cameraButton, pauseButton, timerLabel, pauseLabel, changeCameraPositionButton, flashButton)
                
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        timerLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10, width: 100, height: 30)
        changeCameraPositionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        flashButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: changeCameraPositionButton.leftAnchor, paddingTop: 10, paddingRight: 10)
        pauseLabel.anchor(top: timerLabel.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 10, width: 130, height: 25)
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
            self.currentVideoURL = outputFileURL
        }
    }
}
