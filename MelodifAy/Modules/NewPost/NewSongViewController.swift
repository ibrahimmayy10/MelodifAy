//
//  NewSongViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 9.10.2024.
//

import UIKit
import AVFoundation

class NewSongViewController: UIViewController {
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let newPostLabel = Labels(textLabel: "Yeni Gönderi", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let timerLabel = Labels(textLabel: "00.00", fontLabel: .boldSystemFont(ofSize: 26), textColorLabel: .white)
    private let videoLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 30), textColorLabel: .white)
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Video", "Ses"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let soundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let timerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        view.layer.cornerRadius = 70
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let audioRecordingStartButton: UIButton = {
        let button = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 70, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "mic.circle.fill", withConfiguration: largeConfig)
        
        button.setImage(largeImage, for: .normal)
        button.tintColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        
        return button
    }()
        
    private let uploadRecordedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "camera.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        return button
    }()
    
    private let existingRecordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 17/255, green: 57/255, blue: 113/255, alpha: 1.0)
        button.setTitle("Mevcut Ses Kaydı", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    let scrollView = UIScrollView()
    let waveformContentView = UIView()
    
    private let centerLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    var waveformBars = [UIView]()
    var waveformXOffset: CGFloat = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    var recordedAudioURL: URL?
    var selectedAudioURL: URL?
    
    private var timer: Timer?
    private var elapsedTime: Int = 0
    private var totalTime: String = ""
    private var progressUpdateTimer: Timer?
    
    private let progressLayer = CAShapeLayer()
    private let maxRecordingTime: Int = 300
    
    private var isAnimating = false
    private var isSeeking: Bool = false
    private var isRecordingPaused = false
    
    private var videoPlayer: AVPlayer?
    var selectedVideoURL: URL?
    
    var playbackSpeed: Float = 1.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureTopBar()
        configureSegmentedControl()
        configureWithExt()
        configureTimerLabel()
        configureAudioPlayerView()
        configureVideoView()
        addTargetButtons()
        setupCircularProgress()
        
        existingRecordButton.isHidden = recordedAudioURL == nil
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateCircularProgressFrame()
    }
    
    func setupCircularProgress() {
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 5
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        timerView.layer.addSublayer(progressLayer)
    }
    
    func updateCircularProgressFrame() {
        let center = CGPoint(x: timerView.bounds.midX, y: timerView.bounds.midY)
        let radius = min(timerView.bounds.width, timerView.bounds.height) / 2 - progressLayer.lineWidth / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: true)
        
        progressLayer.path = circularPath.cgPath
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        uploadRecordedButton.addTarget(self, action: #selector(uploadRecordedButton_Clicked), for: .touchUpInside)
        audioRecordingStartButton.addTarget(self, action: #selector(audioRecordingButton_Clicked), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButton_Clicked), for: .touchUpInside)
        existingRecordButton.addTarget(self, action: #selector(existingRecordButton_Clicked), for: .touchUpInside)
    }
    
    @objc func existingRecordButton_Clicked() {
        let vc = AudioRecordingPreviewViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.audioURL = self.recordedAudioURL
        self.present(vc, animated: true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func cameraButton_Clicked() {
        let vc = CameraViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func convertUrlToString(url: URL) -> String {
        return url.absoluteString
    }
    
    @objc func backButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            videoView.isHidden = false
            soundView.isHidden = true
        } else {
            videoView.isHidden = true
            soundView.isHidden = false
        }
    }
    
    @objc func audioRecordingPlayButton_Clicked() {
        if isRecordingPaused {
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            isRecordingPaused = false
            
            print("kayıt devam ediyor")
        }
    }
    
    @objc func audioRecordingPauseButton_Clicked() {
        if !isRecordingPaused {
            guard let recorder = audioRecorder, recorder.isRecording else {
                print("Kayıt devam etmiyor, durdurulacak bir şey yok.")
                return
            }
            
            audioRecorder?.pause()
            timer?.invalidate()
            
            print("Kayıt duraklatıldı.")
            isRecordingPaused = true
        }
    }
    
    @objc func audioRecordingButton_Clicked() {
        if audioRecorder?.isRecording == true {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc func uploadRecordedButton_Clicked() {
        if segmentedControl.selectedSegmentIndex == 0 {
            let videoPicker = UIImagePickerController()
            videoPicker.delegate = self
            videoPicker.sourceType = .photoLibrary
            videoPicker.mediaTypes = [UTType.movie.identifier]
            present(videoPicker, animated: true)
        } else {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            present(documentPicker, animated: true)
        }
    }
    
    func startRecording() {
        resetWaveform()
        waveformContentView.isHidden = false
        centerLine.isHidden = false
        isRecordingPaused = false
        existingRecordButton.isHidden = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.audioRecordingStartButton.transform = self.audioRecordingStartButton.transform.scaledBy(x: 1.2, y: 1.2)
        })
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession ayarlanamadı: \(error)")
            return
        }
        
        let recordingPath = "\(UUID().uuidString)/\(Date().timeIntervalSince1970)/recording.m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(recordingPath)
        
        try? FileManager.default.createDirectory(at: audioFilename.deletingLastPathComponent(),
                                                   withIntermediateDirectories: true)
            
        recordedAudioURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            elapsedTime = 0
            timerLabel.text = "00:00"
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            
            print("kayıt başladı")
            
            Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateAudioMeter), userInfo: nil, repeats: true)
        } catch {
            print("kayıt yapılamadı")
        }
    }
    
    @objc func updateTimer() {
        elapsedTime += 1
        
        if elapsedTime == maxRecordingTime {
            stopRecording()
            return
        }
        
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        let progress = CGFloat(elapsedTime) / CGFloat(maxRecordingTime)
        progressLayer.strokeEnd = progress
        
        if !isAnimating {
            animateRecordingButton()
        }
    }
    
    func animateRecordingButton() {
        isAnimating = true
        UIView.animate(withDuration: 0.5, animations: {
            self.audioRecordingStartButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.audioRecordingStartButton.transform = .identity
            }) { _ in
                self.isAnimating = false
            }
        }
    }
    
    @objc func updateAudioMeter() {
        guard let recorder = audioRecorder, !isRecordingPaused else { return }
        recorder.updateMeters()
        
        let averagePower = recorder.averagePower(forChannel: 0)
        let normalizedPower = normalizedPowerLevel(fromDecibels: averagePower)
                
        updateWaveform(normalizedPower)
    }
    
    func normalizedPowerLevel(fromDecibels decibels: Float) -> CGFloat {
        let minDecibels: Float = -80.0
        
        if decibels < minDecibels {
            return 0.0
        } else {
            let level = pow(10.0, 0.05 * decibels)
            return CGFloat(level)
        }
    }
    
    func updateWaveform(_ level: CGFloat) {
        let maxBarHeight: CGFloat = 150
        let minBarHeight: CGFloat = 5
        let centerY: CGFloat = maxBarHeight / 2
        
        let barHeight = max(minBarHeight, level * maxBarHeight)
        let topOffset = centerY - barHeight / 2
        
        let newBar = UIView()
        newBar.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        newBar.translatesAutoresizingMaskIntoConstraints = false
        
        newBar.frame = CGRect(x: waveformXOffset, y: topOffset, width: 3, height: barHeight)
        waveformContentView.addSubview(newBar)
        waveformBars.append(newBar)
        
        waveformXOffset += 4
        
        scrollView.contentSize = CGSize(width: waveformXOffset, height: maxBarHeight)
        
        if waveformXOffset > scrollView.frame.width {
            let newOffset = CGPoint(x: waveformXOffset - scrollView.frame.width, y: 0)
            scrollView.setContentOffset(newOffset, animated: false)
        }
        
        if let firstBar = waveformBars.first, firstBar.frame.maxX < scrollView.contentOffset.x {
            firstBar.removeFromSuperview()
            waveformBars.removeFirst()
        }
    }
    
    func stopRecording() {
        guard let recorder = audioRecorder, recorder.isRecording else {
            print("Kayıt devam etmiyor, durdurulacak bir şey yok.")
            return
        }
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        timer?.invalidate()
        timer = nil
        
        waveformContentView.isHidden = true
        centerLine.isHidden = true
        existingRecordButton.isHidden = false
        isRecordingPaused = false
        
        elapsedTime += 1
        totalTime = timerLabel.text ?? ""
        
        progressLayer.strokeEnd = 0
        
        print("Kayıt durduruldu")
        let vc = AudioRecordingPreviewViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        vc.audioURL = self.recordedAudioURL
        self.present(navController, animated: true)
    }
    
    func resetWaveform() {
        for bar in waveformBars {
            bar.removeFromSuperview()
        }
        waveformBars.removeAll()
        
        waveformXOffset = 0.0
        
        scrollView.contentOffset = .zero
        scrollView.contentSize = CGSize(width: 0, height: 50)
        
        waveformContentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func formatTime(_ timeInSeconds: Int) -> String {
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startAnimatingText() {
        let text = "Hemen video çekmeye başlayabilir ya da mevcut videonuzu yükleyebilirsiniz."
        animateTextInLabel(text: text) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.startAnimatingText()
            }
        }
    }
    
    private func animateTextInLabel(text: String, completion: @escaping () -> Void) {
        let totalCharacters = text.count
        
        videoLabel.text = ""
        
        let delayMultiplier = 0.05
        for (index, char) in text.enumerated() {
            let delay = Double(index) * delayMultiplier
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.videoLabel.text?.append(char)
                
                if index == totalCharacters - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayMultiplier) {
                        completion()
                    }
                }
            }
        }
    }
    
}

extension NewSongViewController {
    func configureTopBar() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.addViews(backButton, newPostLabel, seperatorView, uploadRecordedButton)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        newPostLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        uploadRecordedButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        seperatorView.anchor(top: newPostLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, height: 1)
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        soundView.isHidden = true
        segmentedControl.anchor(top: seperatorView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
    }
    
    private func configureWithExt() {
        view.addViews(videoView, soundView)
        soundView.addViews(audioRecordingStartButton, existingRecordButton)
        videoView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        soundView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
                
        existingRecordButton.anchor(bottom: audioRecordingStartButton.topAnchor, centerX: view.centerXAnchor, paddingBottom: 20, width: 200, height: 50)
        audioRecordingStartButton.anchor(bottom: soundView.safeAreaLayoutGuide.bottomAnchor, centerX: view.centerXAnchor, paddingBottom: 10)
    }
    
    private func configureTimerLabel() {
        soundView.addSubview(timerView)
        timerView.addViews(timerLabel)
        
        timerView.layer.shadowColor = UIColor.black.cgColor
        timerView.layer.shadowOpacity = 0.4
        timerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        timerView.layer.shadowRadius = 4
        
        timerView.anchor(top: segmentedControl.bottomAnchor, centerX: soundView.centerXAnchor, paddingTop: 20, width: 140, height: 140)
        timerLabel.anchor(centerX: timerView.centerXAnchor, centerY: timerView.centerYAnchor)
    }
    
    func configureAudioPlayerView() {
        soundView.addViews(scrollView, centerLine)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.isUserInteractionEnabled = false
        waveformContentView.isUserInteractionEnabled = false
        scrollView.addSubview(waveformContentView)
        
        scrollView.anchor(top: timerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 60, height: 150)
        waveformContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, height: 150)
        waveformContentView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        centerLine.anchor(left: view.leftAnchor, right: view.rightAnchor, centerY: scrollView.centerYAnchor, height: 1)
    }
    
    func configureVideoView() {
        videoView.addViews(cameraButton, videoLabel)
        
        videoLabel.numberOfLines = 0
        
        videoLabel.anchor(top: videoView.topAnchor, left: videoView.leftAnchor, right: videoView.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        cameraButton.anchor(bottom: videoView.safeAreaLayoutGuide.bottomAnchor, centerX: videoView.centerXAnchor, paddingBottom: 10)
        
        startAnimatingText()
    }
}

extension NewSongViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileUrl = urls.first else { return }
        
        guard selectedFileUrl.startAccessingSecurityScopedResource() else {
            print("Could not access the file.")
            return
        }
        
        do {
            var isDirectory: ObjCBool = false
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: selectedFileUrl.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
                print("File does not exist or is a directory")
                selectedFileUrl.stopAccessingSecurityScopedResource()
                return
            }
            
            let documentsDirectory = getDocumentsDirectory()
            let destinationURL = documentsDirectory.appendingPathComponent(selectedFileUrl.lastPathComponent)
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: selectedFileUrl, to: destinationURL)
            
            selectedFileUrl.stopAccessingSecurityScopedResource()
            
            self.recordedAudioURL = destinationURL
            
            let vc = ShareNewPostViewController()
            vc.newPostURL = self.recordedAudioURL
            navigationController?.pushViewController(vc, animated: true)
            
        } catch {
            print("Error processing file: \(error)")
            selectedFileUrl.stopAccessingSecurityScopedResource()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension NewSongViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("kayıt başarıyla tamamlandı")
        } else {
            print("kayıt başarısız oldu")
        }
    }
}

extension NewSongViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension NewSongViewController {
    func makeAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

extension NewSongViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedVideoURL = info[.mediaURL] as? URL {
            self.selectedVideoURL = selectedVideoURL
            print(selectedVideoURL)
            
            do {
                var isDirectory: ObjCBool = false
                let fileManager = FileManager.default
                guard fileManager.fileExists(atPath: selectedVideoURL.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
                    print("File does not exist or is a directory")
                    selectedVideoURL.stopAccessingSecurityScopedResource()
                    return
                }
                
                let documentsDirectory = getDocumentsDirectory()
                let destinationURL = documentsDirectory.appendingPathComponent(selectedVideoURL.lastPathComponent)
                
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                try fileManager.copyItem(at: selectedVideoURL, to: destinationURL)
                
                selectedVideoURL.stopAccessingSecurityScopedResource()
                
                self.selectedVideoURL = destinationURL
                
                self.dismiss(animated: true) {
                    let vc = EditVideoViewController()
                    vc.videoURL = self.selectedVideoURL
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } catch {
                print("Error processing file: \(error)")
                selectedVideoURL.stopAccessingSecurityScopedResource()
            }
        }
    }
}
