//
//  RecommendedCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 26.02.2025.
//

import UIKit

class RecommendedCollectionViewCell: UICollectionViewCell {
    static let cellID = "recommendedCell"
    
    private let recommendedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 12), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureWithExt()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureWithExt()
    }
    
    func configureWithExt() {
        contentView.addViews(recommendedImageView, songNameLabel, nameLabel)
        
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        
        recommendedImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: 130)
        songNameLabel.anchor(top: recommendedImageView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 5)
    }
    
    func configure(music: MusicModel) {
        nameLabel.text = music.name
        recommendedImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
    }
}
