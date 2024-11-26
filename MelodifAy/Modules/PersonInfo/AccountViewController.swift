//
//  AccountViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit
import Firebase
import SDWebImage

protocol AccountViewControllerProtocol: AnyObject {
    func setUserInfo(user: UserModel)
}

class AccountViewController: UIViewController {
    
    private let bottomBar = BottomBarView()
    
    private let seperatorView = SeperatorView(color: .lightGray)
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 17), textColorLabel: .darkGray)
    
    private let followingLabel = Labels(textLabel: "Takip", fontLabel: .systemFont(ofSize: 14), textColorLabel: .black)
    private let followingCountLabel = Labels(textLabel: "200", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .black)
    private let followerLabel = Labels(textLabel: "Takipçi", fontLabel: .systemFont(ofSize: 14), textColorLabel: .black)
    private let followerCountLabel = Labels(textLabel: "300", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .black)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("çıkış yap", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()
    
//    private let collectionView: UICollectionView = {
//        let collectionView = UICollectionView()
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .white
//        collectionView.register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellWithReuseIdentifier: <#T##String#>)
//        return collectionView
//    }()
    
    private var viewModel: AccountViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = AccountViewModel(view: self)
        
        setup()
        configureBottomBar()
        configureWithExt()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        button.addTarget(self, action: #selector(button_Clicked), for: .touchUpInside)
    }
    
    @objc func button_Clicked() {
        do {
            try Auth.auth().signOut()
            self.navigationController?.pushViewController(SignInViewController(), animated: true)
        } catch {
            print("öfdsşlfslş")
        }
    }

}

extension AccountViewController {
    func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        viewModel?.getDataUserInfo()
    }
    
    func configureBottomBar() {
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
        view.addViews(profileImageView, nameLabel, usernameLabel, followerLabel, followerCountLabel, followingLabel, followingCountLabel, button)
        
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 70, height: 70)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: profileImageView.rightAnchor, paddingTop: 30, paddingLeft: 15)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 5, paddingLeft: 15)
        followerLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 20, paddingLeft: 15)
        followerCountLabel.anchor(top: followerLabel.bottomAnchor, centerX: followerLabel.centerXAnchor, paddingTop: 5)
        followingLabel.anchor(top: usernameLabel.bottomAnchor, left: followerLabel.rightAnchor, paddingTop: 20, paddingLeft: 20)
        followingCountLabel.anchor(top: followingLabel.bottomAnchor, centerX: followingLabel.centerXAnchor, paddingTop: 5)
        button.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: bottomBar.topAnchor, paddingBottom: 20, height: 50)
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
        nameLabel.text = "\(user.name) \(user.surname)"
        usernameLabel.text = "@\(user.username)"
         
        if !user.imageUrl.isEmpty {
            profileImageView.sd_setImage(with: URL(string: user.imageUrl))
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
            profileImageView.contentMode = .scaleAspectFit
        }
    }
}
