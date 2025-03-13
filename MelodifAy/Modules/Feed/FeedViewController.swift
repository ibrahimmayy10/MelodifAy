//
//  FeedViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.03.2025.
//

import UIKit
import Lottie

protocol FeedViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

class FeedViewController: BaseViewController {
    
    private let bottomBar = BottomBarView()
    private let topBar = TopBarView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.cellID)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: FeedViewModel?
    
    private var tableViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = FeedViewModel(view: self)
        
        setMiniPlayerBottomPadding(65)
        setup()
        configureTopBar()
        configureBottomBar()
        configureWithExt()
        configureAnimationView()
        setDelegate()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerVisibilityChanged),
                                               name: NSNotification.Name("MiniVisibilityChanged"),
                                               object: nil)

    }
    
    override func viewDidLayoutSubviews() { // bu kod bloğu tableView ın constraint ine dokunmadan bottomBar ın üzerinde görünmesini sağlıyor.
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBar.frame.height + 10, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    override func updateMiniPlayerConstraints(isVisible: Bool) {
        tableViewBottomConstraint?.isActive = false

        let bottomAnchor = isVisible ? view.bottomAnchor : bottomBar.topAnchor
        let bottomPadding: CGFloat = isVisible ? 0 : -10

        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomPadding)
        tableViewBottomConstraint?.isActive = true
        view.layoutIfNeeded()
    }
    
    func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension FeedViewController {
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
            
            self.viewModel?.getDataMusicOfFollowed(completion: { success in
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
        tableView.isHidden = isHidden
    }
    
    func configureTopBar() {
        topBar.delegate = self
        view.addViews(topBar)
        
        topBar.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: view.bounds.size.height * 0.12)
    }
    
    func configureBottomBar() {
        let feedViewModel = BottomBarViewModel(selectedTab: .feed(isSelected: true))
        bottomBar.viewModel = feedViewModel
        bottomBar.delegate = self
        
        view.addViews(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 10, paddingRight: 10, paddingBottom: 5, height: 55)
    }
    
    func configureWithExt() {
        view.addViews(tableView)
        
        tableView.anchor(top: topBar.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        
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

extension FeedViewController: FeedViewControllerProtocol {
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension FeedViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        navigationController?.pushViewController(HomePageViewController(), animated: false)
    }
    
    func didTapFeedButton() {
        
    }
    
    func didTapSearchButton() {
        navigationController?.pushViewController(SearchViewController(), animated: false)
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.musics.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.cellID, for: indexPath) as! FeedTableViewCell
        let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
        let user = viewModel?.users.first(where: { $0.userID == music.userID }) ?? UserModel(userID: "", name: "", surname: "", username: "", imageUrl: "")
        cell.configure(music: music, user: user)
        cell.delegate = self 
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let music = viewModel?.musics[indexPath.row] ?? MusicModel(coverPhotoURL: "", lyrics: "", musicID: "", musicUrl: "", songName: "", name: "", userID: "", musicFileType: "")
//        
//        if let cell = tableView.cellForRow(at: indexPath) {
//            AnimationHelper.animateCell(cell: cell, in: self.view) {
//                let vc = MusicDetailsViewController()
//                vc.music = music
//                vc.musics = self.viewModel?.musics ?? []
//                vc.delegate = self
//                vc.modalPresentationStyle = .overFullScreen
//                vc.modalTransitionStyle = .crossDissolve
//                self.present(vc, animated: true)
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension FeedViewController: MusicDetailsDelegate {
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

extension FeedViewController: FeedTableViewCellDelegate {
    func didTapOptionsButton(music: MusicModel) {
        let vc = OptionsViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        vc.music = music
        self.present(navController, animated: true)
    }
}

extension FeedViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension FeedViewController: TopBarViewDelegate {
    func didTapNotificationButton() {
        
    }
    
    func didTapMessageBoxButton() {
        
    }
}
