//
//  BaseViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 11.12.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var miniMusicPlayerViewController: MiniMusicPlayerViewController?
    
    private var miniPlayerBottomConstraint: NSLayoutConstraint?
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiniMusicPlayer()
        
        MusicPlayerService.shared.musicStatusChangedHandler = { [weak self] music, isPlaying in
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerVisibilityChanged),
                                               name: .miniPlayerVisibilityChanged,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .miniPlayerVisibilityChanged, object: nil)
    }
        
    @objc func miniPlayerVisibilityChanged(_ notification: Notification) {
        guard let isVisible = notification.userInfo?["isVisible"] as? Bool else { return }
        updateMiniPlayerConstraints(isVisible: isVisible)
    }
    
    func updateMiniPlayerConstraints(isVisible: Bool) {
        tableViewBottomConstraint?.constant = isVisible ? -65 : 0
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
        
        miniPlayerVC.view.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 5, paddingRight: 5, height: 65)
        
        miniPlayerBottomConstraint = miniPlayerVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        miniPlayerBottomConstraint?.isActive = true
        
        miniPlayerVC.view.clipsToBounds = true
        miniPlayerVC.view.layer.cornerRadius = 10
        
        miniPlayerVC.view.isHidden = true
        self.miniMusicPlayerViewController = miniPlayerVC
    }
    
    func setMiniPlayerBottomPadding(_ padding: CGFloat) {
        miniPlayerBottomConstraint?.constant = -padding
        view.layoutIfNeeded()
    }
    
    func showMiniMusicPlayer(with music: MusicModel) {
        miniMusicPlayerViewController?.showMiniPlayer()
        miniMusicPlayerViewController?.updateMiniPlayer(with: music, isPlaying: true)
    }

    func hideMiniMusicPlayer() {
        miniMusicPlayerViewController?.hideMiniPlayer()
    }
    
}

extension Notification.Name {
    static let miniPlayerVisibilityChanged = Notification.Name("MiniPlayerVisibilityChanged")
}
