//
//  HomePageViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit
import Firebase
import Lottie

protocol HomePageViewControllerProtocol: AnyObject {
    func reloadDataCollectionView()
}

class HomePageViewController: BaseViewController {
    
    private let bottomBar = BottomBarView()
    private let topBar = TopBarView()
    
    private let recommendedLabel = Labels(textLabel: "Senin için önerilenler", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    private let playlistsForYouLabel = Labels(textLabel: "Senin için derlendi", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    private let singerYouLikeLabel = Labels(textLabel: "Beğendiğin şarkıcılar", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    private let listenToMostLabel = Labels(textLabel: "Dinlemeye doyamadıkların", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    private let newlyReleasedSongsLabel = Labels(textLabel: "Yeni çıkanlar", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    
    private let newPostButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.layer.cornerRadius = 25
        return button
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
    
    private let recommendedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(HomePageCollectionViewCell.self, forCellWithReuseIdentifier: HomePageCollectionViewCell.cellID)
        return collectionView
    }()
    
    private let playlistCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.cellID)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let playlistsForYouCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(PlaylistsForYouCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistsForYouCollectionViewCell.cellID)
        return collectionView
    }()
    
    private let singerYouLikeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(SingerYouLikeCollectionViewCell.self, forCellWithReuseIdentifier: SingerYouLikeCollectionViewCell.cellID)
        return collectionView
    }()
    
    private let listenToMostCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(HomePageCollectionViewCell.self, forCellWithReuseIdentifier: HomePageCollectionViewCell.cellID)
        return collectionView
    }()
    
    private let newlyReleasedSongCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(NewlyReleasedSongCollectionViewCell.self, forCellWithReuseIdentifier: NewlyReleasedSongCollectionViewCell.cellID)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "melodifaylogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var newPostButtonBottomConstraint: NSLayoutConstraint?
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: HomePageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = HomePageViewModel(view: self)
        
        setMiniPlayerBottomPadding(65)
        
        setup()
        configureTopBar()
        configureBottomBar()
        configureWithExt()
        configureCollectionViews()
        configureAnimationView()
        addTargetButtons()
        setDelegate()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerVisibilityChanged),
                                               name: NSNotification.Name("MiniVisibilityChanged"),
                                               object: nil)
        
    }
    
    override func updateMiniPlayerConstraints(isVisible: Bool) {
        newPostButtonBottomConstraint?.isActive = false
        newPostButtonBottomConstraint = newPostButton.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: isVisible ? -75 : 0)
        newPostButtonBottomConstraint?.isActive = true
    }
    
    func setDelegate() {
        recommendedCollectionView.delegate = self
        recommendedCollectionView.dataSource = self
        
        playlistCollectionView.delegate = self
        playlistCollectionView.dataSource = self
        
        playlistsForYouCollectionView.delegate = self
        playlistsForYouCollectionView.dataSource = self
        
        singerYouLikeCollectionView.delegate = self
        singerYouLikeCollectionView.dataSource = self
        
        listenToMostCollectionView.delegate = self
        listenToMostCollectionView.dataSource = self
        
        newlyReleasedSongCollectionView.delegate = self
        newlyReleasedSongCollectionView.dataSource = self
    }
    
    func addTargetButtons() {
        newPostButton.addTarget(self, action: #selector(newPostButton_Clicked), for: .touchUpInside)
    }
    
    @objc func newPostButton_Clicked() {
        navigationController?.pushViewController(NewSongViewController(), animated: true)
    }

}

extension HomePageViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        toggleUIElementsVisibility(isHidden: true)
        getAllData()
    }
    
    func getAllData() {
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.viewModel?.getDataPlaylists(completion: { success in
                if success {
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: !success)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                }
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.viewModel?.getDataSingersLike(completion: { success in
                if success {
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: !success)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                }
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.viewModel?.getDataLatestMusic(completion: { success in
                if success {
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: !success)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                }
            })
        }
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        scrollView.isHidden = isHidden
    }
    
    func configureTopBar() {
        topBar.delegate = self
        view.addViews(topBar)
        
        topBar.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: view.bounds.size.height * 0.12)
    }
    
    func configureBottomBar() {
        let homeViewModel = BottomBarViewModel(selectedTab: .home(isSelected: true))
        bottomBar.viewModel = homeViewModel
        bottomBar.delegate = self
        
        view.addViews(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 10, paddingRight: 10, paddingBottom: 5, height: 55)
    }
    
    func configureWithExt() {
        view.addViews(newPostButton, scrollView)
        scrollView.addSubview(contentView)
        
        newPostButton.anchor(right: view.rightAnchor, bottom: bottomBar.topAnchor, paddingRight: 10, paddingBottom: 10, width: 50, height: 50)
        
        scrollView.anchor(top: topBar.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, bottom: scrollView.bottomAnchor, width: view.bounds.size.width, height: 1520)
        
        view.bringSubviewToFront(newPostButton)
        view.bringSubviewToFront(bottomBar)
    }
    
    func configureCollectionViews() {
        contentView.addViews(recommendedLabel, recommendedCollectionView, playlistCollectionView, playlistsForYouLabel, playlistsForYouCollectionView, singerYouLikeLabel, singerYouLikeCollectionView, listenToMostLabel, listenToMostCollectionView, newlyReleasedSongsLabel, newlyReleasedSongCollectionView)
        
        playlistCollectionView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5, height: 200)
        
        recommendedLabel.anchor(top: playlistCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        recommendedCollectionView.anchor(top: recommendedLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5, height: 190)
        
        newlyReleasedSongsLabel.anchor(top: recommendedCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        newlyReleasedSongCollectionView.anchor(top: newlyReleasedSongsLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5, height: 160)
        
        singerYouLikeLabel.anchor(top: newlyReleasedSongCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        singerYouLikeCollectionView.anchor(top: singerYouLikeLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5, height: 140)
        
        playlistsForYouLabel.anchor(top: singerYouLikeCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        playlistsForYouCollectionView.anchor(top: playlistsForYouLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5, height: 220)
        
        listenToMostLabel.anchor(top: playlistsForYouCollectionView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 10)
        listenToMostCollectionView.anchor(top: listenToMostLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5, paddingRight: 5, height: 190)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
}

extension HomePageViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        
    }
    
    func didTapFeedButton() {
        navigationController?.pushViewController(FeedViewController(), animated: false)
    }
    
    func didTapSearchButton() {
        navigationController?.pushViewController(SearchViewController(), animated: false)
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
}

extension HomePageViewController: HomePageViewControllerProtocol {
    func reloadDataCollectionView() {
        DispatchQueue.main.async {
            self.recommendedCollectionView.reloadData()
            self.playlistCollectionView.reloadData()
            self.playlistsForYouCollectionView.reloadData()
            self.singerYouLikeCollectionView.reloadData()
            self.listenToMostCollectionView.reloadData()
            self.newlyReleasedSongCollectionView.reloadData()
        }
    }
}

extension HomePageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recommendedCollectionView {
            return viewModel?.musics.count ?? 1
        } else if collectionView == playlistCollectionView {
            return min(viewModel?.playlists.count ?? 1, 6)
        } else if collectionView == playlistsForYouCollectionView {
            return viewModel?.musics.count ?? 1
        } else if collectionView == singerYouLikeCollectionView {
            return viewModel?.users.count ?? 1
        } else if collectionView == listenToMostCollectionView {
            return viewModel?.musics.count ?? 1
        } else if collectionView == newlyReleasedSongCollectionView {
            return viewModel?.musics.count ?? 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recommendedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePageCollectionViewCell.cellID, for: indexPath) as! HomePageCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            cell.configure(music: music)
            return cell
        } else if collectionView == playlistCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.cellID, for: indexPath) as! PlaylistCollectionViewCell
            let playlist = viewModel?.playlists[indexPath.row] ?? PlaylistModel(playlistID: "", name: "", musicIDs: [], imageUrl: "", userID: "")
            cell.configure(playlist: playlist)
            return cell
        } else if collectionView == playlistsForYouCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistsForYouCollectionViewCell.cellID, for: indexPath) as! PlaylistsForYouCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            cell.configure(music: music)
            return cell
        } else if collectionView == singerYouLikeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingerYouLikeCollectionViewCell.cellID, for: indexPath) as! SingerYouLikeCollectionViewCell
            let user = viewModel?.users[indexPath.row] ?? UserModel(userID: "", name: "", surname: "", username: "", imageUrl: "", followers: [], following: [])
            cell.configure(user: user)
            return cell
        } else if collectionView == listenToMostCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePageCollectionViewCell.cellID, for: indexPath) as! HomePageCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            cell.configure(music: music)
            return cell
        } else if collectionView == newlyReleasedSongCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewlyReleasedSongCollectionViewCell.cellID, for: indexPath) as! NewlyReleasedSongCollectionViewCell
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            cell.delegate = self
            cell.configure(music: music)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == recommendedCollectionView {
            let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "", likes: [])
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                AnimationHelper.animateCell(cell: cell, in: self.view) {
                    let vc = MusicDetailsViewController()
                    vc.music = music
                    vc.musics = self.viewModel?.musics ?? []
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                }
            }
        } else if collectionView == singerYouLikeCollectionView {
            let user = viewModel?.users[indexPath.row] ?? UserModel(userID: "", name: "", surname: "", username: "", imageUrl: "", followers: [], following: [])
            
            if let cell = collectionView.cellForItem(at: indexPath) {
                AnimationHelper.animateCell(cell: cell, in: self.view) {
                    let vc = UserDetailsViewController()
                    vc.userID = user.userID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if collectionView == playlistCollectionView {
            let vc = PlaylistMusicsViewController()
            let playlist = viewModel?.playlists[indexPath.row] ?? PlaylistModel(playlistID: "", name: "", musicIDs: [], imageUrl: "", userID: "")
            vc.musicIDs = playlist.musicIDs
            vc.text = playlist.name
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recommendedCollectionView {
            return CGSize(width: 130, height: 180)
        } else if collectionView == playlistCollectionView {
            return CGSize(width: view.bounds.size.width * 0.45, height: 60)
        } else if collectionView == playlistsForYouCollectionView {
            return CGSize(width: view.bounds.size.width * 0.98, height: 210)
        } else if collectionView == singerYouLikeCollectionView {
            return CGSize(width: 100, height: 140)
        } else if collectionView == listenToMostCollectionView {
            return CGSize(width: 130, height: 180)
        } else if collectionView == newlyReleasedSongCollectionView {
            return CGSize(width: view.bounds.size.width * 0.95, height: 150)
        } else {
            return CGSize()
        }
    }
    
}

extension HomePageViewController: MusicDetailsDelegate {
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

extension HomePageViewController: NewlyReleasedSongCollectionViewCellProtocol {
    func didTapOptionsButton(music: MusicModel) {
        let vc = OptionsViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        vc.music = music
        self.present(navController, animated: true)
    }
    
    func didTapAddToLibraryButton(music: MusicModel) {
        let vc = NewPlaylistViewController()
        vc.music = music
        present(vc, animated: true)
    }
}

extension HomePageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension HomePageViewController: TopBarViewDelegate {
    func didTapNotificationButton() {
        
    }
    
    func didTapMessageBoxButton() {
        
    }
}
