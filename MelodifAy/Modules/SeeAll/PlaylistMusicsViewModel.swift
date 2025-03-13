//
//  SeeAllViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 14.03.2025.
//

import Foundation

protocol SeeAllViewModelProtocol {
    func getDataPlaylistMusics(musicIDs: [String], completion: @escaping (Bool) -> Void)
    var servicePlaylistMusics: ServicePlaylistMusicsProtocol { get }
}

class PlaylistMusicsViewModel: SeeAllViewModelProtocol {
    var servicePlaylistMusics: ServicePlaylistMusicsProtocol = ServicePlaylistMusics()
    
    var musics = [MusicModel]()
    
    weak var view: PlaylistMusicsViewControllerProtocol?
    
    init(view: PlaylistMusicsViewControllerProtocol) {
        self.view = view
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
