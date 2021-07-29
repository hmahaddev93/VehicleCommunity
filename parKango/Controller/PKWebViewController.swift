//
//  PKWebViewController.swift

//
//  Created by Khatib H. on 3/24/19.
//  //

import UIKit
import WebKit

class PKWebViewController: UIViewController {

    @IBOutlet weak var viWeb: WKWebView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    var browseURL = ""
    var pageTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        btnDone.layer.masksToBounds = true
        btnDone.layer.cornerRadius = btnDone.frame.size.height / 2.0
        btnDone.layer.borderColor = ColorPalette.pkRed.cgColor
        btnDone.layer.borderWidth = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if browseURL.contains("facebook.com"){
            self.lblTitle.text = "FACEBOOK"
        }
        else if browseURL.contains("twitter.com")
        {
            self.lblTitle.text = "TWITTER"
        }
        else if browseURL.contains("instagram.com")
        {
            self.lblTitle.text = "INSTAGRAM"
        }
        else if browseURL.contains("snapchat.com")
        {
            self.lblTitle.text = "SNAPCHAT"
        }
        else {
            self.lblTitle.text = self.pageTitle
        }
            
        self.viWeb.load(URLRequest(url: URL(string: self.browseURL)!))
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Event Handlers
    @IBAction func onDone(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }

}
