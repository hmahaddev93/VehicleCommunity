//
//  EditTextTableViewCell.swift
//  LAVESHMUSIC
//
//  Created by Khatib H. on 3/7/19.
//  Copyright © 2019 LAVESHMUSIC. All rights reserved.
//

import UIKit

class EditTextTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLabel: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
