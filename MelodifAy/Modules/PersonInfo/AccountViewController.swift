//
//  AccountViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit

class AccountViewController: UIViewController {
    
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

extension AccountViewController {
    func configureBottomBar() {
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        let accountViewModel = BottomBarViewModel(selectedTab: .account(isSelected: true))
        bottomBar.viewModel = accountViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = .black
        
        view.addViews(bottomBar, seperatorView)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
        seperatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, height: 1)
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
