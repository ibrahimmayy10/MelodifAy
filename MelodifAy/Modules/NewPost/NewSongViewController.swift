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
        button.tintColor = .black
        return button
    }()
    
    private let newPostLabel = Labels(textLabel: "Yeni Gönderi", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let timerLabel = Labels(textLabel: "00.00", fontLabel: .boldSystemFont(ofSize: 32), textColorLabel: .black)
    private let videoLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 30), textColorLabel: .black)
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Video", "Ses"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let soundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let timerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 80
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let playView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let buttonsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    let audioRecordingStartButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 60
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    private let audioRecordingStartButton: UIButton = {
        let button = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "mic.circle.fill", withConfiguration: largeConfig)
        
        button.setImage(largeImage, for: .normal)
        button.tintColor = .systemOrange
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let audioRecordingPlayButton: UIButton = {
        let button = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
        
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        return button
    }()
    
    private let audioRecordingPauseButton: UIButton = {
        let button = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "stop.circle.fill", withConfiguration: largeConfig)
        
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isHidden = true
        
        return button
    }()
    
    private let optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
        
    private let uploadRecordedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.forward"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.isHidden = true
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "goforward.15", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.isHidden = true
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backwardButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "gobackward.15", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.isHidden = true
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let audioSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isHidden = true
        slider.minimumValue = 0
        slider.tintColor = .gray
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let largeCircleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        slider.setThumbImage(largeCircleImage, for: .normal)
        return slider
    }()
    
    private let waveformView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "camera.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .systemOrange
        return button
    }()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    let scrollView = UIScrollView()
    let waveformContentView = UIView()
    var waveformBars = [UIView]()
    var waveformXOffset: CGFloat = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    var recordedAudioURL: URL?
    var selectedAudioURL: URL?
    
    private var timer: Timer?
    private var elapsedTime: Int = 0
    private var progressUpdateTimer: Timer?
    
    private let progressLayer = CAShapeLayer()
    private let maxRecordingTime: Int = 180
    
    private var isAnimating = false
    private var isSeeking: Bool = false
    private var isRecordingPaused = false
    
    private var videoPlayer: AVPlayer?
    var selectedVideoURL: URL?
    
    var playbackSpeed: Float = 1.0
    
    let viewModel = NewSongViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopBar()
        configureSegmentedControl()
        configureWithExt()
        configureTimerLabel()
        configureWaveformView()
        configureAudioPlayerView()
        configureVideoView()
        addTargetButtons()
        setupCircularProgress()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateCircularProgressFrame()
    }
    
    func setupCircularProgress() {
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemOrange.cgColor
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
    
    @objc func audioSliderValueChanged(_ slider: UISlider) {
        guard let player = audioPlayer else { return }
        player.currentTime = TimeInterval(slider.value)
        updateProgress()
    }
    
    func startUpdatingProgress() {
        progressUpdateTimer?.invalidate()

        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    func updateProgress() {
        guard let player = audioPlayer else { return }
        
        audioSlider.value = Float(player.currentTime)
        
        let minutes = Int(player.currentTime) / 60
        let seconds = Int(player.currentTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        uploadRecordedButton.addTarget(self, action: #selector(uploadRecordedButton_Clicked), for: .touchUpInside)
        audioRecordingStartButton.addTarget(self, action: #selector(audioRecordingButton_Clicked), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_Clicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButton_Clicked), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(backwardButton_Clicked), for: .touchUpInside)
        audioRecordingPlayButton.addTarget(self, action: #selector(audioRecordingPlayButton_Clicked), for: .touchUpInside)
        audioRecordingPauseButton.addTarget(self, action: #selector(audioRecordingPauseButton_Clicked), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(optionsButton_Clicked), for: .touchUpInside)
        audioSlider.addTarget(self, action: #selector(audioSliderValueChanged(_:)), for: .valueChanged)
        cameraButton.addTarget(self, action: #selector(cameraButton_Clicked), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButton_Clicked), for: .touchUpInside)
    }
    
    @objc func nextButton_Clicked() {
        guard ((recordedAudioURL?.absoluteString.isEmpty) != nil) else {
            self.showAlert(message: "Herhangi bir kayıt bulunamadı")
            return
        }
        let vc = ShareNewPostViewController()
        vc.newPostURL = recordedAudioURL
        navigationController?.pushViewController(vc, animated: true)
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
    
    @objc func optionsButton_Clicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Paylaş", style: .default, handler: { action in
            self.shareAudio()
        }))
        
        alert.addAction(UIAlertAction(title: "Taslağı Kaydet", style: .default, handler: { action in
            guard let recordedAudioURL = self.recordedAudioURL else { return }
                        
            self.viewModel.saveDraft(url: recordedAudioURL) { success in
                if success {
                    let successImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
                    successImageView.tintColor = .systemOrange
                    successImageView.alpha = 0.0
                    successImageView.translatesAutoresizingMaskIntoConstraints = false
                    self.soundView.addSubview(successImageView)
                    
                    successImageView.anchor(centerX: self.soundView.centerXAnchor, centerY: self.soundView.centerYAnchor, width: 100, height: 100)
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        successImageView.alpha = 1.0
                    }) { _ in
                        UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                            successImageView.alpha = 0.0
                        }, completion: { _ in
                            successImageView.removeFromSuperview()
                        })
                    }
                } else {
                    self.makeAlert(message: "Ses taslağı kaydedilirken bir hata oluştu.")
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Seçenekler", style: .default, handler: { action in
            let optionsVC = EditPostViewController()
            optionsVC.modalPresentationStyle = .custom
            optionsVC.transitioningDelegate = self
            optionsVC.playbackSpeed = self.playbackSpeed
            optionsVC.audioURL = self.recordedAudioURL
            optionsVC.delegate = self
            self.present(optionsVC, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func convertUrlToString(url: URL) -> String {
        return url.absoluteString
    }
    
    func shareAudio() {
        let activityViewController = UIActivityViewController(activityItems: [recordedAudioURL], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func forwardButton_Clicked() {
        guard let player = audioPlayer else { return }
        player.currentTime += 15
    }
    
    @objc func backwardButton_Clicked() {
        guard let player = audioPlayer else { return }
        player.currentTime -= 15
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
        if audioPlayer != nil {
            stopAndResetPlayback()
        }
        
        if audioRecorder?.isRecording == true {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func stopAndResetPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = nil
        audioSlider.value = 0
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        playButton.setImage(largeImage, for: .normal)
        playButton.tag = 0
    }
    
    @objc func playButton_Clicked() {
        if playButton.tag == 0 {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            playButton.tag = 1
            
            guard let url = recordedAudioURL else { return }
            
            do {
                if audioPlayer == nil {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.delegate = self
                    audioPlayer?.enableRate = true
                    audioPlayer?.rate = playbackSpeed
                    audioPlayer?.prepareToPlay()
                    audioSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
                }
                
                audioPlayer?.play()
                
                startUpdatingProgress()
                print("Ses çalınıyor.")
            } catch {
                print("DEBUG: Ses çalma hatası: \(error)")
            }
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            playButton.tag = 0
            
            pausePlayback()
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = nil
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
        waveformView.isHidden = false
        waveformContentView.isHidden = false
        audioRecordingPlayButton.isHidden = false
        buttonsView.isHidden = false
        audioRecordingPauseButton.isHidden = false
        optionsButton.isHidden = true
        playView.isHidden = true
        audioSlider.isHidden = true
        playButton.isHidden = true
        forwardButton.isHidden = true
        backwardButton.isHidden = true
        isRecordingPaused = false
        
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
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
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
        let remainingTime = maxRecordingTime - elapsedTime
        
        if remainingTime <= 0 {
            stopRecording()
            return
        }
        
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
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
        let maxBarHeight: CGFloat = 50
        let minBarHeight: CGFloat = 5
        let centerY: CGFloat = maxBarHeight / 2
        
        let barHeight = max(minBarHeight, level * maxBarHeight)
        let topOffset = centerY - barHeight / 2
        
        let newBar = UIView()
        newBar.backgroundColor = .gray
        newBar.translatesAutoresizingMaskIntoConstraints = false
        
        newBar.frame = CGRect(x: waveformXOffset, y: topOffset, width: 2, height: barHeight)
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
                
        playView.isHidden = false
        audioSlider.isHidden = false
        playButton.isHidden = false
        forwardButton.isHidden = false
        backwardButton.isHidden = false
        optionsButton.isHidden = false
        waveformView.isHidden = true
        waveformContentView.isHidden = true
        audioRecordingPlayButton.isHidden = true
        buttonsView.isHidden = true
        audioRecordingPauseButton.isHidden = true
        isRecordingPaused = false
        
        elapsedTime += 1
        
        progressLayer.strokeEnd = 0

        print("Kayıt durduruldu")
        
        recordedAudioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
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
        view.backgroundColor = .systemGray5
        view.addViews(backButton, newPostLabel, seperatorView, uploadRecordedButton, nextButton)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        newPostLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        nextButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        uploadRecordedButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: nextButton.leftAnchor, paddingTop: 10, paddingRight: 20)
        seperatorView.anchor(top: newPostLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, height: 1)
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        soundView.isHidden = true
        segmentedControl.anchor(top: seperatorView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
    }
    
    private func configureWithExt() {
        view.addViews(videoView, soundView)
        soundView.addViews(audioRecordingStartButtonView, buttonsView, audioRecordingPlayButton, audioRecordingPauseButton)
        audioRecordingStartButtonView.addSubview(audioRecordingStartButton)
        videoView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        soundView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
                
        audioRecordingStartButtonView.anchor(bottom: soundView.safeAreaLayoutGuide.bottomAnchor, centerX: soundView.centerXAnchor, paddingBottom: 10, width: 120, height: 120)
        audioRecordingStartButton.anchor(top: audioRecordingStartButtonView.topAnchor, left: audioRecordingStartButtonView.leftAnchor, right: audioRecordingStartButtonView.rightAnchor, bottom: audioRecordingStartButtonView.bottomAnchor)
        buttonsView.anchor(left: soundView.leftAnchor, right: soundView.rightAnchor, centerY: audioRecordingStartButtonView.centerYAnchor, paddingLeft: 20, paddingRight: 20, height: 60)
        audioRecordingPlayButton.anchor(right: buttonsView.rightAnchor, centerY: buttonsView.centerYAnchor)
        audioRecordingPauseButton.anchor(left: buttonsView.leftAnchor, centerY: buttonsView.centerYAnchor)
        
        audioRecordingStartButtonView.layer.zPosition = 1
        audioRecordingStartButton.layer.zPosition = 1
        buttonsView.isUserInteractionEnabled = false
    }
    
    private func configureTimerLabel() {
        soundView.addSubview(timerView)
        timerView.addViews(timerLabel)
        
        timerView.layer.shadowColor = UIColor.black.cgColor
        timerView.layer.shadowOpacity = 0.4
        timerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        timerView.layer.shadowRadius = 4
        
        timerView.anchor(top: segmentedControl.bottomAnchor, centerX: soundView.centerXAnchor, paddingTop: 20, width: 160, height: 160)
        timerLabel.anchor(centerX: timerView.centerXAnchor, centerY: timerView.centerYAnchor)
    }
    
    func configureWaveformView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        soundView.addSubview(waveformView)
        waveformView.addSubview(scrollView)
        
        waveformContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(waveformContentView)
        
        waveformView.layer.cornerRadius = 10
        waveformView.layer.shadowColor = UIColor.black.cgColor
        waveformView.layer.shadowOpacity = 0.4
        waveformView.layer.shadowOffset = CGSize(width: 0, height: 2)
        waveformView.layer.shadowRadius = 4
        
        waveformView.anchor(top: timerView.bottomAnchor, left: soundView.leftAnchor, right: soundView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 75)
        scrollView.anchor(left: waveformView.leftAnchor, right: waveformView.rightAnchor, centerY: waveformView.centerYAnchor, height: 50)
        waveformContentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, height: 50)
        
        waveformContentView.widthAnchor.constraint(equalToConstant: waveformView.frame.width).isActive = true
        
        let centerLine = UIView()
        centerLine.backgroundColor = .lightGray
        waveformView.addSubview(centerLine)
        centerLine.anchor(left: waveformView.leftAnchor, right: waveformView.rightAnchor, centerY: waveformView.centerYAnchor, height: 1)
    }
    
    func configureAudioPlayerView() {
        soundView.addViews(playView)
        playView.addViews(playButton, forwardButton, backwardButton, audioSlider, optionsButton)
        
        playView.layer.cornerRadius = 10
        playView.layer.shadowColor = UIColor.black.cgColor
        playView.layer.shadowOpacity = 0.4
        playView.layer.shadowOffset = CGSize(width: 0, height: 2)
        playView.layer.shadowRadius = 4
        
        optionsButton.anchor(top: playView.topAnchor, right: playView.rightAnchor, paddingTop: 10, paddingRight: 10)
        playView.anchor(top: timerView.bottomAnchor, left: soundView.leftAnchor, right: soundView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 150)
        playButton.anchor(centerX: playView.centerXAnchor, centerY: playView.centerYAnchor)
        forwardButton.anchor(left: playButton.rightAnchor, centerY: playView.centerYAnchor, paddingLeft: 30)
        backwardButton.anchor(right: playButton.leftAnchor, centerY: playView.centerYAnchor, paddingRight: 30)
        audioSlider.anchor(top: playButton.bottomAnchor, left: playView.leftAnchor, right: playView.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
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

extension NewSongViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAndResetPlayback()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        playButton.setImage(largeImage, for: .normal)
        playButton.tag = 0
        
        print("Ses çalma tamamlandı")
    }
}

extension NewSongViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension NewSongViewController: EditPostViewControllerDelegate {
    func didUpdatePlaybackSpeed(to speed: Float) {
        playbackSpeed = speed
        print("Playback speed updated to: \(speed)")
        
        if let audioPlayer = audioPlayer {
            audioPlayer.enableRate = true
            audioPlayer.rate = speed
        }
    }
    
    func didSkipSilenceSwitchValueChanged(to url: URL) {
        self.recordedAudioURL = url
        print("Sessiz kısımaların atıldığı ses urli: \(self.recordedAudioURL)")
    }
    
    func enhanceAudio(enabled: Bool) {
        if enabled {
            enhanceAudioSettings()
        } else {
            resetAudioSettings()
        }
    }
    
    private func enhanceAudioSettings() {
        audioPlayer?.volume = 1.2
        print("Ses ayarları iyileştirildi")
    }
    
    private func resetAudioSettings() {
        audioPlayer?.volume = 1.0
        
        print("Ses ayarları sıfırlandı.")
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
