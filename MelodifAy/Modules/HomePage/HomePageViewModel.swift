//
//  HomePageViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.02.2025.
//

import Foundation

protocol HomePageViewModelProtocol {
    func getDataMusics()
    var serviceHomePage: ServiceHomePageProtocol { get }
}

class HomePageViewModel: HomePageViewModelProtocol {
    var serviceHomePage: ServiceHomePageProtocol = ServiceHomePage()
    var musics = [MusicModel]()
    
    weak var view: HomePageViewControllerProtocol?
    
    init(view: HomePageViewControllerProtocol) {
        self.view = view
    }
    
    func getDataMusics() {
        serviceHomePage.fetchFollowingMusic { musics, error in
            DispatchQueue.main.async {
                self.musics = musics
                self.view?.reloadDataTableView()
            }
        }
    }
}
