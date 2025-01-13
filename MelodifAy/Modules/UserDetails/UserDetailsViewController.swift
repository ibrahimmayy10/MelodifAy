//
//  UserDetailsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 13.12.2024.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 18), textColorLabel: .white)
    private let usernameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 20), textColorLabel: .white)
    
    private let followingLabel = Labels(textLabel: "Takip", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let followingCountLabel = Labels(textLabel: "200", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let followerLabel = Labels(textLabel: "Takipçi", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let followerCountLabel = Labels(textLabel: "300", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let musicLabel = Labels(textLabel: "Şarkı", fontLabel: .systemFont(ofSize: 14), textColorLabel: .white)
    private let musicCountLabel = Labels(textLabel: "10", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 45
        imageView.tintColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        return imageView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "chevron.backward", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Takip Et", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17 / 255, green: 57 / 255, blue: 113 / 255, alpha: 255 / 255)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(UserPostsTableViewCell.self, forCellReuseIdentifier: UserPostsTableViewCell.cellID)
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
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
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
        
        usernameLabel.text = user.username
        nameLabel.text = user.name + " " + user.surname
    }
    
    func configureWithExt() {
        view.addViews(backButton, profileImageView, musicLabel, musicCountLabel, usernameLabel, followButton, followerLabel, followerCountLabel, followingLabel, followingCountLabel, nameLabel)
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        usernameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, centerX: view.centerXAnchor, paddingTop: 10)
        profileImageView.anchor(top: usernameLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 30, paddingLeft: 20, width: 90, height: 90)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        musicLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, paddingTop: 20, paddingLeft: 20)
        musicCountLabel.anchor(top: musicLabel.bottomAnchor, centerX: musicLabel.centerXAnchor, paddingTop: 5)
        followerLabel.anchor(top: usernameLabel.bottomAnchor, left: musicLabel.rightAnchor, paddingTop: 20, paddingLeft: 50)
        followerCountLabel.anchor(top: followerLabel.bottomAnchor, centerX: followerLabel.centerXAnchor, paddingTop: 5)
        followingLabel.anchor(top: usernameLabel.bottomAnchor, left: followerLabel.rightAnchor, paddingTop: 20, paddingLeft: 50)
        followingCountLabel.anchor(top: followingLabel.bottomAnchor, centerX: followingLabel.centerXAnchor, paddingTop: 5)
        followButton.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 40)
    }
}
