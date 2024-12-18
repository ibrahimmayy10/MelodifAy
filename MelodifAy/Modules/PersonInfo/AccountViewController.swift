//
//  AccountViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Firebase
import SDWebImage

protocol AccountViewControllerProtocol: AnyObject {
    func setUserInfo(user: UserModel)
    func reloadDataTableView()
}

class AccountViewController: BaseViewController {
    
    private let bottomBar = BottomBarView()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 17), textColorLabel: .darkGray)
    
    private let followingLabel = Labels(textLabel: "Takip", fontLabel: .systemFont(ofSize: 14), textColorLabel: .black)
    private let followingCountLabel = Labels(textLabel: "200", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .black)
    private let followerLabel = Labels(textLabel: "Takipçi", fontLabel: .systemFont(ofSize: 14), textColorLabel: .black)
    private let followerCountLabel = Labels(textLabel: "300", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .black)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Düzenle", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 10
        return button
    }()
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Paylaşımlarım", "Kitaplığım"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let myPostsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let myLikesView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let myPostsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.register(MyPostsTableViewCell.self, forCellReuseIdentifier: MyPostsTableViewCell.cellID)
        return tableView
    }()
    
    private var viewModel: AccountViewModel?
    private var music: MusicModel?
    private var name = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AccountViewModel(view: self)
        
        configureBottomBar()
        setup()
        configureWithExt()
        configureSegmentedControl()
        configureMyPostsView()
        addTargetButtons()
        setDelegate()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func setDelegate() {
        myPostsTableView.delegate = self
        myPostsTableView.dataSource = self
        
        myPostsTableView.separatorStyle = .none
    }
    
    func addTargetButtons() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        editProfileButton.addTarget(self, action: #selector(editProfileButton_Clicked), for: .touchUpInside)
    }
    
    @objc func editProfileButton_Clicked() {
        do {
            try Auth.auth().signOut()
            navigationController?.pushViewController(SignInViewController(), animated: true)
        } catch {
            print("lfdösşfş")
        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            myPostsView.isHidden = false
            myLikesView.isHidden = true
        } else {
            myPostsView.isHidden = true
            myLikesView.isHidden = false
        }
    }

}

extension AccountViewController {
    func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        viewModel?.getDataUserInfo()
        viewModel?.getDataMusicInfo()
    }
    
    func configureBottomBar() {
        let accountViewModel = BottomBarViewModel(selectedTab: .account(isSelected: true))
        bottomBar.viewModel = accountViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = .white
        
        view.addViews(bottomBar, seperatorView)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
        seperatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, height: 1)
    }
    
    func configureWithExt() {
        view.addViews(profileImageView, nameLabel, usernameLabel, followerLabel, followerCountLabel, followingLabel, followingCountLabel, editProfileButton)
        
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 70, height: 70)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: profileImageView.rightAnchor, paddingTop: 30, paddingLeft: 15)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 5, paddingLeft: 15)
        editProfileButton.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 120, height: 30)
        followerLabel.anchor(top: profileImageView.bottomAnchor, left: editProfileButton.rightAnchor, paddingTop: 15, paddingLeft: 20)
        followerCountLabel.anchor(top: followerLabel.bottomAnchor, centerX: followerLabel.centerXAnchor, paddingTop: 5)
        followingLabel.anchor(top: profileImageView.bottomAnchor, left: followerLabel.rightAnchor, paddingTop: 15, paddingLeft: 25)
        followingCountLabel.anchor(top: followingLabel.bottomAnchor, centerX: followingLabel.centerXAnchor, paddingTop: 5)
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        myLikesView.isHidden = true
        segmentedControl.anchor(top: editProfileButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingRight: 10)
    }
    
    private func configureMyPostsView() {
        view.addViews(myPostsView)
        myPostsView.addSubview(myPostsTableView)
        
        myPostsView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: seperatorView.topAnchor)
        myPostsTableView.anchor(top: myPostsView.topAnchor, left: myPostsView.leftAnchor, right: myPostsView.rightAnchor, bottom: myPostsView.bottomAnchor)
    }
}

extension AccountViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        navigationController?.pushViewController(HomePageViewController(), animated: false)
    }
    
    func didTapSearchButton() {
        navigationController?.pushViewController(SearchViewController(), animated: false)
    }
    
    func didTapAccountButton() {
        
    }
}

extension AccountViewController: AccountViewControllerProtocol {
    func setUserInfo(user: UserModel) {
        self.name = user.name + " " + user.surname
        
        nameLabel.text = "\(user.name) \(user.surname)"
        usernameLabel.text = "@\(user.username)"
         
        if !user.imageUrl.isEmpty {
            profileImageView.sd_setImage(with: URL(string: user.imageUrl))
            profileImageView.contentMode = .scaleAspectFill
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
            profileImageView.contentMode = .scaleAspectFit
        }
    }
    
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.myPostsTableView.reloadData()
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.musics.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyPostsTableViewCell.cellID, for: indexPath) as! MyPostsTableViewCell
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
        return 90
    }
}

extension AccountViewController: MusicDetailsDelegate {
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

extension AccountViewController {
    func playNextSong() {
        guard let currentMusic = MusicPlayerService.shared.music,
              let currentIndex = viewModel?.musics.firstIndex(where: { $0.musicID == currentMusic.musicID }),
              currentIndex + 1 < viewModel?.musics.count ?? 0 else { return }
        
        let nextMusic = viewModel?.musics[currentIndex + 1]
        playMusicAndUpdateUI(music: nextMusic)
    }
    
    func playRandomSong() {
        guard let randomMusic = viewModel?.musics.randomElement() else { return }
        playMusicAndUpdateUI(music: randomMusic)
    }
    
    private func playMusicAndUpdateUI(music: MusicModel?) {
        guard let music = music else { return }
        
        let vc = MusicDetailsViewController()
        vc.music = music
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        if presentedViewController is MusicDetailsViewController {
            dismiss(animated: false) {
                self.present(vc, animated: true)
            }
        } else {
            present(vc, animated: true)
        }
    }
}
