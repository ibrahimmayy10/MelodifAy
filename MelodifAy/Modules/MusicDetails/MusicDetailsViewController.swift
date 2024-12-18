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

protocol MusicDetailsDelegate: AnyObject {
    func updateMiniPlayer(with music: MusicModel, isPlaying: Bool)
}

class MusicDetailsViewController: UIViewController {
    
    private let playLabel = Labels(textLabel: "Şarkı oynatılıyor", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .darkGray)
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let currentTimeLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .black)
    private let remainingTimeLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .black)
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.down", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "ellipsis", withConfiguration: largeConfig)
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
    
    private let restartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "arrow.rectanglepath", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let mixButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "shuffle", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let watchVideoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Videoyu izle", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.isHidden = true
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
    
    private let musicView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        return view
    }()
        
    var music: MusicModel?
    var musics = [MusicModel]()
    
    weak var delegate: MusicDetailsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
        configureWithExt()
        setMusicInfo()
        addTargetButtons()
        playMusic()
        
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let music = music else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if translation.y > 100 {
                delegate?.updateMiniPlayer(with: music, isPlaying: MusicPlayerService.shared.isPlaying)
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func playMusic() {
        guard let music = music else { return }
        let musicUrl = music.musicUrl
        
        configureAudioPlayer()
        
        if let currentMusic = MusicPlayerService.shared.music, currentMusic.musicUrl == musicUrl {
            MusicPlayerService.shared.startPlayback()
            MiniMusicPlayerViewController.shared.miniPlayButton.tag = 0
        } else {
            MusicPlayerService.shared.playMusic(from: musicUrl)
            MusicPlayerService.shared.music = music
        }
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_Clicked), for: .touchUpInside)
        audioSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        backwardButton.addTarget(self, action: #selector(backwardButton_Clicked), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardButton_Clicked), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(restartButton_Clicked), for: .touchUpInside)
        mixButton.addTarget(self, action: #selector(mixButton_Clicked), for: .touchUpInside)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func mixButton_Clicked() {
        if mixButton.tag == 0 {
            mixButton.tag = 1
            mixButton.tintColor = .systemGreen
            
            guard let delegate = delegate as? AccountViewController else { return }
            delegate.playRandomSong()
        } else {
            mixButton.tag = 0
            mixButton.tintColor = .black
        }
    }
    
    @objc func restartButton_Clicked() {
        if restartButton.tag == 0 {
            restartButton.tag = 1
            restartButton.tintColor = .systemGreen
        } else {
            restartButton.tag = 0
            restartButton.tintColor = .black
        }
    }
    
    @objc func forwardButton_Clicked() {
        guard let delegate = delegate as? AccountViewController else { return }
        delegate.playNextSong()
    }
    
    @objc func backwardButton_Clicked() {
        MusicPlayerService.shared.seek(to: 0)
        
        if playButton.tag == 1 {
            self.playButton_Clicked()
        }
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
        watchVideoButton.alpha = 0.3
        playLabel.alpha = 0.3
        coverPhotoImageView.alpha = 0.3
        nameLabel.alpha = 0.3
        songNameLabel.alpha = 0.3
        audioSlider.alpha = 0.3
        forwardButton.alpha = 0.3
        backwardButton.alpha = 0.3
        playButton.alpha = 0.3
        restartButton.alpha = 0.3
        mixButton.alpha = 0.3
        
        loadingIndicator.alpha = 1.0
    }
    
    func isUploadedMusic() {
        loadingIndicator.stopAnimating()
        
        dismissButton.alpha = 1.0
        watchVideoButton.alpha = 1.0
        playLabel.alpha = 1.0
        coverPhotoImageView.alpha = 1.0
        nameLabel.alpha = 1.0
        songNameLabel.alpha = 1.0
        audioSlider.alpha = 1.0
        forwardButton.alpha = 1.0
        backwardButton.alpha = 1.0
        playButton.alpha = 1.0
        restartButton.alpha = 1.0
        mixButton.alpha = 1.0
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func configureAudioPlayer() {
        guard let musicUrl = music?.musicUrl else { return }
        
        MusicPlayerService.shared.progressHandler = { [weak self] currentTime, duration in
            DispatchQueue.main.async {
                guard !currentTime.isNaN, !duration.isNaN else { return }
                
                self?.audioSlider.maximumValue = Float(duration)
                self?.audioSlider.value = Float(currentTime)
                
                self?.currentTimeLabel.text = self?.formatTime(currentTime)
                
                let remainingTime = duration - currentTime
                self?.remainingTimeLabel.text = self?.formatTime(remainingTime)
            }
        }
        
        MusicPlayerService.shared.loadingStateHandler = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.isLoadingMusic()
                } else {
                    self?.isUploadedMusic()
                }
            }
        }
        
        MusicPlayerService.shared.playbackCompletionHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.playButton.tag = 1
                let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
                let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
                self?.playButton.setImage(largeImage, for: .normal)
                
                if self?.restartButton.tag == 1 {
                    MusicPlayerService.shared.seek(to: 0)
                    MusicPlayerService.shared.playMusic(from: musicUrl)
                    self?.playButton.tag = 0
                    let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium, scale: .large)
                    let largeImage = UIImage(systemName: "pause.circle.fill", withConfiguration: largeConfig)
                    self?.playButton.setImage(largeImage, for: .normal)
                }
            }
        }
    }
    
    @objc func dismissButton_Clicked() {
        guard let music = music else { return }
        
        delegate?.updateMiniPlayer(with: music, isPlaying: MusicPlayerService.shared.isPlaying)
        dismiss(animated: true, completion: nil)
    }

}

extension MusicDetailsViewController {
    func setup() {
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        navigationController?.navigationBar.isHidden = true
    }
    
    func setMusicInfo() {
        guard let music = music else { return }
        coverPhotoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
        nameLabel.text = music.name
    }
    
    func configureWithExt() {
        view.addViews(dismissButton, editButton, playLabel, nameLabel, songNameLabel, audioSlider, playButton, backwardButton, forwardButton, loadingIndicator, remainingTimeLabel, currentTimeLabel, musicView, restartButton, mixButton, watchVideoButton)
        musicView.addViews(coverPhotoImageView)
        
        loadingIndicator.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        playLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        editButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        watchVideoButton.anchor(top: playLabel.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 10, width: 150, height: 40)
        
        if music?.musicFileType == "video" {
            watchVideoButton.isHidden = false
            musicView.anchor(top: watchVideoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20, height: view.bounds.size.height * 0.5)
        } else {
            watchVideoButton.isHidden = true
            musicView.anchor(top: playLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: view.bounds.size.height * 0.5)
        }
        
        coverPhotoImageView.anchor(top: musicView.topAnchor, left: musicView.leftAnchor, right: musicView.rightAnchor, bottom: musicView.bottomAnchor)
        songNameLabel.anchor(top: musicView.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: view.leftAnchor, paddingLeft: 20)
        audioSlider.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        currentTimeLabel.anchor(top: audioSlider.bottomAnchor, left: view.leftAnchor, paddingTop: 5, paddingLeft: 20)
        remainingTimeLabel.anchor(top: audioSlider.bottomAnchor, right: view.rightAnchor, paddingTop: 5, paddingRight: 20)
        playButton.anchor(top: audioSlider.bottomAnchor, centerX: view.centerXAnchor, paddingTop: 20)
        backwardButton.anchor(right: playButton.leftAnchor, centerY: playButton.centerYAnchor, paddingRight: 30)
        forwardButton.anchor(left: playButton.rightAnchor, centerY: playButton.centerYAnchor, paddingLeft: 30)
        restartButton.anchor(right: view.rightAnchor, centerY: playButton.centerYAnchor, paddingRight: 20)
        mixButton.anchor(left: view.leftAnchor, centerY: playButton.centerYAnchor, paddingLeft: 20)
        
        view.layoutIfNeeded()
    }
}
