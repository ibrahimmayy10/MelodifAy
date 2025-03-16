//
//  HomePageViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.02.2025.
//

import Foundation

protocol HomePageViewModelProtocol {
    func getDataMusicInfo(completion: @escaping (Bool) -> Void)
    func getDataSingersLike(completion: @escaping (Bool) -> Void)
    func getDataPlaylists(completion: @escaping (Bool) -> Void)
    func getDataLatestMusic(completion: @escaping (Bool) -> Void)
    var serviceHomePage: ServiceHomePageProtocol { get }
}

class HomePageViewModel: HomePageViewModelProtocol {
    var serviceHomePage: ServiceHomePageProtocol = ServiceHomePage()
    var musics = [MusicModel]()
    var users = [UserModel]()
    var playlists = [PlaylistModel]()
    var latestMusic: MusicModel?
    
    weak var view: HomePageViewControllerProtocol?
    
    init(view: HomePageViewControllerProtocol) {
        self.view = view
    }
    
    func getDataLatestMusic(completion: @escaping (Bool) -> Void) {
        serviceHomePage.fetchLatestMusics { music in
            DispatchQueue.main.async {
                self.latestMusic = music
                self.view?.reloadDataCollectionView()
                completion(true)
            }
        }
    }
    
    func getDataPlaylists(completion: @escaping (Bool) -> Void) {
        serviceHomePage.fetchPlaylists { playlists in
            DispatchQueue.main.async {
                self.playlists = playlists
                self.view?.reloadDataCollectionView()
                completion(true)
            }
        }
    }
    
    func getDataMusicInfo(completion: @escaping (Bool) -> Void) {
        serviceHomePage.fetchMusicInfo { musics in
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
    
    func getDataSingersLike(completion: @escaping (Bool) -> Void) {
        serviceHomePage.fetchSingersLike { users in
            guard !users.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.users = users
                self.view?.reloadDataCollectionView()
                completion(true)
            }
        }
    }
}
