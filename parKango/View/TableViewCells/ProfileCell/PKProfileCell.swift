//
//  PKProfileCell.swift

//
//  Created by Khatib H. on 3/17/19.
//  //

import UIKit

class PKProfileCell: UITableViewCell {

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnHashtag: UIButton!
    @IBOutlet weak var imgViGender: UIImageView!
    @IBOutlet weak var imgViPhoto: UIImageView!
    @IBOutlet weak var lblMakeModel: UILabel!
    @IBOutlet weak var markVerified: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
