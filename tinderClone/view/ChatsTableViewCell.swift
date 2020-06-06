//
//  ChatsTableViewCell.swift
//  tinderClone
//
//  Created by Nishant Thakur on 05/06/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.cornerRadius = userImage.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
