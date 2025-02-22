//
//  MyPostsTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 27.11.2024.
//

import UIKit

class MyPostsTableViewCell: UITableViewCell {
    
    static let cellID = "postCell"
    
    private let myPostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .white)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 14), textColorLabel: .lightGray)
    private let likeCountLabel = Labels(textLabel: "250", fontLabel: .boldSystemFont(ofSize: 14), textColorLabel: .white)
    
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
        contentView.addViews(myPostImageView, heartImageView, songNameLabel, nameLabel, likeCountLabel)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        myPostImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, width: 55)
        songNameLabel.anchor(top: contentView.topAnchor, left: myPostImageView.rightAnchor, paddingTop: 20, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: myPostImageView.rightAnchor, paddingLeft: 10)
        heartImageView.anchor(right: contentView.rightAnchor, centerY: contentView.centerYAnchor, paddingRight: 10, width: 20, height: 20)
        likeCountLabel.anchor(right: heartImageView.leftAnchor, centerY: contentView.centerYAnchor)
    }
    
    func configure(music: MusicModel) {
        nameLabel.text = music.name
        myPostImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
    }

}
