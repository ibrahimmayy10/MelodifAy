//
//  SearchViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Lottie

protocol SearchViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

enum SearchResult {
    case music(MusicModel)
    case user(UserModel)
}

class SearchViewController: BaseViewController {
    
    private let bottomBar = BottomBarView()
    
    private let searchLabel = Labels(textLabel: "Şarkı veya Sanatçı Ara", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellID)
        return tableView
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Şarkı veya sanatçı ara"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        return searchBar
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    private var viewModel: SearchViewModel?
    var searchResults = [SearchResult]()
    
    private var tableViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMiniPlayerBottomPadding(65)
        
        viewModel = SearchViewModel(view: self)
        
        setup()
        configureBottomBar()
        configureWithExt()
        configureAnimationView()
        setDelegate()
        addTargetButtons()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerVisibilityChanged),
                                               name: NSNotification.Name("MiniVisibilityChanged"),
                                               object: nil)
        
    }
    
    override func updateMiniPlayerConstraints(isVisible: Bool) {
        tableViewBottomConstraint?.isActive = false
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: isVisible ? -65 : 0)
        tableViewBottomConstraint?.isActive = true
    }
    
    func addTargetButtons() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension SearchViewController {
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
            
            viewModel?.getDataUsers()
            viewModel?.getDataMusics()
            
            DispatchQueue.main.async {
                self.animationView.stop()
                self.animationView.isHidden = true
                
                self.toggleUIElementsVisibility(isHidden: false)
            }
        }
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        tableView.isHidden = isHidden
        searchBar.isHidden = isHidden
        searchLabel.isHidden = isHidden
    }
    
    func configureBottomBar() {
        let searchViewModel = BottomBarViewModel(selectedTab: .search(isSelected: true))
        bottomBar.viewModel = searchViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        view.addViews(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
    }
    
    func configureWithExt() {
        view.addViews(searchLabel, searchBar, tableView)
        
        searchLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        searchBar.anchor(top: searchLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, height: 50)
        tableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
}

extension SearchViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        navigationController?.pushViewController(HomePageViewController(), animated: false)
    }
    
    func didTapSearchButton() {
        
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
}

extension SearchViewController: SearchViewControllerProtocol {
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        
        let filteredMusics = viewModel?.musics.filter {
            $0.songName.lowercased().contains(searchText.lowercased()) ||
            $0.name.lowercased().contains(searchText.lowercased())
        } ?? []
        
        let filteredUsers = viewModel?.users.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.surname.lowercased().contains(searchText.lowercased()) ||
            $0.username.lowercased().contains(searchText.lowercased())
        } ?? []
        
        searchResults = filteredMusics.map { .music($0) } + filteredUsers.map { .user($0) }
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellID, for: indexPath) as! SearchTableViewCell
        let result = searchResults[indexPath.row]
        
        switch result {
        case .music(let music):
            cell.configure(music: music, user: nil)
        case .user(let user):
            cell.configure(music: nil, user: user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        
        switch result {
        case .music(let music):
            let vc = MusicDetailsViewController()
            vc.music = music
            vc.delegate = self
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            
        case .user(let user):
            let vc = UserDetailsViewController()
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SearchViewController: MusicDetailsDelegate {
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
