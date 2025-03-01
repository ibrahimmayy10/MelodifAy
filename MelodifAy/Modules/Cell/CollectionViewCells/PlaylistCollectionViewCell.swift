//
//  PlaylistCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 27.02.2025.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    static let cellID = "playlistCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let playlistNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 12), textColorLabel: .white)
    
    private var gradientLayer: CAGradientLayer?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureWithExt()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureWithExt()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayer()
    }
    
    private func updateGradientLayer() {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer?.colors = [
                UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0).cgColor,
                UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0).cgColor
            ]
            gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer?.cornerRadius = 10
            
            if let gradientLayer = gradientLayer {
                contentView.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        
        gradientLayer?.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playlistImageView.image = nil
    }
    
    func configureWithExt() {
        contentView.addViews(playlistImageView, playlistNameLabel)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        contentView.layer.cornerRadius = 10
        
        playlistImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 0.5, paddingLeft: 0.5, paddingBottom: 0.5, width: 60, height: 60)
        playlistNameLabel.anchor(top: contentView.topAnchor, left: playlistImageView.rightAnchor, right: contentView.rightAnchor, bottom: contentView.bottomAnchor, paddingLeft: 5)
    }
    
    func configure(music: MusicModel) {
        playlistImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        playlistNameLabel.text = music.songName
    }
}
