//
//  SearchViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let seperatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBottomBar()
        
    }

}

extension SearchViewController {
    func configureBottomBar() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        let searchViewModel = BottomBarViewModel(selectedTab: .search(isSelected: true))
        bottomBar.viewModel = searchViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = .black
        
        view.addViews(bottomBar, seperatorView)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
        seperatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, height: 1)
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
