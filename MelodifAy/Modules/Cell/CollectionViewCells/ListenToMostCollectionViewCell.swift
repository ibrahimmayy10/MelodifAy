//
//  ListenToMostCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 1.03.2025.
//

import UIKit

class ListenToMostCollectionViewCell: UICollectionViewCell {
    static let cellID = "listenToMostCell"
    
    private let listenToMostImageView: UIImageView = {
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
        contentView.addViews(listenToMostImageView, songNameLabel, nameLabel)
        
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        
        listenToMostImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: 130)
        songNameLabel.anchor(top: listenToMostImageView.bottomAnchor, left: contentView.leftAnchor, paddingTop: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: contentView.leftAnchor, paddingTop: 5)
    }
    
    func configure(music: MusicModel) {
        nameLabel.text = music.name
        listenToMostImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
    }
}
