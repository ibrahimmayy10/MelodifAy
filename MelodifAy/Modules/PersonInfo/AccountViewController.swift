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
    func reloadDataCollectionView()
}

class AccountViewController: BaseViewController {
    
    private let bottomBar = BottomBarView()
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .white)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 14), textColorLabel: .lightGray)
    private let myPostLabel = Labels(textLabel: "Paylaşımlarım", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let myLikesLabel = Labels(textLabel: "Beğendiklerim", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
    private let followingLabel = Labels(textLabel: "Takip", fontLabel: .systemFont(ofSize: 13), textColorLabel: .white)
    private let followingCountLabel = Labels(textLabel: "200", fontLabel: .boldSystemFont(ofSize: 12), textColorLabel: .white)
    private let followerLabel = Labels(textLabel: "Takipçi", fontLabel: .systemFont(ofSize: 13), textColorLabel: .white)
    private let followerCountLabel = Labels(textLabel: "300", fontLabel: .boldSystemFont(ofSize: 12), textColorLabel: .white)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
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
    
    private let seeAllMyPostsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tümünü Gör", for: .normal)
        button.setTitleColor(UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    private let seeAllMyLikesButton: UIButton = {
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
    
    private let myLikesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        collectionView.register(MyLikesCollectionViewCell.self, forCellWithReuseIdentifier: MyLikesCollectionViewCell.cellID)
        return collectionView
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
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: AccountViewModel?
    private var music: MusicModel?
    private var name = String()
    
    private var tableViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AccountViewModel(view: self)
        
        setMiniPlayerBottomPadding(70)
        
        configureBottomBar()
        setup()
        configureWithExt()
        configureCollectionView()
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
//        tableViewBottomConstraint = myPostsTableView.bottomAnchor.constraint(equalTo: myPostsView.bottomAnchor, constant: isVisible ? -65 : 0)
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
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        
        myLikesCollectionView.delegate = self
        myLikesCollectionView.dataSource = self
    }
    
    func addTargetButtons() {
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
        scrollView.isHidden = isHidden
    }
    
    func configureBottomBar() {
        let accountViewModel = BottomBarViewModel(selectedTab: .account(isSelected: true))
        bottomBar.viewModel = accountViewModel
        bottomBar.delegate = self
        
        view.addViews(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 10, paddingRight: 10, paddingBottom: 5, height: 60)
    }
    
    func configureWithExt() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addViews(profileImageView, nameLabel, usernameLabel, followerLabel, followerCountLabel, followingLabel, followingCountLabel, editProfileButton)
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width, height: 1000)
        
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 100, height: 100)
        
        nameLabel.anchor(left: profileImageView.rightAnchor, bottom: usernameLabel.topAnchor, paddingLeft: 15)
        usernameLabel.anchor(left: profileImageView.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 15)
        
        editProfileButton.anchor(top: profileImageView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 25, paddingLeft: 20, width: 140, height: 30)
        
        followerLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 15, paddingLeft: 30)
        followerCountLabel.anchor(top: followerLabel.bottomAnchor, centerX: followerLabel.centerXAnchor, paddingTop: 5)
        
        followingLabel.anchor(top: usernameLabel.bottomAnchor, left: followerLabel.rightAnchor, paddingTop: 15, paddingLeft: 30)
        followingCountLabel.anchor(top: followingLabel.bottomAnchor, centerX: followingLabel.centerXAnchor, paddingTop: 5)
    }
    
    func configureCollectionView() {
        contentView.addViews(postCollectionView, myPostLabel, seeAllMyPostsButton, myLikesCollectionView, myLikesLabel, seeAllMyLikesButton)
        
        myPostLabel.anchor(top: editProfileButton.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        seeAllMyPostsButton.anchor(top: editProfileButton.bottomAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingRight: 10)
        postCollectionView.anchor(top: myPostLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 220)
        
        myLikesLabel.anchor(top: postCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        seeAllMyLikesButton.anchor(top: postCollectionView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 15, paddingRight: 10)
        myLikesCollectionView.anchor(top: myLikesLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 220)
        
        view.bringSubviewToFront(bottomBar)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
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
    
    func reloadDataCollectionView() {
        DispatchQueue.main.async {
            self.postCollectionView.reloadData()
            self.myLikesCollectionView.reloadData()
        }
    }
}

extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == postCollectionView {
            return viewModel?.musics.count ?? 1
        } else if collectionView == myLikesCollectionView {
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
        } else if collectionView == myLikesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyLikesCollectionViewCell.cellID, for: indexPath) as! MyLikesCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
            cell.configure(music: music)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == postCollectionView || collectionView == myLikesCollectionView {
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
            
            if let cell = collectionView.cellForItem(at: indexPath) {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == postCollectionView || collectionView == myLikesCollectionView {
            return CGSize(width: 150, height: 210)
        } else {
            return CGSize()
        }
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
