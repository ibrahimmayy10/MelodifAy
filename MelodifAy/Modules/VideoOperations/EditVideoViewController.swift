//
//  EditVideoViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 24.10.2024.
//

import UIKit
import AVFoundation

class EditVideoViewController: UIViewController {
    
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
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "pause.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        
        button.tintColor = .white
        button.alpha = 0
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "goforward.10", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    private let backwardButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "gobackward.10", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    private let nextButton: UIButton = {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("İleri", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "arrow.forward"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 20
        
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: button.bounds.size.width - 60, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: button.bounds.size.width - 60)
        
        return button
    }()
    
    private let backgroundOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    private let videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.alpha = 0
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.tintColor = .white
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let largeCircleImage = UIImage(systemName: "circle.fill", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        slider.setThumbImage(largeCircleImage, for: .normal)
        return slider
    }()
    
    var videoURL: URL?
    private let videoPlayer = AVPlayer()
    private var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTopBar()
        addTargetButtons()
        playVideo()
        setupSlider()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)
                
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    @objc func videoDidFinishPlaying() {
        print("Video oynatması tamamlandı")
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
        playButton.setImage(largeImage, for: .normal)
        videoSlider.value = 0.0
        
        videoPlayer.seek(to: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideo()
    }
    
    func addTargetButtons() {
        setupGestureRecognizers()
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_Clicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButton_Clicked), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(backwardButton_Clicked), for: .touchUpInside)
    }
    
    @objc func dismissButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func playVideo() {
        guard let videoURL = videoURL else { return }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        playerLayer.removeFromSuperlayer()
        
        let playerItem = AVPlayerItem(url: videoURL)
        videoPlayer.replaceCurrentItem(with: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.videoGravity = .resizeAspect
        
        playerLayer.frame = view.bounds
        view.layer.insertSublayer(playerLayer, at: 0)
        
        videoPlayer.play()
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleScreenTap() {
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = self.playButton.alpha == 0 ? 1 : 0
            self.forwardButton.alpha = self.forwardButton.alpha == 0 ? 1 : 0
            self.backwardButton.alpha = self.backwardButton.alpha == 0 ? 1 : 0
            self.videoSlider.alpha = self.videoSlider.alpha == 0 ? 1 : 0
            self.backgroundOverlay.alpha = self.backgroundOverlay.alpha == 0 ? 1 : 0
        }
    }
    
    @objc func playButton_Clicked() {
        if videoPlayer.timeControlStatus == .paused {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "pause.circle.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            
            videoPlayer.play()
        } else {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
            let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            
            videoPlayer.pause()
        }
    }
    
    @objc func forwardButton_Clicked() {
        let currentTime = videoPlayer.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10.0, preferredTimescale: 1))
        videoPlayer.seek(to: newTime)
    }
    
    @objc func backwardButton_Clicked() {
        let currentTime = videoPlayer.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: -10.0, preferredTimescale: 1))
        videoPlayer.seek(to: newTime)
    }
    
    private func setupSlider() {
        videoSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        videoPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self, let duration = self.videoPlayer.currentItem?.duration.seconds, duration > 0 else { return }
            self.videoSlider.value = Float(time.seconds / duration)
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let duration = videoPlayer.currentItem?.duration.seconds else { return }
        let newTime = CMTime(seconds: Double(sender.value) * duration, preferredTimescale: 600)
        videoPlayer.seek(to: newTime)
    }

}

extension EditVideoViewController {
    func configureTopBar() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        view.addViews(dismissButton, playButton, forwardButton, backwardButton, videoSlider, backgroundOverlay, nextButton)
        
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        playButton.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        backwardButton.anchor(right: playButton.leftAnchor, centerY: view.centerYAnchor, paddingRight: 30)
        forwardButton.anchor(left: playButton.rightAnchor, centerY: view.centerYAnchor, paddingLeft: 30)
        videoSlider.anchor(top: playButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        backgroundOverlay.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        nextButton.anchor(right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingRight: 20, paddingBottom: 20, width: 100, height: 40)
        
        playButton.layer.zPosition = 1
        forwardButton.layer.zPosition = 1
        backwardButton.layer.zPosition = 1
        videoSlider.layer.zPosition = 1
        backgroundOverlay.isUserInteractionEnabled = false
    }
}
