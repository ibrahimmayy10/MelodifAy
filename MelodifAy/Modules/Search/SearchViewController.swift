//
//  SearchViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit

protocol SearchViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

enum SearchResult {
    case music(MusicModel)
    case user(UserModel)
}

class SearchViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    private let searchLabel = Labels(textLabel: "Şarkı veya Sanatçı Ara", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellID)
        return tableView
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Şarkı veya sanatçı ara"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private var viewModel: SearchViewModel?
    var searchResults = [SearchResult]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SearchViewModel(view: self)
        
        setup()
        configureWithExt()
        configureBottomBar()
        setDelegate()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension SearchViewController {
    func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        viewModel?.getDataUsers()
        viewModel?.getDataMusics()
    }
    
    func configureBottomBar() {
        let searchViewModel = BottomBarViewModel(selectedTab: .search(isSelected: true))
        bottomBar.viewModel = searchViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = .white
        
        view.addViews(bottomBar, seperatorView)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
        seperatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, height: 1)
    }
    
    func configureWithExt() {
        view.addViews(searchLabel, searchBar, tableView)
        
        searchLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        searchBar.anchor(top: searchLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, height: 50)
        tableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
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
            $0.surname.lowercased().contains(searchText.lowercased())
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
