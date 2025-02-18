//
//  AudioRecordingPreviewViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 18.02.2025.
//

import UIKit
import AVFoundation

class AudioRecordingPreviewViewController: UIViewController {
    
    private let previewLabel = Labels(textLabel: "Ses kaydını dinle", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let skipSilenceLabel = Labels(textLabel: "Sessiz Anları Atla", fontLabel: .systemFont(ofSize: 17), textColorLabel: .white)
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let forwardButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "goforward.15", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let backwardButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "gobackward.15", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "square.and.arrow.up", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 17/255, green: 57/255, blue: 113/255, alpha: 1.0)
        button.setTitle("Paylaş", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    let audioSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.tintColor = .gray
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let largeCircleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.setThumbImage(largeCircleImage, for: .normal)
        return slider
    }()
    
    private let speedSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .gray
        slider.isContinuous = true
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let largeCircleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        slider.setThumbImage(largeCircleImage, for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let skipSilenceSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    private let speedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let enhanceRecordingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let turtleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "tortoise")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let rabbitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "hare")
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    private var audioPlayer: AVAudioPlayer?
    var audioURL: URL?
    var progressUpdateTimer: Timer?
    var playbackSpeed: Float = 1.0
    
    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    var audioFile: AVAudioFile?
    
    private let sliderSteps: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    private var tickMarkViews: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        addTargetButtons()
        setupSlider()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for (index, tickView) in tickMarkViews.enumerated() {
            let stepWidth = speedSlider.bounds.width / CGFloat(sliderSteps.count - 1)
            tickView.center.x = speedSlider.frame.minX + CGFloat(index) * stepWidth
        }
    }
    
    func setupSlider() {
        speedSlider.minimumTrackTintColor = .clear
        speedSlider.maximumTrackTintColor = .clear
        
        let trackView = UIView()
        trackView.backgroundColor = .gray
        trackView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(trackView, belowSubview: speedSlider)
        
        trackView.anchor(left: speedSlider.leftAnchor, right: speedSlider.rightAnchor, centerY: speedSlider.centerYAnchor, height: 2)
        
        addTickMarks()
    }
    
    func addTickMarks() {
        let numberOfSteps = sliderSteps.count
        
        for i in 0..<numberOfSteps {
            let tickView = UIView()
            tickView.backgroundColor = .gray
            tickView.translatesAutoresizingMaskIntoConstraints = false
            speedView.addSubview(tickView)
            tickMarkViews.append(tickView)
            
            tickView.anchor(centerY: speedSlider.centerYAnchor, width: 2, height: 15)
        }
    }
    
    @objc private func skipSilenceSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            processAudioWithSkippingSilence()
        } else {
            processAudioWithoutSkippingSilence()
        }
    }
    
    func processAudioWithSkippingSilence() {
        guard let audioURL = audioURL else { return }
        
        let asset = AVAsset(url: audioURL)
        let processor = AudioProcessor(outputURL: audioURL, asset: asset)
        processor.silenceThreshold = -45.0
        processor.minimumSilenceDuration = 0.5
        
        processor.processAudio(skipSilence: true) { processedURL in
            if let processedURL = processedURL {
                print("Sessiz kısımlar atlanarak işlenmiş ses dosyası: \(processedURL)")
                self.didSkipSilenceSwitchValueChanged(to: processedURL)
            } else {
                print("Sessiz kısımları atlama işlemi başarısız oldu.")
            }
        }
    }
    
    func processAudioWithoutSkippingSilence() {
        guard let audioURL = audioURL else { return }
        
        let asset = AVAsset(url: audioURL)
        let processor = AudioProcessor(outputURL: audioURL, asset: asset)
        
        processor.processAudio(skipSilence: false) { processedURL in
            if let processedURL = processedURL {
                print("Normal ses dosyası: \(processedURL)")
                self.didSkipSilenceSwitchValueChanged(to: processedURL)
            } else {
                print("Ses işleme başarısız oldu.")
            }
        }
    }
    
    @objc func speedSliderValueChanged(_ sender: UISlider) {
        let index = Int(round(sender.value))
        sender.value = Float(index)
        let selectedSpeed = sliderSteps[index]
        playbackSpeed = selectedSpeed
        
        UIView.animate(withDuration: 0.1) {
            self.speedSlider.setValue(Float(index), animated: true)
        }
    }
    
    func configureAudioEngine(with url: URL) {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let playerNode = audioPlayerNode else { return }
        
        engine.attach(playerNode)
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            guard let file = audioFile else { return }
            
            engine.connect(playerNode, to: engine.mainMixerNode, format: file.processingFormat)
            
            playerNode.scheduleFile(file, at: nil)
            
            try engine.start()
            
            playerNode.play()
            
        } catch {
            print("Audio engine hatası: \(error.localizedDescription)")
        }
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_Clicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButton_Clicked), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(backwardButton_Clicked), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButton_Clicked), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButton_Clicked), for: .touchUpInside)
        speedSlider.addTarget(self, action: #selector(speedSliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func shareButton_Clicked() {
        dismiss(animated: true) { [weak self] in
            guard let audioURL = self?.audioURL else { return }
            
            let vc = ShareNewPostViewController()
            vc.newPostURL = audioURL
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController as? UINavigationController {
                rootVC.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func playButton_Clicked() {
        guard let audioURL = audioURL else { return }

        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.rate = playbackSpeed
                setupAudioSlider()
            } catch {
                print("Ses dosyası yüklenirken hata oluştu: \(error.localizedDescription)")
                return
            }
        }

        if playButton.tag == 0 {
            audioPlayer?.play()
            startUpdatingSlider()
            updatePlayButtonIcon(isPlaying: true)
            playButton.tag = 1
        } else {
            audioPlayer?.pause()
            stopUpdatingSlider()
            updatePlayButtonIcon(isPlaying: false)
            playButton.tag = 0
        }
    }

    func setupAudioSlider() {
        guard let audioPlayer = audioPlayer else { return }
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = Float(audioPlayer.duration)
        audioSlider.value = 0
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }

    @objc func sliderValueChanged(_ sender: UISlider) {
        audioPlayer?.currentTime = TimeInterval(sender.value)
    }

    func startUpdatingSlider() {
        progressUpdateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }

    func stopUpdatingSlider() {
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = nil
    }

    @objc func updateSlider() {
        guard let audioPlayer = audioPlayer else { return }
        audioSlider.value = Float(audioPlayer.currentTime)
    }

    func updatePlayButtonIcon(isPlaying: Bool) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let largeImage = UIImage(systemName: imageName, withConfiguration: largeConfig)
        playButton.setImage(largeImage, for: .normal)
    }
    
    func seek(to time: Float) {
        audioPlayer?.currentTime = TimeInterval(time)
    }
    
    @objc func forwardButton_Clicked() {
        guard let player = audioPlayer else { return }
        player.currentTime += 15
    }
    
    @objc func backwardButton_Clicked() {
        guard let player = audioPlayer else { return }
        player.currentTime -= 15
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }
    
    @objc func sendButton_Clicked() {
        let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }

}

extension AudioRecordingPreviewViewController {
    func configureWithExt() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        navigationController?.navigationBar.isHidden = true
        
        speedSlider.minimumValue = 0
        speedSlider.maximumValue = Float(sliderSteps.count - 1)
        speedSlider.value = 2
        
        view.addViews(previewLabel, dismissButton, speedView, playButton, forwardButton, backwardButton, audioSlider, sendButton, shareButton)
        speedView.addViews(speedSlider, skipSilenceSwitch, skipSilenceLabel, seperatorView, turtleImageView, rabbitImageView)
        
        previewLabel.anchor(top: view.topAnchor, centerX: view.centerXAnchor, paddingTop: 20)
        dismissButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 30)
        sendButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 30)
        playButton.anchor(top: previewLabel.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 30)
        forwardButton.anchor(left: playButton.rightAnchor, centerY: playButton.centerYAnchor, paddingLeft: 30)
        backwardButton.anchor(right: playButton.leftAnchor, centerY: playButton.centerYAnchor, paddingRight: 30)
        audioSlider.anchor(top: playButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        speedView.anchor(top: audioSlider.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 15, paddingRight: 15, height: 105)
        turtleImageView.anchor(top: speedView.topAnchor, left: speedView.leftAnchor, paddingTop: 15, paddingLeft: 10)
        rabbitImageView.anchor(top: speedView.topAnchor, right: speedView.rightAnchor, paddingTop: 15, paddingRight: 10)
        speedSlider.anchor(top: speedView.topAnchor, left: turtleImageView.rightAnchor, right: rabbitImageView.leftAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        seperatorView.anchor(top: speedSlider.bottomAnchor, left: speedView.leftAnchor, right: speedView.rightAnchor, paddingTop: 15, height: 1)
        skipSilenceLabel.anchor(top: seperatorView.bottomAnchor, left: speedView.leftAnchor, paddingTop: 15, paddingLeft: 10)
        skipSilenceSwitch.anchor(top: seperatorView.bottomAnchor, right: speedView.rightAnchor, paddingTop: 10, paddingRight: 10)
        shareButton.anchor(top: skipSilenceSwitch.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingRight: 30, height: 50)
    }
}

extension AudioRecordingPreviewViewController: EditPostViewControllerDelegate {
    func didUpdatePlaybackSpeed(to speed: Float) {
        playbackSpeed = speed
        print("Playback speed updated to: \(speed)")
        
        if let audioPlayer = audioPlayer {
            audioPlayer.enableRate = true
            audioPlayer.rate = speed
        }
    }
    
    func didSkipSilenceSwitchValueChanged(to url: URL) {
        self.audioURL = url
        print("Sessiz kısımaların atıldığı ses urli: \(self.audioURL)")
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

extension AudioRecordingPreviewViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        playButton.setImage(largeImage, for: .normal)
        playButton.tag = 0
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        print("Ses çalma tamamlandı")
    }
}

extension AudioRecordingPreviewViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
