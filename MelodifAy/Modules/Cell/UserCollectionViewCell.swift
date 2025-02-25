//
//  UserCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 24.02.2025.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    static let cellID = "userPostCell"
    
    private let postView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 12), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)
    private let likeCountLabel = Labels(textLabel: "250", fontLabel: .systemFont(ofSize: 12), textColorLabel: .white)
    
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
                postView.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        
        gradientLayer?.frame = postView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.image = nil
        songNameLabel.text = ""
        nameLabel.text = ""
    }
    
    func configureWithExt() {
        contentView.addSubview(postView)
        postView.addViews(postImageView, heartImageView, songNameLabel, nameLabel, likeCountLabel)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        postView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: contentView.bottomAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, paddingBottom: 5)
        postImageView.anchor(top: postView.topAnchor, left: postView.leftAnchor, right: postView.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5, height: 130)
        songNameLabel.anchor(top: postImageView.bottomAnchor, left: postView.leftAnchor, paddingTop: 10, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: postView.leftAnchor, paddingTop: 5, paddingLeft: 10)
        heartImageView.anchor(top: songNameLabel.bottomAnchor, right: postView.rightAnchor, paddingTop: 5, paddingRight: 10, width: 15, height: 15)
        likeCountLabel.anchor(right: heartImageView.leftAnchor, centerY: heartImageView.centerYAnchor)
    }
    
    func configure(music: MusicModel) {
        nameLabel.text = music.name
        postImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
    }
}
