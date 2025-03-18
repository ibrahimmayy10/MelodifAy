//
//  UserPlaylistTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 11.03.2025.
//

import UIKit

protocol UserPlaylistTableViewCellProtocol: AnyObject {
    func didTapOptionsButton(music: MusicModel)
}

class UserPlaylistTableViewCell: UITableViewCell {
    
    static let cellID = "userPlaylistCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let downloadImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
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
    
    private let playlistNameLabel = Labels(textLabel: "Daily Mix 01", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)
    
    var music: MusicModel?
    
    weak var delegate: UserPlaylistTableViewCellProtocol?

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
    }
    
    @objc func optionsButton_Clicked() {
        guard let music = music else { return }
        delegate?.didTapOptionsButton(music: music)
    }
    
    func configureWithExt() {
        contentView.addViews(playlistImageView, playlistNameLabel, downloadImageView, nameLabel, optionsButton)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        playlistImageView.anchor(top: contentView.topAnchor,
                                 left: contentView.leftAnchor,
                                 bottom: contentView.bottomAnchor,
                                 paddingTop: 5,
                                 paddingLeft: 10,
                                 paddingBottom: 5,
                                 width: 60)
        
        playlistNameLabel.anchor(top: playlistImageView.topAnchor,
                                 left: playlistImageView.rightAnchor,
                                 paddingTop: 7,
                                 paddingLeft: 10)
        
        downloadImageView.anchor(top: playlistNameLabel.bottomAnchor,
                                 left: playlistImageView.rightAnchor,
                                 paddingTop: 5, paddingLeft: 10,
                                 width: 16,
                                 height: 16)
        
        nameLabel.anchor(top: playlistNameLabel.bottomAnchor,
                               left: downloadImageView.rightAnchor,
                               paddingTop: 5,
                               paddingLeft: 3)
        
        optionsButton.anchor(top: contentView.topAnchor,
                             right: contentView.rightAnchor,
                             bottom: contentView.bottomAnchor,
                             paddingRight: 10)
    }
    
    func configure(playlist: PlaylistModel, name: String) {
        playlistImageView.sd_setImage(with: URL(string: playlist.imageUrl))
        playlistNameLabel.text = playlist.name
        nameLabel.text = "Çalma Listesi - \(name)"
        
        optionsButton.isHidden = true
    }
    
    func configure(music: MusicModel) {
        playlistImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        playlistNameLabel.text = music.songName
        nameLabel.text = music.name
        
        self.music = music
    }
    
    func configure(user: UserModel) {
        playlistImageView.sd_setImage(with: URL(string: user.imageUrl))
        playlistNameLabel.text = user.name + " " + user.surname
        nameLabel.text = user.username
        
        downloadImageView.isHidden = true
        optionsButton.isHidden = true
        
        nameLabel.anchor(top: playlistNameLabel.bottomAnchor,
                         left: playlistImageView.rightAnchor,
                         paddingTop: 5, paddingLeft: 9)
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.needsUpdateConstraints()
    }

}
