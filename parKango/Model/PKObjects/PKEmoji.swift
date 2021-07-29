//
//  PKEmoji.swift

//
//  Created by Khatib H. on 4/3/19.
//  //

import UIKit
import Firebase

class PKEmoji: NSObject {
    
    var emojiId: String?
    var imageURL: String?
    var linkURLString = ""
    var type: Int!
    
    required override init() {
    }
    
    func setEmoji(withDataSnapshot: DataSnapshot) {
        let value = withDataSnapshot.value as? NSDictionary
        
        emojiId = value?["id"] as? String
        imageURL = value?["image"] as? String
        
        if ((value?["link_url"]) != nil)
        {
            linkURLString = value?["link_url"] as! String
        }
        type = (value?["type"] as! Int)

    }

}
