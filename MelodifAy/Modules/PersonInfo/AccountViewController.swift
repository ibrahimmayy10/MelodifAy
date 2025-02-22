//
//  AccountViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Firebase
import SDWebImage
import Lottie

protocol AccountViewControllerProtocol: AnyObject {
    func setUserInfo(user: UserModel)
    func reloadDataTableView()
}

class AccountViewController: BaseViewController {
    
    private let bottomBar = BottomBarView()
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 17), textColorLabel: .lightGray)
    
    private let followingLabel = Labels(textLabel: "Takip", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let followingCountLabel = Labels(textLabel: "200", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let followerLabel = Labels(textLabel: "Takipçi", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let followerCountLabel = Labels(textLabel: "300", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.tintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        return imageView
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Düzenle", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Paylaşımlarım", "Kitaplığım"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let myPostsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let myLikesView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let myPostsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(MyPostsTableViewCell.self, forCellReuseIdentifier: MyPostsTableViewCell.cellID)
        return tableView
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: AccountViewModel?
    private var music: MusicModel?
    private var name = String()
    
    private var tableViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AccountViewModel(view: self)
        
        setMiniPlayerBottomPadding(65)
        
        configureBottomBar()
        setup()
        configureWithExt()
        configureSegmentedControl()
        configureMyPostsView()
        configureAnimationView()
        addTargetButtons()
        setDelegate()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerVisibilityChanged),
                                               name: NSNotification.Name("MiniPlayerVisibilityChanged"),
                                               object: nil)
        
    }
    
    override func updateMiniPlayerConstraints(isVisible: Bool) {
        tableViewBottomConstraint?.isActive = false
        tableViewBottomConstraint = myPostsTableView.bottomAnchor.constraint(equalTo: myPostsView.bottomAnchor, constant: isVisible ? -65 : 0)
        tableViewBottomConstraint?.isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        editProfileButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    func setDelegate() {
        myPostsTableView.delegate = self
        myPostsTableView.dataSource = self
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension AccountViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
        
        toggleUIElementsVisibility(isHidden: true)
        getAllData()
    }
    
    func getAllData() {
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            viewModel?.getDataUserInfo(completion: { successfully in
                if successfully {
                    self.viewModel?.getDataMusicInfo(completion: { success in
                        if success {
                            DispatchQueue.main.async {
                                self.toggleUIElementsVisibility(isHidden: !success)
                                self.animationView.stop()
                                self.animationView.isHidden = true
                            }
                        }
                    })
                }
            })
        }
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        myPostsTableView.isHidden = isHidden
        segmentedControl.isHidden = isHidden
        profileImageView.isHidden = isHidden
        nameLabel.isHidden = isHidden
        usernameLabel.isHidden = isHidden
        editProfileButton.isHidden = isHidden
        followerLabel.isHidden = isHidden
        followingLabel.isHidden = isHidden
        followingCountLabel.isHidden = isHidden
        followerCountLabel.isHidden = isHidden
    }
    
    func configureBottomBar() {
        let accountViewModel = BottomBarViewModel(selectedTab: .account(isSelected: true))
        bottomBar.viewModel = accountViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        view.addViews(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
    }
    
    func configureWithExt() {
        view.addViews(profileImageView, nameLabel, usernameLabel, followerLabel, followerCountLabel, followingLabel, followingCountLabel, editProfileButton)
        
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 70, height: 70)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: profileImageView.rightAnchor, paddingTop: 30, paddingLeft: 15)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 5, paddingLeft: 15)
        editProfileButton.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 160, height: 30)
        followerLabel.anchor(top: profileImageView.bottomAnchor, left: editProfileButton.rightAnchor, paddingTop: 15, paddingLeft: 30)
        followerCountLabel.anchor(top: followerLabel.bottomAnchor, centerX: followerLabel.centerXAnchor, paddingTop: 5)
        followingLabel.anchor(top: profileImageView.bottomAnchor, left: followerLabel.rightAnchor, paddingTop: 15, paddingLeft: 30)
        followingCountLabel.anchor(top: followingLabel.bottomAnchor, centerX: followingLabel.centerXAnchor, paddingTop: 5)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
    
    private func configureSegmentedControl() {
        view.addSubview(segmentedControl)
        myLikesView.isHidden = true
        segmentedControl.anchor(top: editProfileButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 10, paddingRight: 10)
    }
    
    private func configureMyPostsView() {
        view.addViews(myPostsView)
        myPostsView.addSubview(myPostsTableView)
        
        myPostsView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor)
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
        return 75
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
