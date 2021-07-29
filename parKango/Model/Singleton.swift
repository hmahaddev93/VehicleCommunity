//
//  Singleton.swift
//
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation

class Singleton {
    
    //MARK: Shared Instance
    
    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    //MARK: Local Variable
    
    var arrAllMakes = [String]()
    var arrVehicleMakes = [String]()
    var arrCycleMakes = [String]()
    
    var myUser: PKUser = PKUser.init()
    var dicRegisterValues = ["uid": "",
                             "email": "",
                             "username": "",
                             "gender": PKGender.none,
                             "v_type": PKVehicleType.none,
                             "v_make": "",
                             "v_model": "",
                             "zipcode": "",
                             "LFLP": "",
                             "hashtag": "",
                             "photos": [String](),
                             "social_links": [String](),
                             "is_instagram_login": false,
                             "fcm_token": "",
                             "createdTimestamp": ""] as [String : Any]
    
    var fcmToken = ""
    var instaAccessToken = ""
    var instaUserInfo = [String: Any]()
                          
    /*//MARK: Init
    
    convenience init() {
        self.init(array : [])
    }
    
    //MARK: Init Array
    
    init( array : [Dictionary]) {
        arrVideosInDraft = array
    }*/
    
    //MARK: General Methods
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidUSZipCode(postalCode:String) -> Bool{
        let postalcodeRegex = "^[0-9]{5}(-[0-9]{4})?$"
        let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
        return pinPredicate.evaluate(with: postalCode) as Bool
    }
    
    //func boldSubString(fromString: String, subString: String, font: UIFont, boldColor: UIColor) -> NSAttributedString {
    //    return attributedString(from: fromString, boldRange: fromString.lineRange(of: subString),font: font , boldColor: boldColor)
    //}
    
    func videoSnapshot(filePathLocal: String) -> UIImage? {
        
        let asset = AVAsset.init(url: URL.init(string: filePathLocal)!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage.init(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func setVideoSnapshot(filePathLocal: String, forImageView:UIImageView) {
        
        let asset = AVAsset.init(url: URL.init(string: filePathLocal)!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            forImageView.image = UIImage.init(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
        }
    }
    
    /*func attributedString(from string: String, boldRange: NSRange?, font: UIFont, boldColor: UIColor) -> NSAttributedString {
        let attrs = [
            NSAttributedStringKey.font: font
        ]
        let boldAttribute = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize),
            NSAttributedStringKey.foregroundColor: boldColor
            ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = boldRange {
            attrStr.setAttributes(boldAttribute, range: range)
        }
        return attrStr
    }*/
    
    func stringDateAndTimeForNow() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/yyyy - HH:mm a"
        return dateFormatter.string(from: Date())
    }
    
    func stringDateAndTimeForApp(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy - HH:mm a"
        return dateFormatter.string(from: date)
    }
    
    func stringDateForApp(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    
    func calculateDistanceInMeters(fromLatitude:Double, fromLongitude: Double, toLatitude:Double, toLongitude:Double) -> Double
    {
        let coordinate0 = CLLocation(latitude: fromLatitude, longitude: fromLongitude)
        let coordinate1 = CLLocation(latitude: toLatitude, longitude: toLongitude)
        
        return coordinate0.distance(from: coordinate1) 
    }
    
    //MARK: App Methods
    
    func sendCreateRequestForNotification(withDeviceGroup:[String])
    {
        
        let parameters = ["operation": "create",
                          "notification_key_name": String(format: "abtest332_%@", self.myUser.uid!),
                          "registration_ids": withDeviceGroup
            ] as [String : Any]
        
        //create the url with URL
        let url = URL(string: "https://fcm.googleapis.com/fcm/notification")!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("key=" + Constants.Keys.firebase_fcm_api_key, forHTTPHeaderField: "Authorization")
        request.addValue(Constants.Keys.firebase_fcm_sender_id, forHTTPHeaderField: "project_id")
        
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func sendMessageTo(targetUserToken:String, msgTitle:String, msgBody:String)
    {
        
        let messageData = ["body":"This is a Firebase Cloud Messaging Topic Message!",
                           "title":"FCM Message"]
        
        let parameters = ["to": targetUserToken,
                          "notification": messageData
            ] as [String : Any]
        
        //create the url with URL
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("key=" + Constants.Keys.firebase_fcm_api_key, forHTTPHeaderField: "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func sendNotificationTo(targetUserToken:String, msgTitle:String, msgBody:String, type:String)
    {
        let messageData = ["body": msgBody,
                           "title": msgTitle,
                           "msg_type": type]
        
        let parameters = ["to": targetUserToken,
                          "notification": messageData
            ] as [String : Any]
        
        //create the url with URL
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("key=" + Constants.Keys.firebase_fcm_api_key, forHTTPHeaderField: "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getAppAlert(withMsg:String) -> UIAlertController {
        let alert = UIAlertController(title: APP_NAME, message: withMsg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: {
                
            })
        }))
        return alert
    }
    
    func getAlertWith(title: String, andMsg:String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: andMsg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: {
            })
        }))
        return alert
    }
    
    func getErrorAlert(withError:Error) -> UIAlertController {
        let alert = UIAlertController(title: "Error", message: withError.localizedDescription , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: {
                
            })
        }))
        return alert
    }
    
    func addBottomBlackGradient(toView:UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: toView.frame.size.height)
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        toView.layer.addSublayer(gradient)
    }
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
