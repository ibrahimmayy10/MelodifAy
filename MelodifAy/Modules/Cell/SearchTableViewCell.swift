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
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 14), textColorLabel: .lightGray)
    
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
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        photoImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, width: 50)
        songNameLabel.anchor(top: contentView.topAnchor, left: photoImageView.rightAnchor, paddingTop: 17, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: photoImageView.rightAnchor, paddingLeft: 10)
    }
    
    func configure(music: MusicModel?, user: UserModel?) {
        if let music = music {
            photoImageView.layer.cornerRadius = 0
            photoImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
            songNameLabel.text = music.songName
            nameLabel.text = music.name
        } else if let user = user {
            photoImageView.layer.cornerRadius = 25
            photoImageView.sd_setImage(with: URL(string: user.imageUrl))
            songNameLabel.text = user.name + " " + user.surname
            nameLabel.text = "Sanatçı"
        }
    }

}
