//
//  NewlyReleasedSongCollectionViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 1.03.2025.
//

import UIKit

protocol NewlyReleasedSongCollectionViewCellProtocol: AnyObject {
    func didTapOptionsButton(music: MusicModel)
}

class NewlyReleasedSongCollectionViewCell: UICollectionViewCell {
    static let cellID = "newlyReleasedSongCell"
    
    private let newlyReleasedSongImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        imageView.clipsToBounds = true
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
    
    weak var delegate: NewlyReleasedSongCollectionViewCellProtocol?
    
    var music: MusicModel?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureWithExt()
        addTargetButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureWithExt()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayer()
        addTargetButtons()
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
    
    func addTargetButtons() {
        optionsButton.addTarget(self, action: #selector(optionsButton_Clicked), for: .touchUpInside)
    }
    
    @objc func optionsButton_Clicked() {
        guard let music = music else { return }
        delegate?.didTapOptionsButton(music: music)
    }
    
    func configureWithExt() {
        contentView.addViews(newlyReleasedSongImageView, songNameLabel, nameLabel, optionsButton, addToLibraryButton, playTheSongButton)
        
        contentView.backgroundColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 0.3)
        contentView.layer.cornerRadius = 10
        
        newlyReleasedSongImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, width: contentView.bounds.size.width * 0.4)
        songNameLabel.anchor(top: contentView.topAnchor, left: newlyReleasedSongImageView.rightAnchor, paddingTop: 10, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: newlyReleasedSongImageView.rightAnchor, paddingTop: 5, paddingLeft: 10)
        optionsButton.anchor(top: contentView.topAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingRight: 10)
        addToLibraryButton.anchor(left: newlyReleasedSongImageView.rightAnchor, bottom: contentView.bottomAnchor, paddingLeft: 10, paddingBottom: 10)
        playTheSongButton.anchor(right: contentView.rightAnchor, bottom: contentView.bottomAnchor, paddingRight: 10, paddingBottom: 10)
    }
    
    func configure(music: MusicModel) {
        nameLabel.text = music.name
        newlyReleasedSongImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
        
        self.music = music
    }
}
