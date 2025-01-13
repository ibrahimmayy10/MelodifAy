//
//  MiniMusicPlayerViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 10.12.2024.
//

import UIKit

class MiniMusicPlayerViewController: UIViewController {
    
    static let shared = MiniMusicPlayerViewController()
    
    let miniPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        return view
    }()
    
    let miniPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()

    let miniMusicNameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .white)
    let miniNameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 14), textColorLabel: .lightGray)
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let audioSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.tintColor = .white
        slider.thumbTintColor = .clear
        slider.isUserInteractionEnabled = false
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupAudioSliderObserver()
        
    }
    
    private func setupAudioSliderObserver() {
        MusicPlayerService.shared.miniProgressHandler = { [weak self] currentTime, duration in
            DispatchQueue.main.async {
                guard !currentTime.isNaN, !duration.isNaN else { return }
                
                self?.audioSlider.maximumValue = Float(duration)
                self?.audioSlider.value = Float(currentTime)
            }
        }
    }

}

extension MiniMusicPlayerViewController {
    func configureUI() {
        view.addSubview(miniPlayerView)
        miniPlayerView.addViews(miniPlayButton, miniMusicNameLabel, miniNameLabel, imageView, audioSlider)
        
        miniPlayerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        audioSlider.anchor(left: miniPlayerView.leftAnchor, right: miniPlayerView.rightAnchor, bottom: miniPlayerView.bottomAnchor, paddingLeft: 5, paddingRight: 5, height: 1)
        miniPlayButton.anchor(top: miniPlayerView.topAnchor, right: miniPlayerView.rightAnchor, bottom: miniPlayerView.bottomAnchor, paddingRight: 10)
        imageView.anchor(top: miniPlayerView.topAnchor, left: miniPlayerView.leftAnchor, bottom: audioSlider.topAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, width: 55)
        miniMusicNameLabel.anchor(top: miniPlayerView.topAnchor, left: imageView.rightAnchor, paddingTop: 10, paddingLeft: 10)
        miniNameLabel.anchor(top: miniMusicNameLabel.bottomAnchor, left: imageView.rightAnchor, paddingLeft: 10)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        miniPlayerView.addGestureRecognizer(tapGesture)
        
        miniPlayButton.addTarget(self, action: #selector(miniPlayButtonTapped), for: .touchUpInside)
    }
    
    @objc func miniPlayButtonTapped() {
        if miniPlayButton.tag == 0 {
            miniPlayButton.tag = 1
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
            miniPlayButton.setImage(largeImage, for: .normal)
            MusicPlayerService.shared.pausePlayback()
        } else {
            miniPlayButton.tag = 0
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
            miniPlayButton.setImage(largeImage, for: .normal)
            MusicPlayerService.shared.startPlayback()
            setupAudioSliderObserver()
        }
    }
    
    @objc func miniPlayerTapped() {
        let musicDetailsVC = MusicDetailsViewController()
        musicDetailsVC.modalPresentationStyle = .overFullScreen
        musicDetailsVC.music = MusicPlayerService.shared.music
        musicDetailsVC.delegate = self
        present(musicDetailsVC, animated: true, completion: nil)
    }
    
}

extension MiniMusicPlayerViewController: MusicDetailsDelegate {
    func updateMiniPlayer(with music: MusicModel, isPlaying: Bool) {
        MusicPlayerService.shared.music = music
        
        self.miniMusicNameLabel.text = music.songName
        self.miniNameLabel.text = music.name
        
        MusicPlayerService.shared.miniProgressHandler = { [weak self] currentTime, duration in
            DispatchQueue.main.async {
                guard !currentTime.isNaN, !duration.isNaN else { return }
                
                self?.audioSlider.maximumValue = Float(duration)
                self?.audioSlider.value = Float(currentTime)
            }
        }
        
        guard let url = URL(string: music.coverPhotoURL) else { return }
        MiniMusicPlayerViewController.shared.imageView.sd_setImage(with: url)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        let largePauseImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
        let largePlayImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        let buttonImage = MusicPlayerService.shared.isPlaying ? largePauseImage : largePlayImage
        self.miniPlayButton.setImage(buttonImage, for: .normal)
    }
}
