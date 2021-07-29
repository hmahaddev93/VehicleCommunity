//
//  PKInstagramAuthViewController.swift

//
//  Created by Khatib H. on 4/27/19.
//  //

import UIKit

class PKInstagramAuthViewController: UIViewController, UIWebViewDelegate {

    //@IBOutlet weak var webViInstagram: WKWebView!
    @IBOutlet weak var webViInstagram: UIWebView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var nInstaAuthMode = PKInstagramAuthMode.login
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnDone.layer.masksToBounds = true
        btnDone.layer.cornerRadius = btnDone.frame.size.height / 2.0
        btnDone.layer.borderColor = ColorPalette.pkRed.cgColor
        btnDone.layer.borderWidth = 1.0
        
        //let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [InstagramAPI.INSTAGRAM_AUTH_URL_PREFIX,InstagramAPI.INSTAGRAM_CLIENT_ID,InstagramAPI.INSTAGRAM_REDIRECT_URI, InstagramAPI.INSTAGRAM_SCOPE ])
        
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&DEBUG=True", arguments: [InstagramAPI.INSTAGRAM_AUTH_URL_PREFIX,InstagramAPI.INSTAGRAM_CLIENT_ID,InstagramAPI.INSTAGRAM_REDIRECT_URI])

        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        webViInstagram.loadRequest(urlRequest)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    // MARK: - UIWebViewDelegate Methods
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }
    
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(InstagramAPI.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        print("Instagram authentication token ==", authToken)
        //INSTAGRAM_IDS.INSTAGRAM_USER_TOCKEN = authToken
        //UserDefaults.standard.setValue(authToken, forKey: "INSTAGRAM_USER_TOKEN")
        
        self.sharedManager.instaAccessToken = authToken
        if self.nInstaAuthMode == PKInstagramAuthMode.login {
            NotificationCenter.default.post(name: NSNotification.Name("instaLoginSuccess"), object: nil)
        }
        else if self.nInstaAuthMode == PKInstagramAuthMode.verifyProfile1 {
            NotificationCenter.default.post(name: NSNotification.Name("instaVerifySuccess1"), object: authToken)
        }
        else if self.nInstaAuthMode == PKInstagramAuthMode.verifyProfile2 {
            NotificationCenter.default.post(name: NSNotification.Name("instaVerifySuccess2"), object: authToken)
        }
        else if self.nInstaAuthMode == PKInstagramAuthMode.verifyProfile3 {
            NotificationCenter.default.post(name: NSNotification.Name("instaVerifySuccess3"), object: authToken)
        }
        
        self.dismiss(animated: true) {
        }
    }

}
