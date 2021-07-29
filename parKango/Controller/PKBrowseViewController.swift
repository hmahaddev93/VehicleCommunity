//
//  PKBrowseViewController.swift

//
//  Created by Khatib H. on 3/10/19.
//  //

import UIKit
import JHSpinner
import Firebase
import SDWebImage
import CoreLocation
import ActionSheetPicker_3_0

class PKBrowseViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var lblEmpty: UILabel!
    @IBOutlet weak var scrlViBrowse: UIScrollView!
    @IBOutlet weak var viInput: UIView!
    @IBOutlet weak var btnSendMessage: UIButton!
    @IBOutlet weak var tfMessage: TextField!
    @IBOutlet weak var cltViEmojis: UICollectionView!
    @IBOutlet weak var lblAboutMe: UILabel!
    @IBOutlet weak var lblKarglyphics: UILabel!
    @IBOutlet weak var coverAddEmoji: UIView!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var arrProfiles = [PKUser]()
    var browseMode = PKProfileBrowseMode.home
    var currentPage = 0
    var currentPhotoIdxOnCurrentPage = 0
    var arrCurrentUserEmojis = [PKEmoji]()
    var hashtagSelected = ""
    
    private let emojiCellIdentifier = "PKEmojiCollectionCell"
    var keyboardHeight:CGFloat = 0.0
    var frameSendMsg = CGRect()
    var slideTimer = Timer()
    
    var doneButtonItem = UIBarButtonItem()
    var playButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "HOME"
        
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 30))
        let imageViewLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 30))
        imageViewLogo.contentMode = .scaleAspectFit
        let imageLogo = UIImage(named: "kanga_logo")
        imageViewLogo.image = imageLogo
        logoContainer.addSubview(imageViewLogo)
        navigationItem.titleView = logoContainer

        for tabBarItem in (self.tabBarController?.tabBar.items!)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.doneButtonItem = UIBarButtonItem(title: "···", style: .done, target: self, action: #selector(onReportUser(sender:)))
        
        var imgPlay = UIImage(named: "btnPlay")
        imgPlay = imgPlay?.withRenderingMode(.alwaysOriginal)
        self.playButtonItem = UIBarButtonItem(image: imgPlay, style:.plain, target: self, action: #selector(onPlayPhotoSlide(sender:)))
        
        self.navigationItem.rightBarButtonItems = [self.doneButtonItem]
        
        cltViEmojis.alwaysBounceHorizontal = true
        cltViEmojis.register(UINib(nibName: "PKEmojiCollectionCell", bundle: nil), forCellWithReuseIdentifier: emojiCellIdentifier)
        
        self.tfMessage.layer.masksToBounds = true
        self.tfMessage.layer.cornerRadius = self.tfMessage.frame.size.height / 2.0
        self.tfMessage.layer.borderColor = UIColor.lightGray.cgColor
        self.tfMessage.layer.borderWidth = 1.0
        
        self.btnSendMessage.layer.masksToBounds = true
        self.btnSendMessage.layer.cornerRadius = self.btnSendMessage.frame.size.height / 2.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapBg(sender:)))
        self.scrlViBrowse.addGestureRecognizer(tapGesture)
        
        let tapGestureCover = UITapGestureRecognizer(target: self, action: #selector(onTapCover(sender:)))
        self.coverAddEmoji.addGestureRecognizer(tapGestureCover)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        self.currentPhotoIdxOnCurrentPage = 0
        self.frameSendMsg = self.viInput.frame
        self.getProfiles()
        
        if self.sharedManager.myUser.vehicleType == PKVehicleType.spectator {
            self.coverAddEmoji.isHidden = true
        }
        else {
            if self.sharedManager.myUser.arrRideEmojiIds.count == 0 {
                self.coverAddEmoji.isHidden = false
            }
            else {
                self.coverAddEmoji.isHidden = true
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.slideTimer.invalidate()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIScrollViewDelegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Disable the swiping profiles & emojis together
        if scrollView == self.cltViEmojis {
            self.cltViEmojis.isScrollEnabled = true
            self.scrlViBrowse.isScrollEnabled = false
        }
        else if scrollView == self.scrlViBrowse {
            self.scrlViBrowse.isScrollEnabled = true
            self.cltViEmojis.isScrollEnabled = false
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.cltViEmojis {
            self.scrlViBrowse.isScrollEnabled = true
            self.cltViEmojis.isScrollEnabled = true
        }
        else if scrollView == self.scrlViBrowse {
            self.scrlViBrowse.isScrollEnabled = true
            
            let pageWidth = scrollView.frame.size.width
            self.currentPage = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
            self.currentPhotoIdxOnCurrentPage = 0
            
            self.getCurrentUserEmojis()
            self.updateProfile(withIdx: self.currentPage)
            self.startPhotoSlide()
        }
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrCurrentUserEmojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! PKEmojiCollectionCell
        
        let emoji = self.arrCurrentUserEmojis[indexPath.row]
        
        emojiCell.imgViEmoji.sd_setImage(with: URL(string: emoji.imageURL!), completed: nil)
        
        return emojiCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = self.arrCurrentUserEmojis[indexPath.row]

        if emoji.linkURLString != "" {
            let storyboard = UIStoryboard(name: "Additional", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
            controller.browseURL = emoji.linkURLString
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfMessage {
            textField.resignFirstResponder()
            let targetUser = self.arrProfiles[self.currentPage]
            self.sendMessageTo(targetUser: targetUser, msgText: self.tfMessage.text!)
        }
        return true
    }
    
    // MARK: - Event Handlers
    func startPhotoSlide ()
    {
        self.slideTimer.invalidate()
        
        self.slideTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.updatePhotoSelected(sender:)), userInfo: nil, repeats: true)
        
    }
    
    @objc func updatePhotoSelected(sender:Any)
    {
        print(self.arrProfiles.count)
        print(self.currentPage)
        let profile = self.arrProfiles[self.currentPage]
        var photosCount = profile.arrPhotos.count
        if photosCount > 3 {
            photosCount = 3
        }
        
        if photosCount == 1 {
            return
        }
        
        self.currentPhotoIdxOnCurrentPage = self.currentPhotoIdxOnCurrentPage + 1
        if self.currentPhotoIdxOnCurrentPage > photosCount-1 {
            self.currentPhotoIdxOnCurrentPage = 0
        }
        self.updateProfile(withIdx: self.currentPage)
    }
    
    @objc func onSelectPhoto(sender:Any) {
        self.currentPhotoIdxOnCurrentPage = (sender as! UIButton).tag
        self.updateProfile(withIdx: self.currentPage)
    }
    
    @objc func onReportUser(sender: Any)
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let currentUserProfile = self.arrProfiles[self.currentPage]
        var blockTitle = ""
        if self.sharedManager.myUser.isBlockedUser(bUserId: currentUserProfile.uid!) {
            blockTitle = "Unblock this rider"
        }
        else {
            blockTitle = "Block this rider"
        }

        let actionBlock = UIAlertAction(title: blockTitle, style: .destructive) { (_) in
            self.blockCurrentUser()
        }
        
        let actionLegal = UIAlertAction(title: "Legal agreements", style: .destructive) { (_) in
            let storyboard = UIStoryboard(name: "Additional", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
            controller.browseURL = PKURL.termsOfService
            controller.pageTitle = "TERMS OF SERVICE"
            self.present(controller, animated: true, completion: nil)
        }
        
        let actionReport = UIAlertAction(title: "Report this rider", style: .destructive) { (_) in
            let arrReportReasons = ["Inappropriate pictures", "Impersonating account","Spam"]
            
            ActionSheetStringPicker.show(withTitle: "Select a reason", rows: arrReportReasons, initialSelection: 0, doneBlock: { (picker, selectedIdx, selectedValue) in
                self.reportCurrentUser(withReason: (selectedValue as! String))
                
            }, cancel: { (picker) in
                
            }, origin: sender)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionBlock)
        actionSheet.addAction(actionLegal)
        actionSheet.addAction(actionReport)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func onPlayPhotoSlide(sender:Any) {
        self.startPhotoSlide()
    }
    
    @objc func onTapBg(sender:Any)
    {
        self.tfMessage.resignFirstResponder()
    }
    
    @objc func onTapCover(sender:Any)
    {
        //self.coverAddEmoji.isHidden = true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
            
            UIView.animate(withDuration: 0.3) {
                self.viInput.frame = CGRect(x: 0, y: self.frameSendMsg.origin.y - self.keyboardHeight + (self.tabBarController?.tabBar.frame.size.height)!, width: SCREEN_WIDTH, height: 60)

            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.viInput.frame = self.frameSendMsg
        }
    }
    
    @objc func onTapSocialLink(sender: Any)
    {
        let strLink = (sender as! UIButton).title(for: .normal)
        let storyboard = UIStoryboard(name: "Additional", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
        controller.browseURL = strLink!
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func onTapHashTag(sender: Any)
    {
        var strHashTag = (sender as! UIButton).title(for: .normal)
        strHashTag = strHashTag!.replacingOccurrences(of: "#", with: "")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKBrowseViewController") as! PKBrowseViewController
        controller.browseMode = PKProfileBrowseMode.hashtag
        controller.hashtagSelected = strHashTag!
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func onTapFavorite(sender: Any)
    {
        self.favoriteProfile(withIdx: (sender as! UIButton).tag)
    }

    @objc func onDoubleTapLike(sender: Any)
    {
        let doubleTap = sender as! UITapGestureRecognizer
        self.likeProfile(withIdx: doubleTap.view!.tag)
    }
    
    @objc func onTapLike(sender: Any)
    {
        self.likeProfile(withIdx: (sender as! UIButton).tag)
    }
    
    @IBAction func onMessageSend(_ sender: Any) {
        self.tfMessage.resignFirstResponder()
        let targetUser = self.arrProfiles[self.currentPage]
        self.sendMessageTo(targetUser: targetUser, msgText: self.tfMessage.text!)
    }

    // MARK: - Own Methods
    
    func openChatWith(chatId: String, targetUser:PKUser) {
    
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("chats").child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
            spinner.dismiss()
            let chat = PKChat()
            chat.setChat(withDataSnapshot: snapshot)
            
            let storyboard = UIStoryboard(name: "Additional", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PKChatViewController") as! PKChatViewController
            controller.chat = chat
            controller.senderId = self.sharedManager.myUser.uid
            controller.senderDisplayName = self.sharedManager.myUser.username
            controller.targetUser = targetUser
            controller.immediateMsgText = self.tfMessage.text!
            self.tfMessage.text = ""
            
            self.navigationController?.pushViewController(controller, animated: true)
            
        }) { (error) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
        }
        
    }
    
    func existingChatIdWith(targetUser:PKUser) -> String {
        if self.sharedManager.myUser.arrChatIds.count < 1 {
            return ""
        }
        else {
            for myChatId in self.sharedManager.myUser.arrChatIds {
                if targetUser.arrChatIds.contains(myChatId) {
                    return myChatId
                }
            }
        }
        return ""
    }
    
    func sendMessageTo(targetUser:PKUser, msgText: String) {
        
        if targetUser.isBlockedUser(bUserId: self.sharedManager.myUser.uid!) {
            self.present(self.sharedManager.getAppAlert(withMsg: String(format:
                "Can not send messsage because %@ is blocking you.", targetUser.username!)), animated: true, completion: nil)
            return
        }
        
        if self.sharedManager.myUser.isBlockedUser(bUserId: targetUser.uid!) {
            self.present(self.sharedManager.getAppAlert(withMsg: String(format:
                "Unblock %@ to send message.", targetUser.username!)), animated: true, completion: nil)
            return
        }
        
        let existingChatId = self.existingChatIdWith(targetUser: targetUser)
        if existingChatId != "" {
            self.openChatWith(chatId: existingChatId, targetUser: targetUser)
        }
        else {
            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            let chatData = ["create_user_id": self.sharedManager.myUser.uid!,
                            "target_user_id": targetUser.uid!,
                            "last_message": msgText,
                            "created_time_stamp": ServerValue.timestamp()] as [String : Any]
            
            let dbRef = Database.database().reference()
            dbRef.child("chats").childByAutoId().setValue(chatData) { (error, dataRef) in
                
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    self.updateChatsForUsers(newChatId: dataRef.key!, targetUser: targetUser)
                }
                
            }
        }
    }
    
    func updateChatsForUsers(newChatId: String, targetUser:PKUser) {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let updateValue = ["id": newChatId]

        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("chats").child(newChatId) .setValue(updateValue) { (error, dataRef) in
            
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.sharedManager.myUser.arrChatIds.append(newChatId)
                self.updateTargetUserChats(newChatId: newChatId, targetUser: targetUser)
            }
            
        }
    }
    
    func updateTargetUserChats(newChatId: String, targetUser:PKUser) {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let updateValue = ["id": newChatId]
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(targetUser.uid!).child("chats").child(newChatId).setValue(updateValue) { (error, dataRef) in
            
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.arrProfiles[self.currentPage].arrChatIds.append(newChatId)
                self.openChatWith(chatId: newChatId, targetUser: targetUser)
                
            }
        }
    }
    
    func registerLikeNotification(targetUser:PKUser)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let notificationData = ["type": "like",
                                "from_user_id": self.sharedManager.myUser.uid,
                                "from_user_name": self.sharedManager.myUser.username,
                                "from_user_type": self.sharedManager.myUser.vehicleType,
                                "msg_text": "@" + self.sharedManager.myUser.username! + " liked your profile."
            ] as [String : Any]
        
        let dbRef = Database.database().reference()
        dbRef.child("pk_notifications").child(targetUser.uid!).childByAutoId().setValue(notificationData) { (error, dataRef) in
            
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.sharedManager.sendNotificationTo(targetUserToken: targetUser.fcmToken, msgTitle: "Someone likes you", msgBody: notificationData["msg_text"] as! String, type: PKNotificationType.like)
            }
        }
        
    }
    
    func showAnimationWithText(text: String)
    {
        let lblText = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 120)/2.0, y: 150 - 15, width: 120, height: 30))
        lblText.font = UIFont.systemFont(ofSize: 18.0)
        lblText.textColor = UIColor.white
        lblText.text = text
        lblText.textAlignment = .center
        lblText.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        lblText.layer.masksToBounds = true
        lblText.layer.cornerRadius = 4.0
        
        self.view.addSubview(lblText)
        
        lblText.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            lblText.alpha = 1.0
        }) { (complete) in
            UIView.animate(withDuration: 0.4, animations: {
                lblText.alpha = 0.0
            }) { (complete) in
                lblText.removeFromSuperview()
            }
        }
    }
    
    func reportCurrentUser(withReason:String)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let currentUserProfile = self.arrProfiles[self.currentPage]
        let report = ["reported_user_id": currentUserProfile.uid, "reporter_id": self.sharedManager.myUser.uid, "reason": withReason]
        
        let dbRef = Database.database().reference()
        dbRef.child("reports").childByAutoId().setValue(report) { (error, dataRef) in
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.showAnimationWithText(text: "✓ Reported!")
            }
        }
    }
    
    func blockCurrentUser()
    {
        let currentUserProfile = self.arrProfiles[self.currentPage]
        if currentUserProfile.isBlockedUser(bUserId: self.sharedManager.myUser.uid!) {
            self.present(self.sharedManager.getAppAlert(withMsg: String(format: "%@ is already blocking you.", currentUserProfile.username!)), animated: true, completion: nil)
            return
        }

        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        
        if self.sharedManager.myUser.isBlockedUser(bUserId: currentUserProfile.uid!) {
            //remove blocked user
            dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("blocked").queryOrderedByValue().queryEqual(toValue: currentUserProfile.uid!).observe(.value, with: { (snapshot) in
                
                print(snapshot)
                if let blockedUsers = snapshot.value as? [String: String] {
                    for (key, _) in blockedUsers  {
                        dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("blocked").child(key).removeValue(completionBlock: { (error, dataRef) in
                            if error != nil{
                                spinner.dismiss()
                                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                            }
                            else {
                                spinner.dismiss()
                                self.sharedManager.myUser.removeBlockedUser(bUserId: currentUserProfile.uid!)
                                self.showAnimationWithText(text: "✓ Unblocked!")
                            }
                        })
                    }
                }
            })
            
        }
        else {
            //add blocked user
        dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("blocked").childByAutoId().setValue(currentUserProfile.uid) { (error, dataRef) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    self.sharedManager.myUser.arrBlockedUserIds.append(currentUserProfile.uid!)
                    self.showAnimationWithText(text: "✓ Blocked!")
                }
            }
            
        }
        
        
    }
    
    func getCurrentUserEmojis()
    {
        let userProfile = self.arrProfiles[self.currentPage]
        self.arrCurrentUserEmojis.removeAll()
        //let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        //self.view.addSubview(spinner)
        
        let dispatchGroup = DispatchGroup()
        
        for emojiId in userProfile.arrRideEmojiIds
        {
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("emojis").child(emojiId).observeSingleEvent(of: .value) { (dataSnapShot) in
                
                let emoji = PKEmoji()
                emoji.setEmoji(withDataSnapshot: dataSnapShot)
                
                self.arrCurrentUserEmojis.append(emoji)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            //spinner.dismiss()
            if self.arrCurrentUserEmojis.count > 0 {
                self.lblAboutMe.isHidden = false
                self.lblKarglyphics.isHidden = false
            }
            else {
                self.lblAboutMe.isHidden = true
                self.lblKarglyphics.isHidden = true
            }
            self.cltViEmojis.reloadData()
            
            self.cltViEmojis.isScrollEnabled = true

        }
    }
    
    func showLikeAnimation(isLiked:Bool)
    {
        if !isLiked {
            let likeIcon = UIImageView(frame: CGRect(x: SCREEN_WIDTH/2.0, y: 150, width: 0, height: 0))
            likeIcon.image = UIImage(named: "kk_like")
            likeIcon.contentMode = .scaleAspectFit
            self.view.addSubview(likeIcon)
            
            likeIcon.alpha = 0
            UIView.animate(withDuration: 0.6, animations: {
                likeIcon.frame = CGRect(x: SCREEN_WIDTH/2.0 - 70, y: 150 - 70, width: 140, height: 140)
                likeIcon.alpha = 1.0
            }) { (complete) in
                UIView.animate(withDuration: 0.5, animations: {
                    likeIcon.alpha = 0.0
                }, completion: { (complete) in
                    likeIcon.removeFromSuperview()
                })
            }
        }
        else {
            
            let lblText = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 150)/2.0, y: 150 - 15, width: 150, height: 30))
            lblText.font = UIFont.systemFont(ofSize: 18.0)
            lblText.textColor = UIColor.white
            lblText.text = "✓ Already Liked!"
            lblText.textAlignment = .center
            lblText.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
            lblText.layer.masksToBounds = true
            lblText.layer.cornerRadius = 4.0
            
            self.view.addSubview(lblText)
            
            lblText.alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: {
                lblText.alpha = 1.0
            }) { (complete) in
                UIView.animate(withDuration: 0.4, animations: {
                    lblText.alpha = 0.0
                }) { (complete) in
                    lblText.removeFromSuperview()
                }
            }
        }
    }
    
    func favoriteProfile(withIdx: Int)
    {
        let profile = self.arrProfiles[withIdx]
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        
        if self.sharedManager.myUser.isFavoriteUser(favUserId: profile.uid!)
        {
            dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("favorites").observeSingleEvent(of: .value)
            { (dataSnapShot) in
                
                var favIdKey = ""
                for favObj in dataSnapShot.children.allObjects
                {
                    if (favObj as AnyObject).value == profile.uid
                    {
                        favIdKey = (favObj as AnyObject).key
                        break
                    }
                }
                
                if favIdKey == "" {
                    spinner.dismiss()
                }
                else {
                    dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("favorites").child(favIdKey).removeValue(completionBlock:
                        { (error, dbRef) in
                            
                            if error != nil{
                                spinner.dismiss()
                                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                            }
                            else {
                                spinner.dismiss()
                                
                                self.sharedManager.myUser.removeFavoriteUser(favUserId: profile.uid!)
                                self.updateProfile(withIdx: withIdx)
                            }
                    })
                }
            }
            
        }
        else
        {
            dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("favorites").childByAutoId().setValue(profile.uid) { (error, dataRef) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    
                    self.sharedManager.myUser.arrFavorites.append(profile.uid!)
                    self.updateProfile(withIdx: withIdx)
                }
            }
        }
    }
    
    func likeProfile(withIdx: Int)
    {
        let profile = self.arrProfiles[withIdx]
        if profile.isLikedUser(likedUserId: self.sharedManager.myUser.uid!)
        {
            self.showLikeAnimation(isLiked: true)
        }
        else {
            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            var dicLike = [String: Any]()
            
            var dbRef = Database.database().reference()
            let likeId = profile.likeIdForUser(likedUserId: self.sharedManager.myUser.uid!)
            if  likeId == SELECTED_NONE_STRING {
                dbRef = Database.database().reference().child("user_data").child(profile.uid!).child("likes").childByAutoId()
                
                dicLike = ["uid": dbRef.key,
                               "liker_id": self.sharedManager.myUser.uid,
                               "liked_date": Date().timeIntervalSince1970] as! [String : Any]
            }
            else {
                dbRef = Database.database().reference().child("user_data").child(profile.uid!).child("likes").child(likeId)
                
                dicLike = ["uid": likeId,
                           "liker_id": self.sharedManager.myUser.uid,
                           "liked_date": Date().timeIntervalSince1970] as! [String : Any]
            }
            
            
            dbRef.setValue(dicLike) { (error, dataRef) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    
                    self.showLikeAnimation(isLiked: false)
                    
                    let aLike = PKLike()
                    aLike.setLike(withLikeDic: dicLike)
                    self.arrProfiles[withIdx].arrLikes.append(aLike)
                    
                    self.updateProfile(withIdx: withIdx)
                    self.registerLikeNotification(targetUser: profile)
                }
            }
        }
    }
    
    func sortProfilesByZipCodeDistance()
    {
        for profile in self.arrProfiles
        {
            let coordinateTarget = CLLocation(latitude: profile.zipcodeLatitude, longitude: profile.zipcodeLongitude)
            let coordinateMe = CLLocation(latitude: self.sharedManager.myUser.zipcodeLatitude, longitude: self.sharedManager.myUser.zipcodeLongitude)
            profile.distanceByZipCode = coordinateMe.distance(from: coordinateTarget)
        }
        
        self.arrProfiles = self.arrProfiles.sorted(by: {$0.distanceByZipCode < $1.distanceByZipCode})
        self.loadProfilePhotos()
    }
    
    func getProfiles()
    {
        if self.browseMode == PKProfileBrowseMode.home {
            self.arrProfiles.removeAll()

            self.title = "HOME"

            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            let dbRef = Database.database().reference()
            dbRef.child("user_data").observeSingleEvent(of: .value, with: { (snapshot) in
                spinner.dismiss()
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        
                        if let uid = (snap.value as! NSDictionary)["uid"] as? String {
                            
                            if uid != "" {
                                let profile = PKUser()
                                profile.setUser(withDataSnapshot: snap)
                                
                                if profile.uid != self.sharedManager.myUser.uid && profile.vehicleType != PKVehicleType.spectator
                                {
                                    self.arrProfiles.append(profile)
                                }
                            }
                        }
                        
                    }
                }
                
                if self.arrProfiles.count > 0 {
                    self.lblEmpty.isHidden = true
                    self.scrlViBrowse.isHidden = false
                    self.sortProfilesByZipCodeDistance()
                }
                else {
                    self.lblEmpty.isHidden = false
                    self.scrlViBrowse.isHidden = true
                }
                
            }, withCancel: { (getUserInfoError) in
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
            })
        }
        else if self.browseMode == PKProfileBrowseMode.favorites {
            self.title = "FAVORITES"
            self.arrProfiles.removeAll()
            self.getFavoriteProfiles()
        }
        else if self.browseMode == PKProfileBrowseMode.filtered {
            self.title = "FILTERED"
            
            if self.arrProfiles.count > 0 {
                self.lblEmpty.isHidden = true
                self.scrlViBrowse.isHidden = false
                self.sortProfilesByZipCodeDistance()
            }
            else {
                self.lblEmpty.isHidden = false
                self.scrlViBrowse.isHidden = true
            }
            
        }
        else if self.browseMode == PKProfileBrowseMode.hashtag {
            self.title = "#" + self.hashtagSelected
            self.arrProfiles.removeAll()
            self.getProfilesWithHashtag()
        }
        else if self.browseMode == PKProfileBrowseMode.single {
            self.title = "@" + (self.arrProfiles.first?.username)!
            self.loadProfilePhotos()
        }
        
    }
    
    func getProfilesWithHashtag()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").queryOrdered(byChild: "hashtag").queryEqual(toValue: self.hashtagSelected).observe(.value, with: { (snapshot) in
            
            spinner.dismiss()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    
                    if let uid = (snap.value as! NSDictionary)["uid"] as? String {
                        if uid != "" {
                            let profile = PKUser()
                            profile.setUser(withDataSnapshot: snap)
                            
                            if profile.uid != self.sharedManager.myUser.uid && profile.vehicleType != PKVehicleType.spectator
                            {
                                self.arrProfiles.append(profile)
                            }
                        }
                    }
                    
                }
            }
            
            if self.arrProfiles.count > 0 {
                self.lblEmpty.isHidden = true
                self.scrlViBrowse.isHidden = false
                self.sortProfilesByZipCodeDistance()
            }
            else {
                self.lblEmpty.isHidden = false
                self.scrlViBrowse.isHidden = true
            }
            
        }) { (error) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
        }
    }
    
    func getFavoriteProfiles()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dispatchGroup = DispatchGroup()
        
        for profileId in self.sharedManager.myUser.arrFavorites
        {
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(profileId).observeSingleEvent(of: .value) { (dataSnapShot) in
                
                if let uid = (dataSnapShot.value as! NSDictionary)["uid"] as? String {
                    if uid != "" {
                        let profile = PKUser()
                        profile.setUser(withDataSnapshot: dataSnapShot)
                        
                        self.arrProfiles.append(profile)
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            
            if self.arrProfiles.count > 0 {
                self.lblEmpty.isHidden = true
                self.scrlViBrowse.isHidden = false
                self.sortProfilesByZipCodeDistance()
            }
            else {
                self.lblEmpty.isHidden = false
                self.scrlViBrowse.isHidden = true
            }
        }
    }
    
    func updateProfile(withIdx:Int)
    {
        let profile = self.arrProfiles[withIdx]
        let viProfile = self.scrlViBrowse.viewWithTag(10000 + withIdx) as! PKProfileView
        
        viProfile.btnLike.setTitle(String(format: " %d Likes", profile.arrLikes.count), for: .normal)
        
        if self.sharedManager.myUser.isFavoriteUser(favUserId: profile.uid!) {
            viProfile.btnFavorite.setImage(UIImage(named: "star-filled"), for: .normal)
        }
        else {
            viProfile.btnFavorite.setImage(UIImage(named: "star-empty"), for: .normal)
        }
        
        var photosCount = profile.arrPhotos.count
        
        /*if photosCount > 1 {
            self.navigationItem.rightBarButtonItems = [self.doneButtonItem, self.playButtonItem]
        }
        else {
            self.navigationItem.rightBarButtonItems = [self.doneButtonItem]
        }*/
        
        if photosCount > 3 {
            photosCount = 3
        }
        
        if photosCount - 1 >= self.currentPhotoIdxOnCurrentPage {
            
            for viTemp in viProfile.viPhotoButtons.subviews {
                let btnPhoto = viTemp as! UIButton
                if btnPhoto.tag == self.currentPhotoIdxOnCurrentPage {
                    btnPhoto.layer.borderColor = ColorPalette.pkRed.cgColor
                }
                else {
                    btnPhoto.layer.borderColor = ColorPalette.pkGreen.cgColor
                }
            }
            
            if profile.vehicleType == PKVehicleType.car {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos[self.currentPhotoIdxOnCurrentPage]), placeholderImage:UIImage(named: "icon_car_h"),  completed: nil)
            }
            else if profile.vehicleType == PKVehicleType.truck {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos[self.currentPhotoIdxOnCurrentPage]), placeholderImage:UIImage(named: "icon_truck_h2"),  completed: nil)
            }
            else if profile.vehicleType == PKVehicleType.motorcycle {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos[self.currentPhotoIdxOnCurrentPage]), placeholderImage:UIImage(named: "icon_motorcycle_h"),  completed: nil)
            }
        }
        
    }
    
    func numberOfSocialLinks(profile: PKUser) -> Int {
        var count = 0
        for strLink in profile.arrSocialLinks {
            if strLink.contains("instagram.com") {
                count = count + 1
            }
        }
        if count > 2 {
            return 2
        }
        return count
    }
    
    func loadProfilePhotos()
    {
        for anyView in self.scrlViBrowse.subviews
        {
            anyView.removeFromSuperview()
        }
        
        if self.arrProfiles.count > 0
        {
            //self.currentPage = 0
            self.getCurrentUserEmojis()
        }
        self.scrlViBrowse.frame = CGRect(x: 0, y: self.scrlViBrowse.frame.origin.y, width: SCREEN_WIDTH, height: 410.0)
        self.scrlViBrowse.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(self.arrProfiles.count), height: 410.0)
        self.scrlViBrowse.isPagingEnabled = true
        
        self.lblAboutMe.frame = CGRect(x: 8, y: self.scrlViBrowse.frame.origin.y + 404, width: 200, height: 12)
        self.lblKarglyphics.frame = CGRect(x: SCREEN_WIDTH - 8 - 64, y: self.lblAboutMe.frame.origin.y, width: 64, height: 12)
        
        let tabBarHeight = tabBarController?.tabBar.frame.size.height

        if SCREEN_HEIGHT > 667.0 {
            self.cltViEmojis.frame = CGRect(x: 8.0, y: self.scrlViBrowse.frame.origin.y + 418.0, width: SCREEN_WIDTH - 16.0, height: SCREEN_HEIGHT - self.scrlViBrowse.frame.origin.y - 418.0 - tabBarHeight!)

            self.cltViEmojis.showsHorizontalScrollIndicator = false
            self.cltViEmojis.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 8.0, bottom: 8.0, right: 8.0)
            if let layout = self.cltViEmojis.collectionViewLayout as? UICollectionViewFlowLayout {
                
                if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                        
                    case 1920, 2208, 2436:
                        print("iPhone 6+/6S+/7+/8+ X XS")
                        layout.itemSize = CGSize(width: 40.0, height: 40.0)
                        break
                        
                    default:
                        print("Unknown")
                        layout.itemSize = CGSize(width: 60.0, height: 60.0)
                        break

                    }
                }
                
                layout.scrollDirection = .vertical
                layout.invalidateLayout()
            }
        }
        else {
            self.cltViEmojis.frame = CGRect(x: 8.0, y: self.scrlViBrowse.frame.origin.y + 418.0, width: SCREEN_WIDTH - 16.0, height: 84.0)

            self.cltViEmojis.showsHorizontalScrollIndicator = true
            self.cltViEmojis.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 8.0, bottom: 8.0, right: 0)

            if let layout = self.cltViEmojis.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.itemSize = CGSize(width: 60.0, height: 60.0)
                layout.scrollDirection = .horizontal
                layout.invalidateLayout()
            }
        }

        for i in 0...self.arrProfiles.count - 1
        {
            let profile = self.arrProfiles[i]
            
            let viProfile:PKProfileView = UIView.fromNib()
            
            let calculatedHeight = 344 + (CGFloat(self.numberOfSocialLinks(profile: profile)) * 20.0) + 8
            let profileHeight = calculatedHeight > 360 ? calculatedHeight : 360
            
            viProfile.frame = CGRect(x: SCREEN_WIDTH * CGFloat(i), y: 0, width: SCREEN_WIDTH, height: profileHeight)
            
            viProfile.viContents.frame = CGRect(x: 8, y: 8, width: viProfile.frame.size.width - 16, height: viProfile.frame.size.height - 8)

            viProfile.viContents.layer.masksToBounds = true
            viProfile.viContents.layer.cornerRadius = 3.0
            viProfile.viContents.layer.borderColor = ColorPalette.pkGray.cgColor
            viProfile.viContents.layer.borderWidth = 1.0
            
            viProfile.imgViGender.layer.masksToBounds = true
            viProfile.imgViGender.layer.cornerRadius = viProfile.imgViGender.frame.size.height / 2.0
            viProfile.imgViGender.layer.borderColor = UIColor.black.cgColor
            viProfile.imgViGender.layer.borderWidth = 0.5
            
            if profile.gender == PKGender.male {
                viProfile.imgViGender.image = UIImage(named: "male_empty")
            }
            else if profile.gender == PKGender.female
            {
                viProfile.imgViGender.image = UIImage(named: "female_empty")
            }
            else if profile.gender == PKGender.neutral
            {
                viProfile.imgViGender.image = UIImage(named: "alien_empty")
            }
            
            viProfile.lblUsername.text = profile.username
            
            if profile.isVerified {
                let userNameWidth = profile.username!.widthOfString(usingFont: UIFont.systemFont(ofSize: 14.0))

                viProfile.markVerified.frame = CGRect(x: viProfile.lblUsername.frame.origin.x + userNameWidth + 6, y: viProfile.markVerified.frame.origin.y, width: 16, height: 16)
                viProfile.markVerified.isHidden = false
            }
            else {
                viProfile.markVerified.isHidden = true
            }
            
            viProfile.lblLocation.text = profile.city! + ", " + profile.state!
            
            var index = 0
            for strLink in profile.arrSocialLinks
            {
                
                /*if strLink.contains("facebook.com"){
                    icon.image = UIImage(named: "icon_facebook")
                }
                else if strLink.contains("twitter.com")
                {
                    icon.image = UIImage(named: "icon_twitter")
                }
                else */
                if index == 2 {
                    break
                }
                
                if strLink.contains("instagram.com")
                {
                    let icon = UIImageView(frame: CGRect(x: 8, y: 344 + index * 20, width: 14, height: 14))
                    icon.contentMode = .scaleAspectFit
                    icon.clipsToBounds = true
                    
                    icon.image = UIImage(named: "icon_instagram")
                    
                    viProfile.viContents.addSubview(icon)
                    
                    let btnLink = UIButton(type: .custom)
                    let linkButtonWidth = strLink.size(withAttributes:[.font: UIFont.systemFont(ofSize:10.0)]).width + 4
                    btnLink.frame = CGRect(x:  28, y: 344 + index * 20, width: Int(linkButtonWidth), height: 14)
                    btnLink.setTitle(strLink, for: .normal)
                    btnLink.setTitleColor(ColorPalette.pkLink, for: .normal)
                    btnLink.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
                    
                    btnLink.addTarget(self, action: #selector(onTapSocialLink(sender:)), for: .touchUpInside)
                    viProfile.viContents.addSubview(btnLink)
                    
                    index = index + 1
                }
                /*else if strLink.contains("snapchat.com")
                {
                    icon.image = UIImage(named: "icon_snapchat")
                }*/
            }
            
            if profile.vehicleType == PKVehicleType.spectator {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_spectator_h"),  completed: nil)
                viProfile.btnHashtag.isHidden = true
                viProfile.btnFavorite.isHidden = true
                viProfile.btnLike.isHidden = true
                
                viProfile.tag = 10000 + i
                self.scrlViBrowse.addSubview(viProfile)
                continue
            }
            else if profile.vehicleType == PKVehicleType.car {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_car_h"),  completed: nil)
            }
            else if profile.vehicleType == PKVehicleType.truck {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_truck_h2"),  completed: nil)
            }
            else if profile.vehicleType == PKVehicleType.motorcycle {
                viProfile.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_motorcycle_h"),  completed: nil)
            }
            
            
            var photosCount = profile.arrPhotos.count
            if photosCount > 3 {
                photosCount = 3
            }
            
            for photoIdx in 0...photosCount - 1
            {
                let photo = profile.arrPhotos[photoIdx]
                let btnPhoto = UIButton(type: .custom)
                btnPhoto.layer.borderWidth = 0.6
                btnPhoto.layer.masksToBounds = true
                btnPhoto.layer.cornerRadius = 9.0
                
                if photoIdx == 0 {
                    btnPhoto.layer.borderColor = ColorPalette.pkRed.cgColor
                }
                else {
                    btnPhoto.layer.borderColor = ColorPalette.pkGreen.cgColor
                }
                
                btnPhoto.sd_setImage(with: URL(string: photo), for: .normal, completed: nil)
                
                switch photosCount
                {
                case 3:
                    btnPhoto.frame = CGRect(x: 24.0 * CGFloat(photoIdx), y: 0, width: 18, height: 18)
                    break
                case 2:
                    btnPhoto.frame = CGRect(x:  24.0 * CGFloat(2 - photoIdx), y: 0, width: 18, height: 18)
                    break
                case 1:
                    btnPhoto.frame = CGRect(x: 48.0, y: 0, width: 18, height: 18)
                    break
                default:
                    break
                }
                
                btnPhoto.tag = photoIdx
                btnPhoto.addTarget(self, action: #selector(onSelectPhoto(sender:)), for: .touchDown)
                
                viProfile.viPhotoButtons.addSubview(btnPhoto)
            }
            
            viProfile.btnFavorite.layer.masksToBounds = true
            viProfile.btnFavorite.layer.cornerRadius = viProfile.btnFavorite.frame.size.width / 2.0
            viProfile.btnFavorite.layer.borderColor = ColorPalette.pkGreen.cgColor
            viProfile.btnFavorite.layer.borderWidth = 1.0
            
            if self.sharedManager.myUser.isFavoriteUser(favUserId: profile.uid!) {
                viProfile.btnFavorite.setImage(UIImage(named: "star-filled"), for: .normal)
            }
            else {
                viProfile.btnFavorite.setImage(UIImage(named: "star-empty"), for: .normal)
            }
            viProfile.btnFavorite.tag = i
            viProfile.btnFavorite.addTarget(self, action: #selector(onTapFavorite(sender:)), for: .touchUpInside)
            
            viProfile.btnHashtag.layer.masksToBounds = true
            viProfile.btnHashtag.layer.cornerRadius = viProfile.btnHashtag.frame.size.height / 2.0
            viProfile.btnHashtag.layer.borderColor = ColorPalette.pkLightGray.cgColor
            viProfile.btnHashtag.layer.borderWidth = 1.0
            
            viProfile.btnLike.layer.masksToBounds = true
            viProfile.btnLike.layer.cornerRadius = viProfile.btnLike.frame.size.height / 2.0
            viProfile.btnLike.layer.borderColor = UIColor.white.cgColor
            viProfile.btnLike.layer.borderWidth = 1.0
            viProfile.btnLike.setTitle(String(format: " %d Likes", profile.arrLikes.count), for: .normal)
            viProfile.btnLike.tag = i
            viProfile.btnLike.addTarget(self, action: #selector(onTapLike(sender:)), for: .touchDown)
            
            let hashTagString = "#" + profile.hashtag!
            let hashButtonWidth = hashTagString.size(withAttributes:[.font: UIFont.systemFont(ofSize:12.0)]).width + 16

            viProfile.btnHashtag.frame = CGRect(x: viProfile.viContents.frame.width - 8 - hashButtonWidth, y: viProfile.btnHashtag.frame.origin.y, width: hashButtonWidth, height: 30)
            viProfile.btnHashtag.setTitle(hashTagString, for: .normal)
            viProfile.btnHashtag.tag = i
            viProfile.btnHashtag.addTarget(self, action: #selector(self.onTapHashTag(sender:)), for: .touchDown)
            
            viProfile.btnFavorite.frame = CGRect(x: viProfile.btnHashtag.frame.origin.x - 38, y: viProfile.btnFavorite.frame.origin.y, width: 30, height: 30)
            
            viProfile.imgViPhoto.tag = i
            viProfile.imgViPhoto.isUserInteractionEnabled = true
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.onDoubleTapLike(sender:)))
            doubleTap.numberOfTapsRequired = 2
            viProfile.imgViPhoto.addGestureRecognizer(doubleTap)
            
            viProfile.tag = 10000 + i
            self.scrlViBrowse.addSubview(viProfile)
        }
        
        if self.arrProfiles.count > 0 {
            self.updateProfile(withIdx: 0)
        }
        self.startPhotoSlide()
    }
}
