//
//  FeedTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.03.2025.
//

import UIKit
import Firebase

protocol FeedTableViewCellDelegate: AnyObject {
    func didTapOptionsButton(music: MusicModel)
    func didTapLikeButton(music: MusicModel)
}

class FeedTableViewCell: UITableViewCell {

    static let cellID = "feedCell"
    
    private let coverPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
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
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "heart", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "message", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let playTheSongButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "play.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeImage, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let usernameAndSongNameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .lightGray)
    private let likeCountLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .white)
    
    weak var delegate: FeedTableViewCellDelegate?
    var music: MusicModel?
    
    private var isLiked = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureWithExt()
        addTargetButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureWithExt()
        addTargetButtons()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addTargetButtons() {
        optionsButton.addTarget(self, action: #selector(optionsButton_Clicked), for: .touchUpInside)
        addToLibraryButton.addTarget(self, action: #selector(addToLibraryButton_Clicked), for: .touchUpInside)
    }
    
    @objc func optionsButton_Clicked() {
        guard let music = music else { return }
        delegate?.didTapOptionsButton(music: music)
    }
    
    private func updateAddToLibraryButton() {
        let systemName = isLiked ? "heart.fill" : "heart"
        addToLibraryButton.tintColor = isLiked ? UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0) : .white
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: systemName, withConfiguration: largeConfig)
        addToLibraryButton.setImage(largeImage, for: .normal)
    }
    
    @objc func addToLibraryButton_Clicked() {
        guard let music = music else { return }
        delegate?.didTapLikeButton(music: music)
        isLiked.toggle()
        updateAddToLibraryButton()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.addToLibraryButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.addToLibraryButton.transform = .identity
            }
        }
    }
    
    func updateLikeStatus(isLiked: Bool) {
        self.isLiked = isLiked
        updateAddToLibraryButton()
    }
    
    func configureWithExt() {
        contentView.addViews(coverPhotoImageView, profileImageView, usernameAndSongNameLabel, optionsButton, addToLibraryButton, commentButton, likeCountLabel)
        coverPhotoImageView.addViews(playTheSongButton)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 10, paddingLeft: 10, width: 50, height: 50)
        usernameAndSongNameLabel.anchor(left: profileImageView.rightAnchor, centerY: profileImageView.centerYAnchor, paddingLeft: 10)
        optionsButton.anchor(right: contentView.rightAnchor, centerY: profileImageView.centerYAnchor, paddingRight: 10)
        
        coverPhotoImageView.anchor(top: profileImageView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: addToLibraryButton.topAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, paddingBottom: 15)
        coverPhotoImageView.heightAnchor.constraint(equalTo: coverPhotoImageView.widthAnchor, multiplier: 0.6).isActive = true
        playTheSongButton.anchor(centerX: coverPhotoImageView.centerXAnchor, centerY: coverPhotoImageView.centerYAnchor)
        addToLibraryButton.anchor(left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingLeft: 10, paddingBottom: 10)
        likeCountLabel.anchor(left: addToLibraryButton.rightAnchor, centerY: addToLibraryButton.centerYAnchor, paddingLeft: 2)
        commentButton.anchor(left: likeCountLabel.rightAnchor, centerY: addToLibraryButton.centerYAnchor, paddingLeft: 10)
    }
    
    func configure(music: MusicModel, user: UserModel, isLiked: Bool) {
        coverPhotoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        profileImageView.sd_setImage(with: URL(string: user.imageUrl))
        usernameAndSongNameLabel.text = "\(music.name) / \(music.songName)"
        likeCountLabel.text = "\(music.likes?.count ?? 0)"
        
        self.music = music
        self.isLiked = isLiked
        updateAddToLibraryButton()
    }

}
