//
//  PKLike.swift

//
//  Created by Khatib H. on 8/14/19.
//  //

import UIKit

class PKLike: NSObject {
    var uid: String?
    var likerId: String?
    var likedDate: Date?
    
    func setLike(withLikeDic: [String : Any]) {
        self.uid = withLikeDic["uid"] as? String
        self.likerId = withLikeDic["liker_id"] as? String
        self.likedDate = Date(timeIntervalSince1970: withLikeDic["liked_date"] as! TimeInterval)
    }
}
