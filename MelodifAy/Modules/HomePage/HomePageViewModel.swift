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
    func getDataTopListenedSongs(completion: @escaping (Bool) -> Void)
    func getDataTopLikedArtists()
    var serviceHomePage: ServiceHomePageProtocol { get }
}

class HomePageViewModel: HomePageViewModelProtocol {
    var serviceHomePage: ServiceHomePageProtocol = ServiceHomePage()
    var musics = [MusicModel]()
    var topListenedMusics = [MusicModel]()
    var users = [UserModel]()
    var likedArtists = [UserModel]()
    var playlists = [PlaylistModel]()
    var latestMusic: MusicModel?
    
    weak var view: HomePageViewControllerProtocol?
    
    init(view: HomePageViewControllerProtocol) {
        self.view = view
    }
    
    func getDataTopLikedArtists() {
        serviceHomePage.fetchTopLikedArtists { users in
            DispatchQueue.main.async {
                self.likedArtists = users
                self.view?.reloadDataCollectionView()
            }
        }
    }
    
    func getDataTopListenedSongs(completion: @escaping (Bool) -> Void) {
        serviceHomePage.fetchTopListenedSongs { musics in
            DispatchQueue.main.async {
                self.topListenedMusics = musics
                self.view?.reloadDataCollectionView()
                completion(true)
            }
        }
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
                self.view?.reloadDataTableViewView()
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
                self.view?.reloadDataTableViewView()
                completion(true)
            }
        }
    }
}
