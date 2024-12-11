//
//  BaseViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 11.12.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var miniMusicPlayerViewController: MiniMusicPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiniMusicPlayer()
        
        MusicAudioPlayerService.shared.musicStatusChangedHandler = { [weak self] music, isPlaying in
            guard let music = music else {
                self?.hideMiniMusicPlayer()
                return
            }
            
            if isPlaying {
                self?.showMiniMusicPlayer(with: music)
            } else {
                self?.showMiniMusicPlayer(with: music)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(miniMusicPlayerViewController?.view ?? UIView())
    }
    
    private func setupMiniMusicPlayer() {
        let miniPlayerVC = MiniMusicPlayerViewController.shared
        addChild(miniPlayerVC)
        view.addSubview(miniPlayerVC.view)
        miniPlayerVC.didMove(toParent: self)
        
        miniPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerVC.view.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 60, height: 60)
        
        miniPlayerVC.view.isHidden = true
        self.miniMusicPlayerViewController = miniPlayerVC
    }
    
    func showMiniMusicPlayer(with music: MusicModel) {
        miniMusicPlayerViewController?.view.isHidden = false
        miniMusicPlayerViewController?.updateMiniPlayer(with: music, isPlaying: true)
    }
    
    func hideMiniMusicPlayer() {
        miniMusicPlayerViewController?.view.isHidden = true
    }
    
}
