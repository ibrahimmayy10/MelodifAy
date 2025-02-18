//
//  UserDetailsViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 16.01.2025.
//

import Foundation

protocol UserDetailsViewModelProtocol {
    func getDataMusic(userID: String)
    
    var serviceUserDetails: ServiceUserDetailsProtocol { get }
}

class UserDetailsViewModel: UserDetailsViewModelProtocol {
    var serviceUserDetails: ServiceUserDetailsProtocol = ServiceUserDetails()
    weak var view: UserDetailsViewControllerProtocol?
    
    var musics = [MusicModel]()
    
    init(view: UserDetailsViewControllerProtocol) {
        self.view = view
    }
    
    func getDataMusic(userID: String) {
        serviceUserDetails.fetchUserPosts(userID: userID) { musics in
            self.musics = musics
            self.view?.reloadDataTableView()
        }
    }
}
