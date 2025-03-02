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

class FeedViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let melodifayLabel = Labels(textLabel: "MelodifAy", fontLabel: .monospacedDigitSystemFont(ofSize: 20, weight: .heavy), textColorLabel: .white)
    
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
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.cellID)
        return tableView
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .medium)
        let largeImage = UIImage(systemName: "bell.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let messageBoxButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .medium)
        let largeImage = UIImage(systemName: "envelope.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: FeedViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = FeedViewModel(view: self)
        
        setup()
        configureTopBar()
        configureBottomBar()
        configureWithExt()
        configureAnimationView()
        setDelegate()
        
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
        view.addViews(topBarView)
        topBarView.addViews(melodifayLabel, notificationButton, messageBoxButton)
                
        topBarView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: view.bounds.size.height * 0.12)
        melodifayLabel.anchor(bottom: topBarView.bottomAnchor, centerX: topBarView.centerXAnchor, paddingBottom: 15)
        messageBoxButton.anchor(right: topBarView.rightAnchor, bottom: topBarView.bottomAnchor, paddingRight: 20, paddingBottom: 15)
        notificationButton.anchor(right: messageBoxButton.leftAnchor, bottom: topBarView.bottomAnchor, paddingRight: 20, paddingBottom: 15)
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
        
        tableView.anchor(top: topBarView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
        
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
        cell.configure(music: music)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
