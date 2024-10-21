//
//  SeperatorView.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 4.10.2024.
//

import UIKit

class SeperatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor){
        self.init(frame: .zero)
        setView(color: color)
    }
    
    func setView(color: UIColor){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color
    }

}
