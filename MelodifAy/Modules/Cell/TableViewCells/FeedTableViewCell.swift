//
//  FeedTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.03.2025.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    static let cellID = "feedCell"
    
    private let feedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        return view
    }()
    
    private let coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let optionsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "ellipsis", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let addToLibraryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "plus.circle", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .lightGray
        return button
    }()
    
    private let playTheSongButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 14), textColorLabel: .lightGray)
    
    private var gradientLayer: CAGradientLayer?
            
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureWithExt()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureWithExt()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
                feedView.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
        
        gradientLayer?.frame = feedView.bounds
    }
    
    func configureWithExt() {
        contentView.addSubview(feedView)
        feedView.addViews(coverPhotoImageView, songNameLabel, nameLabel, optionsButton, addToLibraryButton, playTheSongButton)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        feedView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: contentView.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, paddingBottom: 10)
        coverPhotoImageView.anchor(top: feedView.topAnchor, left: feedView.leftAnchor, bottom: feedView.bottomAnchor, width: contentView.bounds.size.width * 0.4)
        songNameLabel.anchor(top: feedView.topAnchor, left: coverPhotoImageView.rightAnchor, paddingTop: 10, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: coverPhotoImageView.rightAnchor, paddingTop: 5, paddingLeft: 10)
        optionsButton.anchor(top: feedView.topAnchor, right: feedView.rightAnchor, paddingTop: 10, paddingRight: 10)
        addToLibraryButton.anchor(left: coverPhotoImageView.rightAnchor, bottom: feedView.bottomAnchor, paddingLeft: 10, paddingBottom: 10)
        playTheSongButton.anchor(right: feedView.rightAnchor, bottom: feedView.bottomAnchor, paddingRight: 10, paddingBottom: 10)
    }
    
    func configure(music: MusicModel) {
        coverPhotoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
        nameLabel.text = music.name
    }

}
