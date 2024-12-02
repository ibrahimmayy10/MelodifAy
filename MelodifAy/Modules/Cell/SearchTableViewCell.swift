//
//  SearchTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 2.12.2024.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    static let cellID = "searchCell"
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 17), textColorLabel: .black)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .darkGray)
    
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
        contentView.addViews(photoImageView, songNameLabel, nameLabel)
        
        contentView.backgroundColor = .white
        
        photoImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, width: 60)
        songNameLabel.anchor(top: contentView.topAnchor, left: photoImageView.rightAnchor, paddingTop: 15, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: photoImageView.rightAnchor, paddingLeft: 10)
    }
    
    func configure(music: MusicModel?, user: UserModel?) {
        if let music = music {
            photoImageView.layer.cornerRadius = 0
            photoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
            songNameLabel.text = music.songName
            nameLabel.text = music.name
        } else if let user = user {
            photoImageView.layer.cornerRadius = 30
            photoImageView.sd_setImage(with: URL(string: user.imageUrl))
            songNameLabel.text = user.name + " " + user.surname
            nameLabel.text = "Sanatçı"
        }
    }

}
