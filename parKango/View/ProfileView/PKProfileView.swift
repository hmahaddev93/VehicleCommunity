//
//  PKProfileView.swift

//
//  Created by Khatib H. on 3/10/19.
//  //

import UIKit

class PKProfileView: UIView {
    
    @IBOutlet weak var viContents: UIView!
    @IBOutlet weak var imgViPhoto: UIImageView!
    @IBOutlet weak var imgViGender: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var markVerified: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viPhotoButtons: UIView!
    
    @IBOutlet weak var btnHashtag: UIButton!
    @IBOutlet weak var btnFavorite: UIButton!
    
    @IBOutlet weak var btnLike: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
