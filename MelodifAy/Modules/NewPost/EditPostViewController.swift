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
}

class EditPostViewController: UIViewController {
    
    private let optionsLabel = Labels(textLabel: "Seçenekler", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let skipSilenceLabel = Labels(textLabel: "Sessiz Anları Atla", fontLabel: .systemFont(ofSize: 17), textColorLabel: .black)
    private let enhanceRecordingLabel = Labels(textLabel: "Kayıt İyileştirme", fontLabel: .systemFont(ofSize: 17), textColorLabel: .black)
    
    private let speedSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .gray
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.value = 2
        slider.isContinuous = true
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
        
        guard let audioURL = audioURL else { return }
        configureAudioEngine(with: audioURL)
        
        addTickMarks()
        
    }
    
    @objc func dismissButtonTapped() {
        let selectedSpeed = sliderSteps[Int(round(speedSlider.value))]
        
        delegate?.didUpdatePlaybackSpeed(to: selectedSpeed)
        
        dismiss(animated: true, completion: nil)
    }
    
    func addTickMarks() {
        let numberOfSteps = sliderSteps.count
        let sliderWidth = UIScreen.main.bounds.width - 40
        
        for i in 0..<numberOfSteps {
            let tickView = UIView()
            tickView.backgroundColor = .gray
            tickView.translatesAutoresizingMaskIntoConstraints = false
            tickView.widthAnchor.constraint(equalToConstant: 2).isActive = true
            tickView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            view.addSubview(tickView)
            tickMarkViews.append(tickView)
            
            let xPosition = CGFloat(i) * (sliderWidth / CGFloat(numberOfSteps - 1)) + 21
            tickView.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: xPosition).isActive = true
            tickView.centerYAnchor.constraint(equalTo: speedSlider.centerYAnchor).isActive = true
        }
    }
    
    func addTarget() {
        speedSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let index = Int(round(sender.value))
        let selectedSpeed = sliderSteps[index]
        
        sender.value = Float(index)
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
    
    func saveModifiedAudio(completion: @escaping (URL?) -> Void) {
        guard let engine = audioEngine,
              let playerNode = audioPlayerNode,
              let file = audioFile else {
            completion(nil)
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("modified_audio.m4a")
        
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
        
        guard let outputFile = try? AVAudioFile(forWriting: outputURL, settings: outputFormat!.settings) else {
            completion(nil)
            return
        }
        
        engine.stop()
        playerNode.stop()
        
        playerNode.scheduleFile(file, at: nil)
        playerNode.rate = playbackSpeed
        
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 4096, format: outputFormat) { (buffer, time) in
            try? outputFile.write(from: buffer)
        }
        
        playerNode.play()
        engine.prepare()
        
        do {
            try engine.start()
        } catch {
            print("Engine başlatma hatası: \(error)")
            completion(nil)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(file.length) / file.fileFormat.sampleRate / Double(playbackSpeed)) {
            engine.mainMixerNode.removeTap(onBus: 0)
            engine.stop()
            playerNode.stop()
            completion(outputURL)
        }
    }
}

extension EditPostViewController {
    func configureWithExt() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        speedSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        view.addViews(optionsLabel, speedSlider, skipSilenceSwitch, skipSilenceLabel, enhanceRecordingSwitch, enhanceRecordingLabel, dismissButton)
        
        optionsLabel.anchor(top: view.topAnchor, centerX: view.centerXAnchor, paddingTop: 20)
        dismissButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 20)
        speedSlider.anchor(top: optionsLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        skipSilenceLabel.anchor(top: speedSlider.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        skipSilenceSwitch.anchor(top: speedSlider.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 20)
        enhanceRecordingLabel.anchor(top: skipSilenceLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        enhanceRecordingSwitch.anchor(top: skipSilenceSwitch.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingRight: 20)
    }
}
