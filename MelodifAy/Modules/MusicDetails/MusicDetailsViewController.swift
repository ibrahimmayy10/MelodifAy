//
//  MusicDetailsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.11.2024.
//

import UIKit
import AVFoundation
import AVKit
import Firebase

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
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
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
                
        isLoadingMusic()
        configureAudioPlayer()
        setup()
        configureWithExt()
        setMusicInfo()
        addTargetButtons()
        playMusic()
        
    }
    
    func playMusic() {
        guard let musicUrl = music?.musicUrl else { return }
        
        fetchFileType(for: musicUrl) { [weak self] contentType in
            DispatchQueue.main.async {
                if let contentType = contentType, contentType.contains("video") {
                    self?.playVideo(from: musicUrl)
                } else {
                    self?.configureAudioPlayer()
                    MusicPlayerService.shared.playMusic(from: musicUrl)
                }
            }
        }
    }
    
    func playVideo(from url: String) {
        guard let videoURL = URL(string: url) else { return }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem,
                                               queue: .main) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    func fetchFileType(for url: String, completion: @escaping (String?) -> Void) {
        let storageRef = Storage.storage(url: "gs://melodifay-15da7.firebasestorage.app").reference(forURL: url)
        
        storageRef.getMetadata { metadata, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(nil)
            } else {
                completion(metadata?.contentType)
            }
        }
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_Clicked), for: .touchUpInside)
        audioSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    @objc func sliderChanged() {
        MusicPlayerService.shared.seek(to: Double(audioSlider.value))
    }
    
    @objc func playButton_Clicked() {        
        if playButton.tag == 0 {
            playButton.tag = 1
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            
            MusicPlayerService.shared.pausePlayback()
        } else {
            playButton.tag = 0
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "pause.circle.fill", withConfiguration: largeConfig)
            playButton.setImage(largeImage, for: .normal)
            
            MusicPlayerService.shared.startPlayback()
        }
    }
    
    func isLoadingMusic() {
        loadingIndicator.startAnimating()
        
        dismissButton.alpha = 0.3
        playLabel.alpha = 0.3
        coverPhotoImageView.alpha = 0.3
        nameLabel.alpha = 0.3
        songNameLabel.alpha = 0.3
        audioSlider.alpha = 0.3
        forwardButton.alpha = 0.3
        backwardButton.alpha = 0.3
        playButton.alpha = 0.3
        
        loadingIndicator.alpha = 1.0
    }
    
    func configureAudioPlayer() {
        MusicPlayerService.shared.progressHandler = { [weak self] currentTime, duration in
            DispatchQueue.main.async {
                self?.audioSlider.maximumValue = Float(duration)
                self?.audioSlider.value = Float(currentTime)
            }
        }
        
        MusicPlayerService.shared.loadingStateHandler = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.isLoadingMusic()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    
                    self?.dismissButton.alpha = 1.0
                    self?.playLabel.alpha = 1.0
                    self?.coverPhotoImageView.alpha = 1.0
                    self?.nameLabel.alpha = 1.0
                    self?.songNameLabel.alpha = 1.0
                    self?.audioSlider.alpha = 1.0
                    self?.forwardButton.alpha = 1.0
                    self?.backwardButton.alpha = 1.0
                    self?.playButton.alpha = 1.0
                }
            }
        }
        
        MusicPlayerService.shared.playbackCompletionHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.playButton.tag = 1
                let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
                let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
                self?.playButton.setImage(largeImage, for: .normal)
            }
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
