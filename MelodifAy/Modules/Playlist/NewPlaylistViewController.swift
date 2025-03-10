//
//  PlaylistViewController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 6.03.2025.
//

import UIKit
import Lottie

protocol NewPlaylistViewControllerProtocol: AnyObject {
    func reloadDataTableView()
}

class NewPlaylistViewController: UIViewController {
    
    private let addPlaylistLabel = Labels(textLabel: "Çalma listesine ekle", fontLabel: .boldSystemFont(ofSize: 18), textColorLabel: .white)
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("İptal", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let newPlaylistButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.setTitle("Yeni çalma listesi", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private let finishButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        button.setTitle("Bitti", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.cellID)
        return tableView
    }()
    
    private let animationView = LottieAnimationView(name: "loadingAnimation")
    
    var music: MusicModel?
    
    var viewModel: PlaylistViewModel?
    
    private var selectedPlaylists: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = PlaylistViewModel(view: self)
        
        setup()
        configureWithExt()
        configureAnimationView()
        setDelegate()
        addTargetButtons()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        newPlaylistButton.applyGradient(colors: [UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0), UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)])
    }
    
    func addTargetButtons() {
        dismissButton.addTarget(self, action: #selector(dismissButton_Clicked), for: .touchUpInside)
        newPlaylistButton.addTarget(self, action: #selector(newPlaylistButton_Clicked), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButton_Clicked), for: .touchUpInside)
    }
    
    @objc func finishButton_Clicked() {
        guard let musicID = music?.musicID else { return }
        
        for playlistID in selectedPlaylists {
            viewModel?.addMusicToPlaylist(playlistID: playlistID, musicID: musicID)
        }
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func newPlaylistButton_Clicked() {
        let vc = CreatePlaylistViewController()
        vc.music = music
        present(vc, animated: true)
    }
    
    @objc func dismissButton_Clicked() {
        dismiss(animated: true)
    }
    
    func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension NewPlaylistViewController {
    func setup() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        getAllData()
    }
    
    func getAllData() {
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.viewModel?.getDataUserPlaylist(completion: { success in
                if success {
                    DispatchQueue.main.async {
                        self.toggleUIElementsVisibility(isHidden: !success)
                        self.animationView.stop()
                        self.animationView.isHidden = true
                    }
                }
            })
        }
    }
    
    func toggleUIElementsVisibility(isHidden: Bool) {
        tableView.isHidden = isHidden
    }
    
    func configureWithExt() {
        view.addViews(addPlaylistLabel, dismissButton, newPlaylistButton, tableView, finishButton)
        
        dismissButton.anchor(top: view.topAnchor,
                             left: view.leftAnchor,
                             paddingTop: 15,
                             paddingLeft: 10)
        
        addPlaylistLabel.anchor(top: view.topAnchor,
                                centerX: view.centerXAnchor,
                                paddingTop: 15)
        
        newPlaylistButton.anchor(top: addPlaylistLabel.bottomAnchor,
                                 centerX: view.centerXAnchor,
                                 paddingTop: 20,
                                 width: 160,
                                 height: 50)
        
        tableView.anchor(top: newPlaylistButton.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         bottom: view.bottomAnchor,
                         paddingTop: 10)
        
        finishButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            centerX: view.centerXAnchor,
                            paddingBottom: 10,
                            width: 120,
                            height: 50)
    }
    
    func configureAnimationView() {
        view.addViews(animationView)
        
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.anchor(centerX: view.centerXAnchor, centerY: view.centerYAnchor, width: 150, height: 150)
    }
}

extension NewPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.playlists.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.cellID, for: indexPath) as! PlaylistTableViewCell
        let playlist = viewModel?.playlists[indexPath.row] ?? PlaylistModel(playlistID: "", name: "", musicIDs: [], imageUrl: "", userID: "")
        
        guard let musicID = music?.musicID else { return cell }
        
        let isInPlaylist = playlist.musicIDs.contains(musicID)
        
        let isSelected = selectedPlaylists.contains(playlist.playlistID)
        
        cell.configure(playlist: playlist, isSelected: isSelected || isInPlaylist)
        
        cell.isInPlaylist = isInPlaylist
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playlist = viewModel?.playlists[indexPath.row] else { return }
        
        if let index = selectedPlaylists.firstIndex(of: playlist.playlistID) {
            selectedPlaylists.remove(at: index)
        } else {
            selectedPlaylists.append(playlist.playlistID)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension NewPlaylistViewController: NewPlaylistViewControllerProtocol {
    func reloadDataTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
