//
//  PlaylistTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 6.03.2025.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    static let cellID = "playlistCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .lightGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private let downloadImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.down.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 31/255, green: 84/255, blue: 147/255, alpha: 1.0)
        return imageView
    }()
    
    let selectImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let playlistNameLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .white)
    private let musicCountLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 12), textColorLabel: .lightGray)
    
    var isSelectedPlaylist: Bool = false {
        didSet {
            selectImageView.image = UIImage(systemName: isSelectedPlaylist ? "checkmark.circle.fill" : "circle")
        }
    }
    
    var isInPlaylist: Bool = false
    
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
        contentView.addViews(playlistImageView, playlistNameLabel, downloadImageView, musicCountLabel, selectImageView)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        playlistImageView.anchor(top: contentView.topAnchor,
                                 left: contentView.leftAnchor,
                                 bottom: contentView.bottomAnchor,
                                 paddingTop: 5,
                                 paddingLeft: 10,
                                 paddingBottom: 5,
                                 width: 50)
        
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
        
        musicCountLabel.anchor(top: playlistNameLabel.bottomAnchor,
                               left: downloadImageView.rightAnchor,
                               paddingTop: 5,
                               paddingLeft: 3)
        
        selectImageView.anchor(top: contentView.topAnchor,
                               right: contentView.rightAnchor,
                               bottom: contentView.bottomAnchor,
                               paddingRight: 10,
                               width: 25,
                               height: 25)
    }
    
    func configure(playlist: PlaylistModel, isSelected: Bool) {
        playlistImageView.sd_setImage(with: URL(string: playlist.imageUrl))
        playlistNameLabel.text = playlist.name
        musicCountLabel.text = "\(playlist.musicIDs.count) şarkı"
        
        isSelectedPlaylist = isSelected
        
        if isInPlaylist {
            selectImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            selectImageView.image = isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        }
    }

}
