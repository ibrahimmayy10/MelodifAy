//
//  OptionsTableViewCell.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 6.03.2025.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    static let cellID = "optionsCell"
    
    private let optionsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let optionsLabel = Labels(textLabel: "", fontLabel: .systemFont(ofSize: 16), textColorLabel: .lightGray)
    
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
        contentView.addViews(optionsImageView, optionsLabel)
        
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        optionsImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, paddingLeft: 10)
        optionsLabel.anchor(top: contentView.topAnchor, left: optionsImageView.rightAnchor, bottom: contentView.bottomAnchor, paddingLeft: 10)
    }
    
    func configure(options: Options) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .large)
        optionsImageView.image = UIImage(systemName: options.imageName, withConfiguration: largeConfig)
        optionsLabel.text = options.text
    }

}
