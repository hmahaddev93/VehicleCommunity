//
//  PKChatCell.swift

//
//  Created by Khatib H. on 4/21/19.
//  //

import UIKit

class PKChatCell: UITableViewCell {

    @IBOutlet weak var imgViUserPhoto: UIImageView!
    @IBOutlet weak var lblWithUserName: UILabel!
    @IBOutlet weak var lblBlockingMark: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCheckedMarker: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
