//
//  FeedViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.03.2025.
//

import Foundation

protocol FeedViewModelProtocol {
    func getDataMusicOfFollowed(completion: @escaping (Bool) -> Void)
    var serviceFeed: ServiceFeedProtocol { get }
}

class FeedViewModel: FeedViewModelProtocol {    
    var serviceFeed: ServiceFeedProtocol = ServiceFeed()
    var musics = [MusicModel]()
    var users = [UserModel]()
    
    weak var view: FeedViewControllerProtocol?
    
    init(view: FeedViewControllerProtocol) {
        self.view = view
    }
    
    func getDataMusicOfFollowed(completion: @escaping (Bool) -> Void) {
        serviceFeed.fetchFollowingMusic { musics, users in
            guard !musics.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                self.musics = musics
                self.users = users
                self.view?.reloadDataTableView()
                completion(true)
            }
        }
    }
}
