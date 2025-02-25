//
//  SearchViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.12.2024.
//

import Foundation

protocol SearchViewModelProtocol {
    func getDataUsers()
    func getDataMusics()
    var serviceSearch: ServiceSearchProtocol { get }
}

class SearchViewModel: SearchViewModelProtocol {
    var serviceSearch: ServiceSearchProtocol = ServiceSearch()
    var musics = [MusicModel]()
    var users = [UserModel]()
    
    weak var view: SearchViewControllerProtocol?
    
    init(view: SearchViewControllerProtocol) {
        self.view = view
    }
    
    func getDataUsers() {
        serviceSearch.fetchUsers { users in
            DispatchQueue.main.async {
                self.users = users
                self.view?.reloadDataTableView()
            }
        }
    }
    
    func getDataMusics() {
        serviceSearch.fetchMusics { musics in
            DispatchQueue.main.async {
                self.musics = musics
                self.view?.reloadDataTableView()
            }
        }
    }
}
