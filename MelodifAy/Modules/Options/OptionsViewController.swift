//
//  OptionsViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 6.03.2025.
//

import UIKit

class OptionsViewController: UIViewController {
    
    var options = [
        Options(text: "Çalma listesine ekle", imageName: "plus.circle"),
        Options(text: "Paylaş", imageName: "square.and.arrow.up"),
        Options(text: "Sanatçıya git", imageName: "person.badge.shield.checkmark.fill")
    ]
    
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
    private let coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(OptionsTableViewCell.self, forCellReuseIdentifier: OptionsTableViewCell.cellID)
        return tableView
    }()
    
    private let separatorView = SeperatorView(color: .lightGray)
    
    var music: MusicModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureWithExt()
        setMusicInfo()
        setDelegate()
        addTargetButtons()
        
    }
    
    private func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension OptionsViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        navigationController?.navigationBar.isHidden = true
    }
    
    func setMusicInfo() {
        guard let music = music else { return }
        coverPhotoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
        nameLabel.text = music.name
    }
    
    func configureWithExt() {
        view.addViews(coverPhotoImageView, dismissButton, nameLabel, songNameLabel, separatorView, tableView)
        
        coverPhotoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 15, paddingLeft: 10, width: 50, height: 50)
        dismissButton.anchor(right: view.rightAnchor, centerY: coverPhotoImageView.centerYAnchor, paddingRight: 10)
        songNameLabel.anchor(top: coverPhotoImageView.topAnchor, left: coverPhotoImageView.rightAnchor, paddingTop: 7, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: coverPhotoImageView.rightAnchor, paddingLeft: 10)
        separatorView.anchor(top: coverPhotoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, height: 0.5)
        
        tableView.anchor(top: separatorView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.cellID, for: indexPath) as! OptionsTableViewCell
        let option = options[indexPath.row]
        cell.configure(options: option)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let vc = NewPlaylistViewController()
            vc.music = music
            present(vc, animated: true)
        case 1:
            print("sanatçıya git")
        case 2:
            dismiss(animated: true) {
                let vc = UserDetailsViewController()
                vc.userID = self.music?.userID ?? ""
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController as? UINavigationController {
                    rootVC.pushViewController(vc, animated: true)
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
