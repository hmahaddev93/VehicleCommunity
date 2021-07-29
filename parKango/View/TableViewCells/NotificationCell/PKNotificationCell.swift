//
//  PKNotificationCell.swift

//
//  Created by Khatib H. on 3/17/19.
//  //

import UIKit

class PKNotificationCell: UITableViewCell {

    @IBOutlet weak var imgViThumb: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
