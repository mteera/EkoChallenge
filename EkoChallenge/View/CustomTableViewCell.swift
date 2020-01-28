//
//  CustomTableViewCell.swift
//  EkoChallenge
//
//  Created by Chace Teera on 18/01/2020.
//  Copyright © 2020 chaceteera. All rights reserved.
//

import UIKit
import Kingfisher


protocol CustomTableViewCellDelegate {
    func handleFavourite(_ user: User, indexPath: IndexPath)
}

class CustomTableViewCell: UITableViewCell {
    
    var delegate: CustomTableViewCellDelegate?
    var indexPath: IndexPath!
    var user: User? {
        didSet {
            guard let user = user else { return}
            loginLabel.text = user.login
            githubUrlLabel.text = user.url
            accountTypeLabel.text = user.type
            adminLabel.text = user.siteAdmin ? "Admin" : ""
            starButton.tintColor = user.isFavourite ? .systemYellow : .systemGray5

            if user.avatarUrl == "" {
                avatarImageView.image = UIImage(named: "github")

            }
            let url = URL(string: user.avatarUrl)
            let placeholder = UIImage(named: "github")

            avatarImageView.kf.setImage(with: url, placeholder: placeholder)



        }
    }
    
    lazy var avatarImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.tintColor = .systemGray5
        return imageView
    }()
    
    
    lazy var loginLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    lazy var githubUrlLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left

        return label
    }()
    
    lazy var accountTypeLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)

        return label
    }()
    
    lazy var adminLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(displayP3Red: 0, green: 153, blue: 153, alpha: 1)

        return label
    }()
    
    lazy var starButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "fave_star"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        return button
    }()
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        addSubview(avatarImageView)

        accessoryView = starButton
        starButton.addTarget(self, action: #selector(handleFavourite), for: .touchUpInside)
        
        avatarImageView.anchor(nil, left: leftAnchor, bottom: nil, right: nil, leftConstant: 16, widthConstant: 50, heightConstant: 50)
        avatarImageView.centerYInSuperview()

        
        let textStackView = UIStackView(arrangedSubviews: [loginLabel, githubUrlLabel, accountTypeLabel])
        textStackView.spacing = 4
        textStackView.alignment = .leading
        textStackView.axis = .vertical
        
        addSubview(textStackView)

        
        textStackView.anchor(topAnchor, left: avatarImageView.rightAnchor, bottom: bottomAnchor, right: nil, topConstant: 10, leftConstant: 8, bottomConstant: 10)
        textStackView.centerYInSuperview()
        
        addSubview(adminLabel)
        adminLabel.anchor(loginLabel.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, rightConstant: 16)
        
    }
    
    @objc private func handleFavourite() {
        guard let user = user else { return }
        delegate?.handleFavourite(user, indexPath: indexPath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

