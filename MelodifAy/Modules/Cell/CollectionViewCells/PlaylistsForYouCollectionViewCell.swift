//
//  PlaylistsForYouCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.02.2025.
//

import UIKit

class PlaylistsForYouCollectionViewCell: UICollectionViewCell {
    static let cellID = "playlistForYouCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let playlistNameLabel = Labels(textLabel: "Daily Mix 01", fontLabel: .boldSystemFont(ofSize: 12), textColorLabel: .white)
    private let singerNameLabel = Labels(textLabel: "Duman, Cem Karaca, Emre Fel, Erkin Koray, Barış Akarsu, Barış Manço, Müslüm Gürses, Can Bonomo, Sezen Aksu, Sertab Erener, Feridun Düzağaç", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureWithExt()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureWithExt()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playlistImageView.image = nil
    }
    
    func configureWithExt() {
        contentView.addViews(playlistImageView, playlistNameLabel, singerNameLabel)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        contentView.layer.cornerRadius = 10
        
        singerNameLabel.numberOfLines = 2
        
        playlistImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingLeft: 5, paddingRight: 5, height: 150)
        playlistNameLabel.anchor(top: playlistImageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingLeft: 5)
        singerNameLabel.anchor(top: playlistNameLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5)
    }
    
    func configure(music: MusicModel) {
        playlistImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
    }
}
