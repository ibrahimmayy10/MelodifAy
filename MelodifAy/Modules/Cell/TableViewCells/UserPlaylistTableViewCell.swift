//
//  UserPlaylistTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 11.03.2025.
//

import UIKit

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
    
    private let playlistNameLabel = Labels(textLabel: "Daily Mix 01", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)

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
    
    func configureWithExt() {
        contentView.addViews(playlistImageView, playlistNameLabel, downloadImageView, nameLabel)
        
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
        
        downloadImageView.anchor(top:
                                    playlistNameLabel.bottomAnchor,
                                 left: playlistImageView.rightAnchor,
                                 paddingTop: 5, paddingLeft: 10,
                                 width: 16,
                                 height: 16)
        
        nameLabel.anchor(top: playlistNameLabel.bottomAnchor,
                               left: downloadImageView.rightAnchor,
                               paddingTop: 5,
                               paddingLeft: 3)
    }
    
    func configure(playlist: PlaylistModel, name: String) {
        playlistImageView.sd_setImage(with: URL(string: playlist.imageUrl))
        playlistNameLabel.text = playlist.name
        nameLabel.text = "Çalma Listesi - \(name)"
    }
    
    func configure(music: MusicModel) {
        playlistImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        playlistNameLabel.text = music.songName
        nameLabel.text = music.name
    }

}
