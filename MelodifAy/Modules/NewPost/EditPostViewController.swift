//
//  EditPostViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 17.10.2024.
//

import UIKit
import AVFoundation

protocol EditPostViewControllerDelegate: AnyObject {
    func didUpdatePlaybackSpeed(to speed: Float)
    func didSkipSilenceSwitchValueChanged(to url: URL)
    func enhanceAudio(enabled: Bool)
}

class EditPostViewController: UIViewController {
    
    private let optionsLabel = Labels(textLabel: "Seçenekler", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let skipSilenceLabel = Labels(textLabel: "Sessiz Anları Atla", fontLabel: .systemFont(ofSize: 17), textColorLabel: .black)
    private let enhanceRecordingLabel = Labels(textLabel: "Kayıt İyileştirme", fontLabel: .systemFont(ofSize: 17), textColorLabel: .black)
    private let speedLabel = Labels(textLabel: "OYNATMA HIZI", fontLabel: .systemFont(ofSize: 14), textColorLabel: .darkGray)
    
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
    
    private let enhanceRecordingSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    let skipSilenceSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let speedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let enhanceRecordingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
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
    
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    var audioFile: AVAudioFile?
    var playbackSpeed: Float = 1.0
    var audioURL: URL?
    
    private let sliderSteps: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    private var tickMarkViews: [UIView] = []
    
    weak var delegate: EditPostViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        addTarget()
        setupSlider()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for (index, tickView) in tickMarkViews.enumerated() {
            let stepWidth = speedSlider.bounds.width / CGFloat(sliderSteps.count - 1)
            tickView.center.x = speedSlider.frame.minX + CGFloat(index) * stepWidth
        }
    }
    
    @objc func dismissButtonTapped() {
        let selectedSpeed = sliderSteps[Int(round(speedSlider.value))]
        
        delegate?.didUpdatePlaybackSpeed(to: selectedSpeed)
        
        dismiss(animated: true, completion: nil)
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
    
    func addTarget() {
        speedSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        skipSilenceSwitch.addTarget(self, action: #selector(skipSilenceSwitchValueChanged(_:)), for: .valueChanged)
        enhanceRecordingSwitch.addTarget(self, action: #selector(enhanceRecordingSwitchValueChanged(_:)), for: .valueChanged)
        speedSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func enhanceRecordingSwitchValueChanged(_ sender: UISwitch) {
        delegate?.enhanceAudio(enabled: sender.isOn)
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
                self.delegate?.didSkipSilenceSwitchValueChanged(to: processedURL)
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
                self.delegate?.didSkipSilenceSwitchValueChanged(to: processedURL)
            } else {
                print("Ses işleme başarısız oldu.")
            }
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
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
}

extension EditPostViewController {
    func configureWithExt() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        speedSlider.minimumValue = 0
        speedSlider.maximumValue = Float(sliderSteps.count - 1)
        speedSlider.value = 2
        
        view.addViews(optionsLabel, speedView, speedLabel, enhanceRecordingView, dismissButton)
        speedView.addViews(speedSlider, skipSilenceSwitch, skipSilenceLabel, seperatorView, turtleImageView, rabbitImageView)
        enhanceRecordingView.addViews(enhanceRecordingSwitch, enhanceRecordingLabel)
        
        optionsLabel.anchor(top: view.topAnchor, centerX: view.centerXAnchor, paddingTop: 20)
        dismissButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 20)
        speedLabel.anchor(top: optionsLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 30)
        speedView.anchor(top: speedLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 105)
        turtleImageView.anchor(top: speedView.topAnchor, left: speedView.leftAnchor, paddingTop: 15, paddingLeft: 10)
        rabbitImageView.anchor(top: speedView.topAnchor, right: speedView.rightAnchor, paddingTop: 15, paddingRight: 10)
        speedSlider.anchor(top: speedView.topAnchor, left: turtleImageView.rightAnchor, right: rabbitImageView.leftAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        seperatorView.anchor(top: speedSlider.bottomAnchor, left: speedView.leftAnchor, right: speedView.rightAnchor, paddingTop: 15, height: 1)
        skipSilenceLabel.anchor(top: seperatorView.bottomAnchor, left: speedView.leftAnchor, paddingTop: 15, paddingLeft: 10)
        skipSilenceSwitch.anchor(top: seperatorView.bottomAnchor, right: speedView.rightAnchor, paddingTop: 10, paddingRight: 10)
        enhanceRecordingView.anchor(top: speedView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 50)
        enhanceRecordingLabel.anchor(left: enhanceRecordingView.leftAnchor, centerY: enhanceRecordingView.centerYAnchor, paddingLeft: 10)
        enhanceRecordingSwitch.anchor(right: enhanceRecordingView.rightAnchor, centerY: enhanceRecordingView.centerYAnchor, paddingRight: 10)
    }
}
