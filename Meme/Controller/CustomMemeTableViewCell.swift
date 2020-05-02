//
//  CustomMemeTableViewCell.swift
//  MemeMe
//
//  Created by bhuvan on 05/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class CustomMemeTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var memeTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
