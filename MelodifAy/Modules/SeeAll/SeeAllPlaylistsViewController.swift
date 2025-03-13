//
//  SeeAllViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 13.03.2025.
//

import UIKit

class SeeAllPlaylistsViewController: BaseViewController {
    
    private let topLabel = Labels(textLabel: "Çalma Listelerin", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    
    private let topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.108, green: 0.108, blue: 0.108, alpha: 1.0)
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(UserPlaylistTableViewCell.self, forCellReuseIdentifier: UserPlaylistTableViewCell.cellID)
        return tableView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeImage = UIImage(systemName: "xmark", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
    var name = String()
    
    var playlists = [PlaylistModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMiniPlayerBottomPadding(0)
        
        setup()
        configureTopBar()
        configureWithExt()
        addTargetButtons()
        setDelegate()
        
        if let currentMusic = MusicPlayerService.shared.music {
            showMiniMusicPlayer(with: currentMusic)
        }
        
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }
    
    func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension SeeAllPlaylistsViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        tableView.isHidden = isHidden
    }
    
    func configureTopBar() {
        view.addViews(topBarView)
        topBarView.addViews(topLabel, dismissButton)

        topBarView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: view.bounds.size.height * 0.12)
        
        topLabel.anchor(bottom: topBarView.bottomAnchor, centerX: topBarView.centerXAnchor, paddingBottom: 15)
        dismissButton.anchor(left: topBarView.leftAnchor, bottom: topBarView.bottomAnchor, paddingLeft: 20, paddingBottom: 15)
    }
    
    func configureWithExt() {
        view.addViews(tableView)
        
        tableView.anchor(top: topBarView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor)
    }
}

extension SeeAllPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserPlaylistTableViewCell.cellID, for: indexPath) as! UserPlaylistTableViewCell
        let playlist = playlists[indexPath.row]
        cell.configure(playlist: playlist, name: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PlaylistMusicsViewController()
        let playlist = playlists[indexPath.row]
        vc.musicIDs = playlist.musicIDs
        vc.text = playlist.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
