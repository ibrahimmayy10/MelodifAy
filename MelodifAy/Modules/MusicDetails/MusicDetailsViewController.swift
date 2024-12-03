//
//  MusicDetailsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.11.2024.
//

import UIKit
import AVFoundation

class MusicDetailsViewController: UIViewController {
    
    private let playLabel = Labels(textLabel: "Şarkı oynatılıyor", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .darkGray)
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.down", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "pause.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "forward.end.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let backwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "backward.end.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let audioSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.tintColor = .gray
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let largeCircleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        slider.setThumbImage(largeCircleImage, for: .normal)
        return slider
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var playbackTimer: Timer?
    
    var music: MusicModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureWithExt()
        setMusicInfo()
        addTargetButtons()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopPlaybackTimer()
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        player?.pause()
        player = nil
        audioSlider.value = 0
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_Clicked), for: .touchUpInside)
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let player = player else { return }
        let seconds = Int64(sender.value)
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
    }
    
    @objc func playButton_Clicked() {
        guard let player = player else { return }
        
        if playButton.tag == 0 {
            playButton.tag = 1
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            
            player.pause()
        } else {
            playButton.tag = 0
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "pause.circle.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            
            player.play()
        }
    }
    
    func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player, let currentItem = player.currentItem else { return }
            let currentTime = CMTimeGetSeconds(player.currentTime())
            self.audioSlider.value = Float(currentTime)
            
            if CMTimeGetSeconds(currentItem.duration) == currentTime {
                self.playButton.tag = 0
                let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium, scale: .large)
                let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
                self.playButton.setImage(largeImage, for: .normal)
            }
        }
    }

    func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func addPeriodicTimeObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            self.audioSlider.value = Float(currentTime)
        }
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }

}

extension MusicDetailsViewController {
    func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
    }
    
    func setMusicInfo() {
        guard let music = music else { return }
        coverPhotoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
        nameLabel.text = music.name
        
        loadingIndicator.startAnimating()
        self.dismissButton.isHidden = true
        self.playLabel.isHidden = true
        self.coverPhotoImageView.isHidden = true
        self.nameLabel.isHidden = true
        self.songNameLabel.isHidden = true
        self.audioSlider.isHidden = true
        self.forwardButton.isHidden = true
        self.backwardButton.isHidden = true
        self.playButton.isHidden = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let url = URL(string: music.musicUrl) else { return }
            let playerItem = AVPlayerItem(url: url)
            
            DispatchQueue.main.async {
                self.playerItem = playerItem
                self.player = AVPlayer(playerItem: playerItem)
                
                let duration = playerItem.asset.duration
                let seconds = CMTimeGetSeconds(duration)
                self.audioSlider.maximumValue = Float(seconds)
                self.audioSlider.value = 0
                
                
                self.addPeriodicTimeObserver()
                self.startPlaybackTimer()
                self.player?.play()
                self.loadingIndicator.stopAnimating()
                
                self.dismissButton.isHidden = false
                self.playLabel.isHidden = false
                self.coverPhotoImageView.isHidden = false
                self.nameLabel.isHidden = false
                self.songNameLabel.isHidden = false
                self.audioSlider.isHidden = false
                self.forwardButton.isHidden = false
                self.backwardButton.isHidden = false
                self.playButton.isHidden = false
            }
        }
    }
    
    func configureWithExt() {
        view.addViews(dismissButton, playLabel, coverPhotoImageView, nameLabel, songNameLabel, audioSlider, playButton, backwardButton, forwardButton, loadingIndicator)
        
        loadingIndicator.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        playLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        coverPhotoImageView.anchor(top: playLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 370)
        songNameLabel.anchor(top: coverPhotoImageView.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: view.leftAnchor, paddingLeft: 20)
        audioSlider.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        playButton.anchor(top: audioSlider.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 20)
        backwardButton.anchor(right: playButton.leftAnchor, centerY: playButton.centerYAnchor, paddingRight: 30)
        forwardButton.anchor(left: playButton.rightAnchor, centerY: playButton.centerYAnchor, paddingLeft: 30)
    }
}
