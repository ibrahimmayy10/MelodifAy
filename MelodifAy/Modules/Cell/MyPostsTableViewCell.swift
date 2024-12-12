//
//  MyPostsTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 27.11.2024.
//

import UIKit

class MyPostsTableViewCell: UITableViewCell {
    
    static let cellID = "postCell"
    
    private let cellBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        return view
    }()
    
    private let myPostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let heartImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let songNameLabel = Labels(textLabel: "", fontLabel: .boldSystemFont(ofSize: 17), textColorLabel: .black)
    private let nameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .darkGray)
    private let likeCountLabel = Labels(textLabel: "250", fontLabel: .boldSystemFont(ofSize: 16), textColorLabel: .systemRed)
    
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
        contentView.addSubview(cellBarView)
        cellBarView.addViews(myPostImageView, heartImageView, songNameLabel, nameLabel, likeCountLabel)
        
        contentView.backgroundColor = .white
        
        cellBarView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, bottom: contentView.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10, paddingBottom: 10)
        myPostImageView.anchor(top: cellBarView.topAnchor, left: cellBarView.leftAnchor, bottom: cellBarView.bottomAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, width: 60)
        songNameLabel.anchor(top: cellBarView.topAnchor, left: myPostImageView.rightAnchor, paddingTop: 15, paddingLeft: 10)
        nameLabel.anchor(top: songNameLabel.bottomAnchor, left: myPostImageView.rightAnchor, paddingLeft: 10)
        heartImageView.anchor(right: cellBarView.rightAnchor, centerY: cellBarView.centerYAnchor, paddingRight: 10, width: 20, height: 20)
        likeCountLabel.anchor(right: heartImageView.leftAnchor, centerY: cellBarView.centerYAnchor)
    }
    
    func configure(music: MusicModel) {
        nameLabel.text = music.name
        myPostImageView.sd_setImage(with: URL(string: music.coverPhotoURL))
        songNameLabel.text = music.songName
    }

}
