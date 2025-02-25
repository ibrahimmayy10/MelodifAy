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
    var serviceAccount: ServiceAccountProtocol { get }
}

class AccountViewModel: AccountViewModelProtocol {
    var serviceAccount: ServiceAccountProtocol = ServiceAccount()
    weak var view: AccountViewControllerProtocol?
    
    var musics = [MusicModel]()
    
    init(view: AccountViewControllerProtocol) {
        self.view = view
    }
    
    func getDataUserInfo(completion: @escaping (Bool) -> Void) {
        serviceAccount.fetchUserInfo { user in
            guard !user.imageUrl.isEmpty else {
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
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
