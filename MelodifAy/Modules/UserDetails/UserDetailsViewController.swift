//
//  UserDetailsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 13.12.2024.
//

import UIKit
import Firebase
import Lottie

protocol UserDetailsViewControllerProtocol: AnyObject {
    func reloadDataCollectionView()
    func reloadDataTableView()
    func setUserInfo(user: UserModel)
}

class UserDetailsViewController: BaseViewController {
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 18), textColorLabel: .white)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    private let myPostLabel = Labels(textLabel: "Paylaşımlarım", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let myLikesLabel = Labels(textLabel: "Beğendiklerim", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let playlistLabel = Labels(textLabel: "Çalma listelerim", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
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
        imageView.layer.cornerRadius = 50
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
    
    private let seeAllPostsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tümünü Gör", for: .normal)
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    private let seeAllLikesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tümünü Gör", for: .normal)
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    private let seeAllPlaylistButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tümünü Gör", for: .normal)
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    private let postCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.cellID)
        return collectionView
    }()
    
    private let likesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.cellID)
        return collectionView
    }()
    
    private let playlistTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(UserPlaylistTableViewCell.self, forCellReuseIdentifier: UserPlaylistTableViewCell.cellID)
        return tableView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1.0)
        return view
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    var userID = String()
    private var music: MusicModel?
    private var viewModel: UserDetailsViewModel?
    private var isFollowing = false
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMiniPlayerBottomPadding(0)
        
        viewModel = UserDetailsViewModel(view: self)
        
        setDelegate()
        configureTopBar()
        configureWithExt()
        configureCollectionView()
        configureAnimationView()
        setup()
        addTargetButtons()
        checkFollowingStatus()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerVisibilityChanged),
                                               name: NSNotification.Name("MiniPlayerVisibilityChanged"),
                                               object: nil)
        
    }
    
//    override func updateMiniPlayerConstraints(isVisible: Bool) {
//        tableViewBottomConstraint?.isActive = false
//        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: isVisible ? -65 : 0)
//        tableViewBottomConstraint?.isActive = true
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        followButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    func setDelegate() {
        postCollectionView.dataSource = self
        postCollectionView.delegate = self
        
        likesCollectionView.dataSource = self
        likesCollectionView.delegate = self
        
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(followButton_Clicked), for: .touchUpInside)
    }
    
    private func checkFollowingStatus() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("Users").document(userID)
        
        userRef.getDocument { document, error in
            if let data = document?.data(), let followers = data["followers"] as? [String] {
                self.isFollowing = followers.contains(currentUserID)
                self.updateFollowButton()
            }
        }
    }
    
    @objc private func followButton_Clicked() {
        viewModel?.followUser(newUserID: userID)
        isFollowing.toggle()
        updateFollowButton()
    }
    
    private func updateFollowButton() {
        let title = isFollowing ? "Takibi Bırak" : "Takip Et"
        followButton.setTitle(title, for: .normal)
    }
    
    @objc func backButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension UserDetailsViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
        
        viewModel?.getDataUser(userID: self.userID)
        toggleUIElementsVisibility(isHidden: true)
        getAllData()
    }
    
    func getAllData() {
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            viewModel?.getDataMusic(userID: userID, completion: { success in
                guard let musics = self.viewModel?.musics else { return }
                if !musics.isEmpty {
                    if success {
                        DispatchQueue.main.async {
                            self.toggleUIElementsVisibility(isHidden: !success)
                            self.animationView.stop()
                            self.animationView.isHidden = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: false)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                }
            })
        }
        
        viewModel?.getDataPlaylist(userID: userID)
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        scrollView.isHidden = isHidden
    }
    
    func configureTopBar() {
        view.addViews(topBarView)
        topBarView.addViews(backButton, usernameLabel)
                
        topBarView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: view.bounds.size.height * 0.12)
        backButton.anchor(left: topBarView.leftAnchor, bottom: topBarView.bottomAnchor, paddingLeft: 10, paddingBottom: 15)
        usernameLabel.anchor(bottom: topBarView.bottomAnchor, centerX: topBarView.centerXAnchor, paddingBottom: 15)
    }
    
    func configureWithExt() {
        view.addViews(scrollView)
        scrollView.addSubview(contentView)
        contentView.addViews(profileImageView, nameLabel, followerLabel, followerCountLabel, followingLabel, followingCountLabel, musicLabel, musicCountLabel, followButton)
        
        scrollView.anchor(top: topBarView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width, height: 1300)
        
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 10, paddingLeft: 20, width: 100, height: 100)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        musicLabel.anchor(bottom: musicCountLabel.topAnchor, centerX: musicCountLabel.centerXAnchor, paddingBottom: 5)
        musicCountLabel.anchor(left: profileImageView.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 20)
        
        followerLabel.anchor(bottom: followerCountLabel.topAnchor, centerX: followerCountLabel.centerXAnchor, paddingBottom: 5)
        followerCountLabel.anchor(left: musicLabel.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 50)
        
        followingLabel.anchor(bottom: followingCountLabel.topAnchor, centerX: followingCountLabel.centerXAnchor, paddingBottom: 5)
        followingCountLabel.anchor(left: followerLabel.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 50)
        
        followButton.anchor(top: followerCountLabel.bottomAnchor, left: musicLabel.leftAnchor, right: followingLabel.rightAnchor, paddingTop: 20, height: 30)
    }
    
    func configureCollectionView() {
        contentView.addViews(postCollectionView, myPostLabel, seeAllPostsButton, likesCollectionView, myLikesLabel, seeAllLikesButton, playlistLabel, seeAllPlaylistButton, playlistTableView)
        
        playlistLabel.anchor(top: nameLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        seeAllPlaylistButton.anchor(top: nameLabel.bottomAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingRight: 10)
        playlistTableView.anchor(top: playlistLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 210)
        
        myPostLabel.anchor(top: playlistTableView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        seeAllPostsButton.anchor(top: playlistTableView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingRight: 10)
        postCollectionView.anchor(top: myPostLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 220)
        
        myLikesLabel.anchor(top: postCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        seeAllLikesButton.anchor(top: postCollectionView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingRight: 10)
        likesCollectionView.anchor(top: myLikesLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 220)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
}

extension UserDetailsViewController: UserDetailsViewControllerProtocol {
    func reloadDataCollectionView() {
        DispatchQueue.main.async {
            self.postCollectionView.reloadData()
            self.likesCollectionView.reloadData()
        }
    }
    
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.playlistTableView.reloadData()
        }
    }
    
    func setUserInfo(user: UserModel) {
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
}

extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(viewModel?.playlists.count ?? 1, 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaylistTableViewCell.cellID, for: indexPath) as! UserPlaylistTableViewCell
        let playlist = viewModel?.playlists[indexPath.row] ?? PlaylistModel(playlistID: "", name: "", musicIDs: [], imageUrl: "", userID: "")
        let name = "\(viewModel?.user?.name ?? "") \(viewModel?.user?.surname ?? "")"
        cell.configure(playlist: playlist, name: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension UserDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postCollectionView {
            return viewModel?.musics.count ?? 1
        } else if collectionView == likesCollectionView {
            return viewModel?.musics.count ?? 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == postCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.cellID, for: indexPath) as! UserCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
            cell.configure(music: music)
            return cell
        } else if collectionView == likesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.cellID, for: indexPath) as! UserCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
            cell.configure(music: music)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == postCollectionView || collectionView == likesCollectionView {
            return CGSize(width: 150, height: 210)
        } else {
            return CGSize()
        }
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
