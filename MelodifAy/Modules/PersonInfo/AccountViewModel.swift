//
//  AccountViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.11.2024.
//

import Foundation

protocol AccountViewModelProtocol {
    func getDataUserInfo(completion: @escaping (Bool) -> Void)
    func getDataMusicInfo(completion: @escaping (Bool) -> Void)
    func getDataPlaylist(completion: @escaping (Bool) -> Void)
    func getDataLikeMusic()
    var serviceAccount: ServiceAccountProtocol { get }
}

class AccountViewModel: AccountViewModelProtocol {
    var serviceAccount: ServiceAccountProtocol = ServiceAccount()
    weak var view: AccountViewControllerProtocol?
    
    var musics = [MusicModel]()
    var likeMusics = [MusicModel]()
    var playlists = [PlaylistModel]()
    var user: UserModel?
    
    init(view: AccountViewControllerProtocol) {
        self.view = view
    }
    
    func getDataLikeMusic() {
        serviceAccount.fetchLikeMusic { musics in
            guard !musics.isEmpty else { return }
            
            DispatchQueue.main.async {
                self.likeMusics = musics
                self.view?.reloadDataCollectionView()
            }
        }
    }
    
    func getDataPlaylist(completion: @escaping (Bool) -> Void) {
        serviceAccount.fetchPlaylist { playlists in
            guard !playlists.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.playlists = playlists
                self.view?.reloadDataTableView()
                completion(true)
            }
        }
    }
    
    func getDataUserInfo(completion: @escaping (Bool) -> Void) {
        serviceAccount.fetchUserInfo { user in
            guard !user.name.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.user = user
                self.view?.setUserInfo(user: user)
                completion(true)
            }
        }
    }
    
    func getDataMusicInfo(completion: @escaping (Bool) -> Void) {
        serviceAccount.fetchMusicInfo { musics in
            guard !musics.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.musics = musics
                self.view?.reloadDataCollectionView()
                completion(true)
            }
        }
    }
}
