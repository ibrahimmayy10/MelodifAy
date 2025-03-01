//
//  SingerYouLikeCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.02.2025.
//

import UIKit

class SingerYouLikeCollectionViewCell: UICollectionViewCell {
    static let cellID = "singersYouLikeCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    private let nameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureWithExt()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureWithExt()
    }
    
    func configureWithExt() {
        contentView.addViews(profileImageView, nameLabel)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        contentView.layer.cornerRadius = 10
        
        nameLabel.textAlignment = .center
        
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, width: 100, height: 100)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5)
    }
    
    func configure(user: UserModel) {
        profileImageView.sd_setImage(with: URL(string: user.imageUrl))
        nameLabel.text = user.name + " " + user.surname
    }
}
