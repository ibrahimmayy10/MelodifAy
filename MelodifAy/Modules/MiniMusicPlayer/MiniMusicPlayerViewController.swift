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
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let miniPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()

    let miniMusicNameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .black)
    let miniNameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 14), textColorLabel: .darkGray)
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }

}

extension MiniMusicPlayerViewController {
    func configureUI() {
        view.addSubview(miniPlayerView)
        miniPlayerView.addViews(miniPlayButton, miniMusicNameLabel, miniNameLabel, imageView)
        
        miniPlayerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        miniPlayButton.anchor(top: miniPlayerView.topAnchor, right: miniPlayerView.rightAnchor, bottom: miniPlayerView.bottomAnchor, paddingRight: 10)
        imageView.anchor(top: miniPlayerView.topAnchor, left: miniPlayerView.leftAnchor, bottom: miniPlayerView.bottomAnchor, width: 60)
        miniMusicNameLabel.anchor(top: miniPlayerView.topAnchor, left: imageView.rightAnchor, paddingTop: 10, paddingLeft: 10)
        miniNameLabel.anchor(top: miniMusicNameLabel.bottomAnchor, left: imageView.rightAnchor, paddingLeft: 10)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        miniPlayerView.addGestureRecognizer(tapGesture)
        
        miniPlayButton.addTarget(self, action: #selector(miniPlayButtonTapped), for: .touchUpInside)
    }
    
    @objc func miniPlayButtonTapped() {
        if miniPlayButton.tag == 0 {
            miniPlayButton.tag = 1
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
            miniPlayButton.setImage(largeImage, for: .normal)
            MusicAudioPlayerService.shared.pausePlayback()
        } else {
            miniPlayButton.tag = 0
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
            let largeImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
            miniPlayButton.setImage(largeImage, for: .normal)
            MusicAudioPlayerService.shared.startPlayback()
        }
    }
    
    @objc func miniPlayerTapped() {
        let musicDetailsVC = MusicDetailsViewController()
        musicDetailsVC.modalPresentationStyle = .overFullScreen
        musicDetailsVC.music = MusicAudioPlayerService.shared.music
        present(musicDetailsVC, animated: true, completion: nil)
    }
    
}

extension MiniMusicPlayerViewController: MusicDetailsDelegate {
    func updateMiniPlayer(with music: MusicModel, isPlaying: Bool) {
        MusicAudioPlayerService.shared.musicStatusChangedHandler = { [weak self] song, isPlayingss in
            guard let self = self else { return }
            self.miniMusicNameLabel.text = music.songName
            self.miniNameLabel.text = music.name
            guard let url = URL(string: music.coverPhotoURL) else { return }
            self.imageView.sd_setImage(with: url)
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
            let largePauseImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
            let largePlayImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
            let buttonImage = isPlayingss ? largePauseImage : largePlayImage
            self.miniPlayButton.setImage(buttonImage, for: .normal)
        }
    }
}
