//
//  PlaylistViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 10.03.2025.
//

import Foundation
import Firebase

protocol PlaylistViewModelProtocol {
    func getDataUserPlaylist(completion: @escaping (Bool) -> Void)
    var servicePlaylist: ServicePlaylistProtocol { get }
}

class PlaylistViewModel: PlaylistViewModelProtocol {
    var servicePlaylist: ServicePlaylistProtocol = ServicePlaylist()
    var playlists = [PlaylistModel]()
    
    weak var view: NewPlaylistViewControllerProtocol?
    
    init(view: NewPlaylistViewControllerProtocol) {
        self.view = view
    }
    
    func getDataUserPlaylist(completion: @escaping (Bool) -> Void) {
        servicePlaylist.fetchUserPlaylist { playlists in
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
    
    func addMusicToPlaylist(playlistID: String, musicID: String) {
        let firestore = Firestore.firestore()
        let playlistRef = firestore.collection("Playlists").document(playlistID)

        playlistRef.updateData([
            "musicIDs": FieldValue.arrayUnion([musicID])
        ]) { error in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
            } else {
                print("Müzik başarıyla eklendi!")
                
                if let index = self.playlists.firstIndex(where: { $0.playlistID == playlistID }) {
                    self.playlists[index].musicIDs.append(musicID)
                    DispatchQueue.main.async {
                        self.view?.reloadDataTableView()
                    }
                }
            }
        }
    }

}
