//
//  PreviewViewModel.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 25.11.2024.
//

import Foundation

protocol PreviewViewModelProtocol {
    func getUserName()
    var servicePreview: ServicePreviewProtocol { get }
}

class PreviewViewModel: PreviewViewModelProtocol {
    var servicePreview: ServicePreviewProtocol = ServicePreview()
    weak var view: PreviewViewControllerProtocol?
    
    init(view: PreviewViewControllerProtocol?) {
        self.view = view
    }
    
    func getUserName() {
        servicePreview.fetchUserName { name in
            self.view?.setUsername(name: name)
        }
    }
}
