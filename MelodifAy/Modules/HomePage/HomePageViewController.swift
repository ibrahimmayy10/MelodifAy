//
//  HomePageViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 3.10.2024.
//

import UIKit
import Firebase

class HomePageViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let newPostButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let seperatorView = SeperatorView(color: .lightGray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBottomBar()
        configureWithExt()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        newPostButton.addTarget(self, action: #selector(newPostButton_Clicked), for: .touchUpInside)
    }
    
    @objc func newPostButton_Clicked() {
        navigationController?.pushViewController(NewSongViewController(), animated: true)
    }

}

extension HomePageViewController {
    func configureWithExt() {
        view.addViews(newPostButton)
        
        newPostButton.anchor(right: view.rightAnchor, bottom: seperatorView.topAnchor, paddingRight: 10, paddingBottom: 10, width: 50, height: 50)
    }
}

extension HomePageViewController {
    func configureBottomBar() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        let homeViewModel = BottomBarViewModel(selectedTab: .home(isSelected: true))
        bottomBar.viewModel = homeViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = .white
        
        view.addViews(bottomBar, seperatorView)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
        seperatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, height: 1)
    }
}

extension HomePageViewController: BottomBarViewProtocol {
    func didTapHomeButton() {
        
    }
    
    func didTapSearchButton() {
        navigationController?.pushViewController(SearchViewController(), animated: false)
    }
    
    func didTapAccountButton() {
        navigationController?.pushViewController(AccountViewController(), animated: false)
    }
    
}
