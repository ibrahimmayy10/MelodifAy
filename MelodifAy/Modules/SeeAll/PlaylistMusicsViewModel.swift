//
//  SeeAllViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 14.03.2025.
//

import Foundation

protocol SeeAllViewModelProtocol {
    func getDataPlaylistMusics(musicIDs: [String], completion: @escaping (Bool) -> Void)
    func getDataFollowerUsers(userID: String, completion: @escaping (Bool) -> Void)
    func getDataFollowingUsers(userID: String, completion: @escaping (Bool) -> Void)
    var servicePlaylistMusics: ServicePlaylistMusicsProtocol { get }
}

class PlaylistMusicsViewModel: SeeAllViewModelProtocol {
    var servicePlaylistMusics: ServicePlaylistMusicsProtocol = ServicePlaylistMusics()
    
    var musics = [MusicModel]()
    var followers = [UserModel]()
    var following = [UserModel]()
    
    weak var view: PlaylistMusicsViewControllerProtocol?
    
    init(view: PlaylistMusicsViewControllerProtocol) {
        self.view = view
    }
    
    func getDataFollowingUsers(userID: String, completion: @escaping (Bool) -> Void) {
        servicePlaylistMusics.fetchFollowingUsers(userID: userID) { users in
            DispatchQueue.main.async {
                self.following = users
                self.view?.reloadDataTableView()
                completion(true)
            }
        }
    }
    
    func getDataFollowerUsers(userID: String, completion: @escaping (Bool) -> Void) {
        servicePlaylistMusics.fetchFollowerUsers(userID: userID) { users in
            DispatchQueue.main.async {
                self.followers = users
                self.view?.reloadDataTableView()
                completion(true)
            }
        }
    }
    
    func getDataPlaylistMusics(musicIDs: [String], completion: @escaping (Bool) -> Void) {
        servicePlaylistMusics.fetchPlaylistMusics(musicIDs: musicIDs) { musics in
            guard !musics.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.musics = musics
                self.view?.reloadDataTableView()
                completion(true)
            }
        }
    }
}
