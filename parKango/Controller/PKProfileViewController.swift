//
//  PKProfileViewController.swift

//
//  Created by Khatib H. on 3/10/19.
//  //

import UIKit
import Firebase
import JHSpinner
import SDWebImage

class PKProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var scrlViProfile: UIScrollView!
    @IBOutlet weak var imgViMain: UIImageView!
    @IBOutlet weak var imgViGender: UIImageView!
    
    @IBOutlet weak var imgViPhoto1: UIImageView!
    @IBOutlet weak var imgViPhoto2: UIImageView!
    @IBOutlet weak var imgViPhoto3: UIImageView!
    
    @IBOutlet weak var btnPhoto1: UIButton!
    @IBOutlet weak var btnPhoto2: UIButton!
    @IBOutlet weak var btnPhoto3: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnHashtag: UIButton!
    @IBOutlet weak var btnContactUs: UIButton!
    
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnAddSocial: UIButton!
    
    @IBOutlet weak var lblMakeModel: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblLFLP: UILabel!
    @IBOutlet weak var lblZipCode: UILabel!
    @IBOutlet weak var viLinksContainer: UIView!
    @IBOutlet weak var lblFavorite: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var lblEmojiButtonTitle: UILabel!
    @IBOutlet weak var btnEditEmojii: UIButton!
    
    @IBOutlet weak var cltViEmojis: UICollectionView!
    
    @IBOutlet weak var lblEmojiEmpty: UILabel!
    @IBOutlet weak var markVerified: UILabel!
    
    private let emojiCellIdentifier = "PKEmojiCollectionCell"
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var photoIdxToTake = SELECTED_NONE

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "PROFILE"
        
        for tabBarItem in (self.tabBarController?.tabBar.items!)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.scrlViProfile.contentSize = CGSize(width: SCREEN_WIDTH, height: 720)
        
        cltViEmojis.alwaysBounceVertical = true
        cltViEmojis.register(UINib(nibName: "PKEmojiCollectionCell", bundle: nil), forCellWithReuseIdentifier: emojiCellIdentifier)
        cltViEmojis.layer.masksToBounds = true
        cltViEmojis.layer.cornerRadius = 4.0
        
        self.imgViGender.layer.masksToBounds = true
        self.imgViGender.layer.cornerRadius = self.imgViGender.frame.size.height / 2.0
        self.imgViGender.layer.borderColor = UIColor.darkGray.cgColor
        self.imgViGender.layer.borderWidth = 0.5
        
        self.imgViPhoto1.layer.borderColor = UIColor.white.cgColor
        self.imgViPhoto1.layer.borderWidth = 1.0
        self.imgViPhoto2.layer.borderColor = UIColor.white.cgColor
        self.imgViPhoto2.layer.borderWidth = 1.0
        self.imgViPhoto3.layer.borderColor = UIColor.white.cgColor
        self.imgViPhoto3.layer.borderWidth = 1.0
        
        self.lblEmojiButtonTitle.layer.masksToBounds = true
        self.lblEmojiButtonTitle.layer.cornerRadius = self.lblEmojiButtonTitle.frame.size.height / 2.0
        self.lblEmojiButtonTitle.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.lblEmojiButtonTitle.layer.borderWidth = 1.0
        
        self.btnHashtag.layer.masksToBounds = true
        self.btnHashtag.layer.cornerRadius = self.btnHashtag.frame.size.height / 2.0
        self.btnHashtag.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.btnHashtag.layer.borderWidth = 1.0
        
        self.btnContactUs.layer.masksToBounds = true
        self.btnContactUs.layer.cornerRadius = self.btnContactUs.frame.size.height / 2.0
        self.btnContactUs.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.btnContactUs.layer.borderWidth = 1.0
        
        self.btnAddSocial.layer.masksToBounds = true
        self.btnAddSocial.layer.cornerRadius = self.btnAddSocial.frame.size.height / 2.0
        self.btnAddSocial.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.btnAddSocial.layer.borderWidth = 1.0
        
        self.btnFavorite.layer.masksToBounds = true
        self.btnFavorite.layer.cornerRadius = self.btnFavorite.frame.size.height / 2.0
        self.btnFavorite.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.btnFavorite.layer.borderWidth = 1.0
        
        self.btnLogout.layer.masksToBounds = true
        self.btnLogout.layer.cornerRadius = self.btnLogout.frame.size.height / 2.0
        self.btnLogout.layer.borderColor = ColorPalette.pkRed.cgColor
        self.btnLogout.layer.borderWidth = 1.0
        
        let makeModelString = self.sharedManager.myUser.vehicleMake! + " " + self.sharedManager.myUser.vehicleModel!
        let makeModelWidth = makeModelString.size(withAttributes:[.font: UIFont.systemFont(ofSize:14.0)]).width + 16
        self.lblMakeModel.frame = CGRect(x: self.lblMakeModel.frame.origin.x, y: self.lblMakeModel.frame.origin.y, width: makeModelWidth, height: 30)
        self.lblMakeModel.text = makeModelString
        
        self.lblUsername.text = self.sharedManager.myUser.username
        
        if self.sharedManager.myUser.isVerified {
            
            let userNameWidth = self.sharedManager.myUser.username!.widthOfString(usingFont: UIFont.systemFont(ofSize: 16, weight: .medium))
            self.markVerified.frame = CGRect(x: 106 + userNameWidth + 6, y: 360, width: 16, height: 18)
            self.markVerified.isHidden = false
        }
        else {
            self.markVerified.isHidden = true
        }
        
        if self.sharedManager.myUser.isInstagramLogin {
            self.lblEmail.text = ""
        }
        else {
            self.lblEmail.text = self.sharedManager.myUser.email
        }
        
        self.lblZipCode.text = String(format: "%@, %@, %@", self.sharedManager.myUser.zipCode!, self.sharedManager.myUser.city!, self.sharedManager.myUser.state!)
        self.lblLFLP.text = self.sharedManager.myUser.LFLP
        
        let hashTagString = "#" + self.sharedManager.myUser.hashtag!
        let hashButtonWidth = hashTagString.size(withAttributes:[.font: UIFont.systemFont(ofSize:14.0)]).width + 16
        self.lblFavorite.text = String(format: "FAVORITES(%d)", self.sharedManager.myUser.arrFavorites.count)
        
        self.btnHashtag.frame = CGRect(x: SCREEN_WIDTH - 16 - hashButtonWidth, y: self.btnHashtag.frame.origin.y, width: hashButtonWidth, height: 30)
        self.btnHashtag.setTitle(hashTagString, for: .normal)
        
        if self.sharedManager.myUser.vehicleType == PKVehicleType.car {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "icon_car_h"),  completed: nil)
        }
        else if self.sharedManager.myUser.vehicleType == PKVehicleType.truck {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "icon_truck_h2"),  completed: nil)
        }
        else if self.sharedManager.myUser.vehicleType == PKVehicleType.motorcycle {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "icon_motorcycle_h"),  completed: nil)
        }
        
        if self.sharedManager.myUser.vehicleType == PKVehicleType.spectator {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "male_empty"),  completed: nil)
            self.lblEmojiButtonTitle.text = "DO YOU OWN A RIDE NOW?"
            self.lblEmojiEmpty.text = "I'M SPECTATOR"
            self.lblMakeModel.isHidden = true
            self.btnPhoto2.isHidden = true
            self.btnPhoto3.isHidden = true
            self.imgViPhoto2.isHidden = true
            self.imgViPhoto3.isHidden = true
            //self.btnHashtag.isHidden = true
        }
        else {
            self.lblEmojiButtonTitle.text = "DESCRIBE YOUR\nRIDE WITH EMOJI"
            self.lblEmojiEmpty.text = "EMPTY"
            self.lblMakeModel.isHidden = false
            self.btnPhoto2.isHidden = false
            self.btnPhoto3.isHidden = false
            self.imgViPhoto2.isHidden = false
            self.imgViPhoto3.isHidden = false
            //self.btnHashtag.isHidden = false
        }
        
        self.imgViPhoto1.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), completed: nil)
        
        if self.sharedManager.myUser.arrPhotos.indices.contains(1)
        {
            self.imgViPhoto2.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[1]), completed: nil)
            
            if self.sharedManager.myUser.arrPhotos[1] != ""
            {
                self.btnPhoto2.setTitle("", for: .normal)
            }
        }
        if self.sharedManager.myUser.arrPhotos.indices.contains(2)
        {
            self.imgViPhoto3.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[2]), completed: nil)
            if self.sharedManager.myUser.arrPhotos[2] != ""
            {
                self.btnPhoto3.setTitle("", for: .normal)
            }
        }
        
        if self.sharedManager.myUser.gender == PKGender.male {
            self.imgViGender.image = UIImage(named: "male_empty")
        }
        else if self.sharedManager.myUser.gender == PKGender.female
        {
            self.imgViGender.image = UIImage(named: "female_empty")
        }
        else if self.sharedManager.myUser.gender == PKGender.neutral
        {
            self.imgViGender.image = UIImage(named: "alien_empty")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadMyProfile()
        self.getMyRideEmojis()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust cell width to screensize.
        
        if let layout = cltViEmojis.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 26, height: 26)
            layout.scrollDirection = .vertical
            layout.invalidateLayout()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showFavoriteProfiles" {
            let viCtrlProfiles = segue.destination as! PKBrowseViewController
            viCtrlProfiles.browseMode = PKProfileBrowseMode.favorites
        }
    }
    
    
    // MARK: - Own Methods
    
    func reloadMyProfile()
    {
        let makeModelString = self.sharedManager.myUser.vehicleMake! + " " + self.sharedManager.myUser.vehicleModel!
        let makeModelWidth = makeModelString.size(withAttributes:[.font: UIFont.systemFont(ofSize:14.0)]).width + 16
        self.lblMakeModel.frame = CGRect(x: self.lblMakeModel.frame.origin.x, y: self.lblMakeModel.frame.origin.y, width: makeModelWidth, height: 30)
        self.lblMakeModel.text = makeModelString
        
        self.lblUsername.text = self.sharedManager.myUser.username
        
        if self.sharedManager.myUser.isInstagramLogin {
            self.lblEmail.text = ""
        }
        else {
            self.lblEmail.text = self.sharedManager.myUser.email
        }
        
        self.lblZipCode.text = String(format: "%@, %@, %@", self.sharedManager.myUser.zipCode!, self.sharedManager.myUser.city!, self.sharedManager.myUser.state!)
        self.lblLFLP.text = self.sharedManager.myUser.LFLP
        
        let hashTagString = "#" + self.sharedManager.myUser.hashtag!
        let hashButtonWidth = hashTagString.size(withAttributes:[.font: UIFont.systemFont(ofSize:14.0)]).width + 16
        self.btnHashtag.frame = CGRect(x: SCREEN_WIDTH - 16 - hashButtonWidth, y: self.btnHashtag.frame.origin.y, width: hashButtonWidth, height: 30)
        self.btnHashtag.setTitle(hashTagString, for: .normal)
        
        self.lblFavorite.text = String(format: "FAVORITES(%d)", self.sharedManager.myUser.arrFavorites.count)
        
        if self.sharedManager.myUser.vehicleType == PKVehicleType.car {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "icon_car_h"),  completed: nil)
        }
        else if self.sharedManager.myUser.vehicleType == PKVehicleType.truck {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "icon_truck_h2"),  completed: nil)
        }
        else if self.sharedManager.myUser.vehicleType == PKVehicleType.motorcycle {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "icon_motorcycle_h"),  completed: nil)
        }
        
        if self.sharedManager.myUser.vehicleType == PKVehicleType.spectator {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), placeholderImage:UIImage(named: "male_empty"),  completed: nil)
            self.lblEmojiButtonTitle.text = "DO YOU OWN A RIDE NOW?"
            self.lblEmojiEmpty.text = "I'M SPECTATOR"
            self.lblMakeModel.isHidden = true
            self.btnPhoto2.isHidden = true
            self.btnPhoto3.isHidden = true
            self.imgViPhoto2.isHidden = true
            self.imgViPhoto3.isHidden = true
            //self.btnHashtag.isHidden = true
        }
        else {
            self.lblEmojiButtonTitle.text = "DESCRIBE YOUR\nRIDE WITH EMOJI"
            self.lblEmojiEmpty.text = "EMPTY"
            self.lblMakeModel.isHidden = false
            self.btnPhoto2.isHidden = false
            self.btnPhoto3.isHidden = false
            self.imgViPhoto2.isHidden = false
            self.imgViPhoto3.isHidden = false
            //self.btnHashtag.isHidden = false
        }
        
    }
    
    func getMyRideEmojis()
    {
        self.sharedManager.myUser.arrRideEmojis.removeAll()
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dispatchGroup = DispatchGroup()
        
        for emojiId in self.sharedManager.myUser.arrRideEmojiIds
        {
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("emojis").child(emojiId).observeSingleEvent(of: .value) { (dataSnapShot) in
                
                let emoji = PKEmoji()
                emoji.setEmoji(withDataSnapshot: dataSnapShot)
                
                self.sharedManager.myUser.arrRideEmojis.append(emoji)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            if self.sharedManager.myUser.arrRideEmojis.count > 0 {
                self.lblEmojiEmpty.isHidden = true
            }
            else {
                self.lblEmojiEmpty.isHidden = false
            }
            self.cltViEmojis.reloadData()
            
            self.reloadSocialLinks()
        }
    }
    
    func reloadSocialLinks()
    {
        for view in self.viLinksContainer.subviews
        {
            view.removeFromSuperview()
        }
        
        var index = 0
        for strLink in self.sharedManager.myUser.arrSocialLinks
        {
            
            
            
            /*if strLink.contains("facebook.com"){
                icon.image = UIImage(named: "icon_facebook")
            }
            else if strLink.contains("twitter.com")
            {
                icon.image = UIImage(named: "icon_twitter")
            }
            else */if strLink.contains("instagram.com")
            {
                
                let icon = UIImageView(frame: CGRect(x: 0, y: index * 24, width: 16, height: 16))
                icon.contentMode = .scaleAspectFit
                icon.clipsToBounds = true
                
                icon.image = UIImage(named: "icon_instagram")
                
                self.viLinksContainer.addSubview(icon)
                
                let btnLink = UIButton(type: .custom)
                let linkButtonWidth = strLink.size(withAttributes:[.font: UIFont.systemFont(ofSize:12.0)]).width + 4
                btnLink.frame = CGRect(x: 24, y: index * 24, width: Int(linkButtonWidth), height: 16)
                btnLink.setTitle(strLink, for: .normal)
                btnLink.setTitleColor(ColorPalette.pkLink, for: .normal)
                btnLink.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
                
                btnLink.addTarget(self, action: #selector(onTapSocialLink(sender:)), for: .touchUpInside)
                self.viLinksContainer.addSubview(btnLink)
                
            }
            /*else if strLink.contains("snapchat.com")
            {
                icon.image = UIImage(named: "icon_snapchat")
            }*/
            index = index + 1
        }
    }
    
    func takePhoto() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Pick a photo from", message: nil, preferredStyle: .actionSheet)
        let actionCameraRoll = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionCameraRoll)
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func deleteFileFromStorage(downloadURLString: String)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:"Deleting")
        self.view.addSubview(spinner)
        
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: downloadURLString)
        
        //Removes image from storage
        storageRef.delete { error in
            spinner.dismiss()
            
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
                print("File deleted.")
            }
        }
    }
    
    func uploadPhoto(image:UIImage, intoIndex: Int)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let storageRef = Storage.storage().reference()
        let imageData = image.jpegData(compressionQuality: 0.8)
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("user_images/\(uuid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                
            } else {
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    var arrPhotos = self.sharedManager.myUser.arrPhotos
                    var deletingFileURL = self.sharedManager.myUser.arrPhotos[self.photoIdxToTake]
                    arrPhotos[self.photoIdxToTake] = downloadURL.absoluteString
                    
                    let dbRef = Database.database().reference()
                    dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("photos").setValue(arrPhotos) { (error, dataRef) in
                        if error != nil{
                            spinner.dismiss()
                            self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                        }
                        else {
                            spinner.dismiss()
                            self.imgViMain.image = image
                            if self.photoIdxToTake == 0 {
                                self.imgViPhoto1.image = image
                                self.btnPhoto1.setTitle("", for: .normal)
                            }
                            else if self.photoIdxToTake == 1 {
                                self.imgViPhoto2.image = image
                                self.btnPhoto2.setTitle("", for: .normal)
                            }
                            else if self.photoIdxToTake == 2 {
                                self.imgViPhoto3.image = image
                                self.btnPhoto3.setTitle("", for: .normal)
                            }
                            
                            self.sharedManager.myUser.arrPhotos = arrPhotos
                            
                            if deletingFileURL != "" {
                                self.deleteFileFromStorage(downloadURLString: deletingFileURL)
                            }
                        }
                    }
                }
                
            }
        }
    }

    // MARK: - Event Handlers
    @IBAction func onContactUs(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Additional", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
        controller.browseURL = PKURL.contactUs
        controller.pageTitle = "CONTACT US"
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onEmojiEdit(_ sender: Any) {
        if self.sharedManager.myUser.vehicleType == PKVehicleType.spectator {
            
        }
        else {
            let storyboard = UIStoryboard(name: "Additional", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PKEditEmojisViewController") as! PKEditEmojisViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    @IBAction func onTapHashTag(_ sender: Any) {
        
        var strHashTag = (sender as! UIButton).title(for: .normal)
        strHashTag = strHashTag!.replacingOccurrences(of: "#", with: "")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKBrowseViewController") as! PKBrowseViewController
        controller.browseMode = PKProfileBrowseMode.hashtag
        controller.hashtagSelected = strHashTag!
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func onTapSocialLink(sender: Any)
    {
        let strLink = (sender as! UIButton).title(for: .normal)
        let storyboard = UIStoryboard(name: "Additional", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
        controller.browseURL = strLink!
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onPhoto1(_ sender: Any) {
        if self.sharedManager.myUser.arrPhotos.indices.contains(0)
        {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[0]), completed: nil)
        }
        
        self.imgViPhoto1.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.imgViPhoto2.layer.borderColor = UIColor.white.cgColor
        self.imgViPhoto3.layer.borderColor = UIColor.white.cgColor

        self.photoIdxToTake = 0
        self.takePhoto()
    }
    
    @IBAction func onPhoto2(_ sender: Any) {
        if self.sharedManager.myUser.arrPhotos.indices.contains(1)
        {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[1]), completed: nil)
        }
        self.imgViPhoto2.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.imgViPhoto1.layer.borderColor = UIColor.white.cgColor
        self.imgViPhoto3.layer.borderColor = UIColor.white.cgColor

        self.photoIdxToTake = 1
        self.takePhoto()
    }
    
    @IBAction func onPhoto3(_ sender: Any) {
        if self.sharedManager.myUser.arrPhotos.indices.contains(2)
        {
            self.imgViMain.sd_setImage(with: URL(string: self.sharedManager.myUser.arrPhotos[2]), completed: nil)
        }
        
        self.imgViPhoto3.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.imgViPhoto2.layer.borderColor = UIColor.white.cgColor
        self.imgViPhoto1.layer.borderColor = UIColor.white.cgColor
        self.photoIdxToTake = 2
        self.takePhoto()
    }
    
    @IBAction func onAddSocial(_ sender: Any) {
        let viCtrlAddSocial = UIStoryboard(name: "Additional", bundle: nil).instantiateViewController(withIdentifier: "PKAddSocialViewController") as! PKAddSocialViewController
        viCtrlAddSocial.nAddSocialMode = PKAddSocialLinkMode.fromEditProfile
        self.present(viCtrlAddSocial, animated: true, completion: nil)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        try! Auth.auth().signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            spinner.dismiss()
            
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.sharedManager.myUser.arrRideEmojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! PKEmojiCollectionCell
        
        let emoji = self.sharedManager.myUser.arrRideEmojis[indexPath.row]
        
        emojiCell.imgViEmoji.sd_setImage(with: URL(string: emoji.imageURL!), completed: nil)
        
        return emojiCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) != nil
        {
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.uploadPhoto(image: image!, intoIndex: self.photoIdxToTake)
        }
    }
}
