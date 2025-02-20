//
//  UserDetailsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 13.12.2024.
//

import UIKit

protocol UserDetailsViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

class UserDetailsViewController: BaseViewController {
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 18), textColorLabel: .white)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    
    private let followingLabel = Labels(textLabel: "Takip", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let followingCountLabel = Labels(textLabel: "200", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let followerLabel = Labels(textLabel: "Takipçi", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let followerCountLabel = Labels(textLabel: "300", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let musicLabel = Labels(textLabel: "Şarkı", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let musicCountLabel = Labels(textLabel: "10", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 45
        imageView.tintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Takip Et", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(UserPostsTableViewCell.self, forCellReuseIdentifier: UserPostsTableViewCell.cellID)
        return tableView
    }()
    
    var user: UserModel?
    private var music: MusicModel?
    private var viewModel: UserDetailsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = UserDetailsViewModel(view: self)
        
        setDelegate()
        configureWithExt()
        setup()
        addTargetButtons()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        followButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    func setDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
    }
    
    @objc func backButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }

}

extension UserDetailsViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
        
        setUserInfo()
        viewModel?.getDataMusic(userID: user?.userID ?? "")
    }
    
    func setUserInfo() {
        guard let user = user else { return }
        
        if !user.imageUrl.isEmpty {
            profileImageView.sd_setImage(with: URL(string: user.imageUrl))
            profileImageView.contentMode = .scaleAspectFill
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
            profileImageView.contentMode = .scaleAspectFit
        }
        
        usernameLabel.text = user.username
        nameLabel.text = user.name + " " + user.surname
    }
    
    func configureWithExt() {
        view.addViews(backButton, profileImageView, musicLabel, musicCountLabel, usernameLabel, followButton, followerLabel, followerCountLabel, followingLabel, followingCountLabel, nameLabel, tableView)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        usernameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        profileImageView.anchor(top: usernameLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 30, paddingLeft: 20, width: 90, height: 90)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        musicLabel.anchor(bottom: musicCountLabel.topAnchor, centerX: musicCountLabel.centerXAnchor, paddingBottom: 5)
        musicCountLabel.anchor(left: profileImageView.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 20)
        
        followerLabel.anchor(bottom: followerCountLabel.topAnchor, centerX: followerCountLabel.centerXAnchor, paddingBottom: 5)
        followerCountLabel.anchor(left: musicLabel.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 50)
        
        followingLabel.anchor(bottom: followingCountLabel.topAnchor, centerX: followingCountLabel.centerXAnchor, paddingBottom: 5)
        followingCountLabel.anchor(left: followerLabel.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 50)
        
        followButton.anchor(top: followerCountLabel.bottomAnchor, left: musicLabel.leftAnchor, right: followingLabel.rightAnchor, paddingTop: 20, height: 30)
        tableView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingTop: 20)
    }
}

extension UserDetailsViewController: UserDetailsViewControllerProtocol {
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.musics.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserPostsTableViewCell.cellID, for: indexPath) as! UserPostsTableViewCell
        let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
        cell.configure(music: music)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
        
        if let cell = tableView.cellForRow(at: indexPath) {
            AnimationHelper.animateCell(cell: cell, in: self.view) {
                let vc = MusicDetailsViewController()
                self.music = music
                vc.music = music
                vc.musics = self.viewModel?.musics ?? []
                vc.delegate = self
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension UserDetailsViewController: MusicDetailsDelegate {
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
