//
//  AccountViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    private let signOutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Çıkış Yap", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 15
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        configureBottomBar()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        signOutButton.addTarget(self, action: #selector(signOutButton_Clicked), for: .touchUpInside)
    }
    
    @objc func signOutButton_Clicked() {
        do {
            try Auth.auth().signOut()
            self.navigationController?.pushViewController(SignInViewController(), animated: true)
        } catch {
            print("Çıkış yapılırken hata oluştu")
        }
    }

}

extension AccountViewController {
    func configureBottomBar() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        let accountViewModel = BottomBarViewModel(selectedTab: .account(isSelected: true))
        bottomBar.viewModel = accountViewModel
        bottomBar.delegate = self
        bottomBar.backgroundColor = .white
        
        view.addViews(bottomBar, seperatorView)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 60)
        seperatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, height: 1)
    }
    
    func configureWithExt() {
        view.addViews(signOutButton)
        
        signOutButton.anchor(left: view.leftAnchor, right: view.rightAnchor, centerY: view.centerYAnchor, paddingLeft: 20, paddingRight: 20, height: 40)
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
