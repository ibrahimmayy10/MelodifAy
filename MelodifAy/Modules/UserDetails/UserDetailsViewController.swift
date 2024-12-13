//
//  UserDetailsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 13.12.2024.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .black)
    
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
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Takip Et", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 10
        button.tintColor = .black
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.register(MyPostsTableViewCell.self, forCellReuseIdentifier: MyPostsTableViewCell.cellID)
        return tableView
    }()
    
    var user: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWithExt()
        setup()
        addTargetButtons()
        
    }
    
    func addTargetButtons() {
        backButton.addTarget(self, action: #selector(backButton_Clicked), for: .touchUpInside)
    }
    
    @objc func backButton_Clicked() {
        navigationController?.popViewController(animated: true)
    }

}

extension UserDetailsViewController {
    func setup() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        setUserInfo()
    }
    
    func setUserInfo() {
        guard let user = user else { return }
        
        if !user.imageUrl.isEmpty {
            profileImageView.sd_setImage(with: URL(string: user.imageUrl))
            profileImageView.contentMode = .scaleAspectFill
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
            profileImageView.contentMode = .scaleAspectFit
        }
        
        nameLabel.text = user.name + " " + user.surname
    }
    
    func configureWithExt() {
        view.addViews(backButton, profileImageView, nameLabel, followButton, followerLabel, followerCountLabel, followingLabel, followingCountLabel)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        profileImageView.anchor(top: backButton.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 70, height: 70)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        followerLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, paddingTop: 15, paddingLeft: -10)
        followerCountLabel.anchor(top: followerLabel.bottomAnchor, centerX: followerLabel.centerXAnchor, paddingTop: 5)
        followingLabel.anchor(top: nameLabel.bottomAnchor, left: followerLabel.rightAnchor, paddingTop: 15, paddingLeft: 25)
        followingCountLabel.anchor(top: followingLabel.bottomAnchor, centerX: followingLabel.centerXAnchor, paddingTop: 5)
        followButton.anchor(top: followerCountLabel.bottomAnchor, left: nameLabel.leftAnchor, paddingTop: 20, width: 120, height: 30)
    }
}
