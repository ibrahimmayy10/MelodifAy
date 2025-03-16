//
//  PlaylistMusicsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 14.03.2025.
//

import UIKit
import Lottie

protocol PlaylistMusicsViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

class PlaylistMusicsViewController: BaseViewController {
    
    private let topLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    
    private let topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1.0)
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(UserPlaylistTableViewCell.self, forCellReuseIdentifier: UserPlaylistTableViewCell.cellID)
        return tableView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    var text = String()
    var userID = String()
    var musics = [MusicModel]()
    var users = [UserModel]()
    var musicIDs = [String]()
    
    private var viewModel: PlaylistMusicsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMiniPlayerBottomPadding(10)
        
        viewModel = PlaylistMusicsViewModel(view: self)
        
        setup()
        configureTopBar()
        configureWithExt()
        configureAnimationView()
        addTargetButtons()
        setDelegate()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
    }
    
    @objc func dismissButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension PlaylistMusicsViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
        
        topLabel.text = text
        
        if !musics.isEmpty {
            toggleUIElementsVisibility(isHidden: false)
            self.animationView.stop()
            self.animationView.isHidden = true
        } else {
            toggleUIElementsVisibility(isHidden: true)
            getData()
        }
    }
    
    func getData() {
        animationView.play()
        
        if musicIDs.isEmpty {
            if text == "Takipçiler" {
                viewModel?.getDataFollowerUsers(userID: userID, completion: { success in
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: !success)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                })
            } else if text == "Takip edilenler" {
                viewModel?.getDataFollowingUsers(userID: userID, completion: { success in
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: !success)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                })
            }
        } else {
            viewModel?.getDataPlaylistMusics(musicIDs: musicIDs, completion: { success in
                DispatchQueue.main.async {
                    self.toggleUIElementsVisibility(isHidden: !success)
                    self.animationView.stop()
                    self.animationView.isHidden = true
                }
            })
        }
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        tableView.isHidden = isHidden
    }
    
    func configureTopBar() {
        view.addViews(topBarView)
        topBarView.addViews(topLabel, dismissButton)
        
        topBarView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: view.bounds.size.height * 0.12)
        
        topLabel.anchor(bottom: topBarView.bottomAnchor, centerX: topBarView.centerXAnchor, paddingBottom: 15)
        dismissButton.anchor(left: topBarView.leftAnchor, bottom: topBarView.bottomAnchor, paddingLeft: 20, paddingBottom: 15)
    }
    
    func configureWithExt() {
        view.addViews(tableView)
        
        tableView.anchor(top: topBarView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
}

extension PlaylistMusicsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !musics.isEmpty {
            return musics.count
        } else if let followers = viewModel?.followers, text == "Takipçiler" {
            return followers.count
        } else if let following = viewModel?.following, text == "Takip edilenler" {
            return following.count
        } else {
            return viewModel?.musics.count ?? 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !musics.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaylistTableViewCell.cellID, for: indexPath) as! UserPlaylistTableViewCell
            let music = musics[indexPath.row]
            cell.configure(music: music)
            return cell
        } else if let followers = viewModel?.followers, text == "Takipçiler" {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaylistTableViewCell.cellID, for: indexPath) as! UserPlaylistTableViewCell
            let follower = followers[indexPath.row]
            cell.configure(user: follower)
            return cell
        } else if let following = viewModel?.following, text == "Takip edilenler" {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaylistTableViewCell.cellID, for: indexPath) as! UserPlaylistTableViewCell
            let follow = following[indexPath.row]
            cell.configure(user: follow)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaylistTableViewCell.cellID, for: indexPath) as! UserPlaylistTableViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            cell.configure(music: music)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !musics.isEmpty {
            let music = musics[indexPath.row]
            
            if let cell = tableView.cellForRow(at: indexPath) {
                AnimationHelper.animateCell(cell: cell, in: self.view) {
                    let vc = MusicDetailsViewController()
                    vc.music = music
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                }
            }
        } else {
            let music = self.viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            if let cell = tableView.cellForRow(at: indexPath) {
                AnimationHelper.animateCell(cell: cell, in: self.view) {
                    let vc = MusicDetailsViewController()
                    vc.music = music
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension PlaylistMusicsViewController: PlaylistMusicsViewControllerProtocol {
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension PlaylistMusicsViewController: MusicDetailsDelegate {
    func updateMiniPlayer(with music: MusicModel, isPlaying: Bool) {
        MusicPlayerService.shared.music = music
        
        MiniMusicPlayerViewController.shared.miniMusicNameLabel.text = music.songName
        MiniMusicPlayerViewController.shared.miniNameLabel.text = music.name
        
        guard let url = URL(string: music.coverPhotoURL) else { return }
        MiniMusicPlayerViewController.shared.imageView.sd_setImage(with: url)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        let largePauseImage = UIImage(systemName: "pause.fill", withConfiguration: largeConfig)
        let largePlayImage = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        let buttonImage = MusicPlayerService.shared.isPlaying ? largePauseImage : largePlayImage
        MiniMusicPlayerViewController.shared.miniPlayButton.setImage(buttonImage, for: .normal)
    }
}
