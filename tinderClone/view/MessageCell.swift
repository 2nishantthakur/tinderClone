//
//  MessageCell.swift
//  tinderClone
//
//  Created by Nishant Thakur on 06/06/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
  
    @IBOutlet var rightCornerView: UIView!
    @IBOutlet var leftCornerView: UIView!
    @IBOutlet var messageBubble: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var otherUserImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = messageBubble.frame.height / 5
        otherUserImage.layer.cornerRadius = otherUserImage.frame.width / 2
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
