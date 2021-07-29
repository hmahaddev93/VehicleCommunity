//
//  PKNotificationsViewController.swift

//
//  Created by Khatib H. on 3/10/19.
//  //

import UIKit
import Firebase
import JHSpinner

class PKNotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let notiReuseIdentifier = "PKNotificationCell"
    private let chatReuseIdentifier = "PKChatCell"

    private let PK_TAB_NOTIFICATIONS = 0
    private let PK_TAB_CHATS = 1
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var arrNotifications = [PKNotification]()
    var arrChats = [PKChat]()
    var selectedProfile = PKUser()

    @IBOutlet weak var tblViNotification: UITableView!
    @IBOutlet weak var segTabs: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "NOTIFICATIONS"
        
        for tabBarItem in (self.tabBarController?.tabBar.items!)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        tblViNotification.register(UINib(nibName: "PKNotificationCell", bundle: nil), forCellReuseIdentifier: notiReuseIdentifier)
        tblViNotification.register(UINib(nibName: "PKChatCell", bundle: nil), forCellReuseIdentifier: chatReuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChatDeletedByOpposite(notification:)), name: NSNotification.Name(rawValue: "PKChatDeleted"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadSelectedTab()
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
        
        if segue.identifier == "showFromUserProfile" {
            let viCtrlProfiles = segue.destination as! PKBrowseViewController
            viCtrlProfiles.browseMode = PKProfileBrowseMode.single
            viCtrlProfiles.arrProfiles = [self.selectedProfile]
        }
        
    }
    
    // MARK: - Own Methods
    func loadSelectedTab() {
        if self.segTabs.selectedSegmentIndex == PK_TAB_NOTIFICATIONS {
            self.getNotifications()
        }
        else if self.segTabs.selectedSegmentIndex == PK_TAB_CHATS {
            self.getUpdatedProfile()
        }
    }
    
    func checkProfileWithId(userId: String, senderCell: UITableViewCell)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            spinner.dismiss()
            self.selectedProfile = PKUser()
            self.selectedProfile.setUser(withDataSnapshot: snapshot)
            
            self.performSegue(withIdentifier: "showFromUserProfile", sender: senderCell)
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
        
    }
    
    func getNotifications()
    {
        self.arrNotifications.removeAll()
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        
        dbRef.child("pk_notifications").child(self.sharedManager.myUser.uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            spinner.dismiss()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    let notification = PKNotification()
                    notification.setNotification(withDataSnapshot: snap)
                    self.arrNotifications.append(notification)
                }
            }
            self.tblViNotification.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            self.tblViNotification.reloadData()
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
    }
    
    func getUpdatedProfile() {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            spinner.dismiss()
            self.sharedManager.myUser.setUser(withDataSnapshot: dataSnapshot)
            self.getChats()
            
        }, withCancel: { (error) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
        })
    }
    
    func getChats()
    {
        self.arrChats.removeAll()
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dispatchGroup = DispatchGroup()
        
        for chatId in self.sharedManager.myUser.arrChatIds
        {
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("chats").child(chatId).observeSingleEvent(of: .value) { (dataSnapShot) in
                
                print(dataSnapShot.value)
                
                if let dicChat = dataSnapShot.value as? NSDictionary
                {
                    let chat = PKChat()
                    chat.setChat(withChatDic: dicChat, andChatId: dataSnapShot.key)
                    self.arrChats.append(chat)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            self.getChatUsers()
        }
    }
    
    func markChatsChecked()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
    
        
        let dispatchGroup = DispatchGroup()
        for chat in self.arrChats
        {
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("messages").child(chat.id!).queryOrdered(byChild: "created_time_stamp").observeSingleEvent(of: .value) { (dataSnapShot) in
                
                if dataSnapShot.children.allObjects.isEmpty {
                    chat.isChecked = true
                    dispatchGroup.leave()
                }
                else {
                    let lastMsgValue = (dataSnapShot.children.allObjects.last as! DataSnapshot).value as! NSDictionary
                    let lastMsgCreatedTime =  lastMsgValue["created_time_stamp"] as! Double
                    
                    print(lastMsgCreatedTime)
                    dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("chats").child(chat.id!).child("last_check_time").observeSingleEvent(of: .value, with: { (checkTimeSnapshot) in
                        
                        if let checkTimeOfTheChat = checkTimeSnapshot.value as? Double {
                            print(self.sharedManager.stringDateAndTimeForApp(date: Date.init(timeIntervalSince1970: TimeInterval(checkTimeOfTheChat / 1000))))
                            
                            print(self.sharedManager.stringDateAndTimeForApp(date: Date.init(timeIntervalSince1970: TimeInterval(lastMsgCreatedTime / 1000))))
                            
                            if checkTimeOfTheChat > lastMsgCreatedTime {
                                chat.isChecked = true
                            }
                            else {
                                chat.isChecked = false
                            }
                        }
                        else {
                            chat.isChecked = false
                        }
                        
                        dispatchGroup.leave()
                    })
                }
               
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            
            self.tblViNotification.separatorInset = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 12)
            self.tblViNotification.reloadData()
        }
    }
    
    func getChatUsers()
    {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dispatchGroup = DispatchGroup()
        
        var nIdx = 0
        for chat in self.arrChats
        {
            var otherUserId = ""
            if chat.createUserId == self.sharedManager.myUser.uid {
                otherUserId = chat.targetUserId!
            }
            else if chat.targetUserId == self.sharedManager.myUser.uid {
                otherUserId = chat.createUserId!
            }
            else {
                continue
            }
            
            dispatchGroup.enter()
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(otherUserId).observeSingleEvent(of: .value) { (dataSnapShot) in
                
                if let uid = (dataSnapShot.value as! NSDictionary)["uid"] as? String {
                    if uid != "" {
                        let profile = PKUser()
                        profile.setUser(withDataSnapshot: dataSnapShot)
                        chat.otherUser = profile
                    }
                    else {
                        self.arrChats.remove(at: nIdx)
                    }
                }
                else {
                    self.arrChats.remove(at: nIdx)
                }
                
                nIdx += 1
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            self.markChatsChecked()
        }
        
    }
    
    func deleteNotification(notification: PKNotification, notiIdxInFeeds: Int)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("pk_notifications").child(self.sharedManager.myUser.uid!).child(notification.id!).removeValue { (error, dataRef) in
            if error != nil {
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.arrNotifications.remove(at: notiIdxInFeeds)
                self.tblViNotification.reloadData()
            }
        }
    }
    
    func deleteChat(chat: PKChat, chatIdxInFeeds: Int)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("chats").child(chat.id!).removeValue { (error, dataRef) in
            if error != nil {
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                self.deleteChatIdFromUser(userId: chat.createUserId!, chatId: chat.id!, completion: { (isComplete) in
                    
                    self.deleteChatIdFromUser(userId: chat.targetUserId!, chatId: chat.id!, completion: { (isComplete) in
                        spinner.dismiss()
                        
                        self.sharedManager.sendNotificationTo(targetUserToken: chat.otherUser.fcmToken, msgTitle: "A chat deleted", msgBody: "@" + self.sharedManager.myUser.username! + " deleted the chat with you", type: PKNotificationType.deleteChat)

                        self.deleteAllMessagesForChat(chatId: chat.id!, chatIdxInFeeds: chatIdxInFeeds)
                    })
                })
            }
        }
    }
    
    func deleteAllMessagesForChat(chatId: String, chatIdxInFeeds: Int) {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("messages").child(chatId).removeValue { (error, dataRef) in
            if error != nil {
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.sharedManager.myUser.removeChatId(chatId: chatId)
                self.arrChats.remove(at: chatIdxInFeeds)
                self.tblViNotification.reloadData()
            }
        }
    }
    
    func deleteChatIdFromUser(userId: String, chatId: String, completion: @escaping (Bool) -> ()) {
        var isComplete = false
        let dbRef = Database.database().reference()
        
        dbRef.child("user_data").child(userId).child("chats").child(chatId).removeValue(completionBlock: { (error, dataRef) in
            isComplete = true
            completion(isComplete)
        })
        
    }
    
    func showChatDeletedAnimationAndReload(withMsg: String)
    {
        let lblText = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 300)/2.0, y: 250 - 15, width: 300, height: 30))
        lblText.font = UIFont.systemFont(ofSize: 18.0)
        lblText.textColor = UIColor.white
        lblText.text = withMsg
        lblText.textAlignment = .center
        lblText.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        lblText.layer.masksToBounds = true
        lblText.layer.cornerRadius = 4.0
        
        self.view.addSubview(lblText)
        
        lblText.alpha = 0.0
        UIView.animate(withDuration: 0.9, animations: {
            lblText.alpha = 1.0
        }) { (complete) in
            UIView.animate(withDuration: 0.7, animations: {
                lblText.alpha = 0.0
            }) { (complete) in
                lblText.removeFromSuperview()
                self.loadSelectedTab()
            }
        }
    }
    
    // MARK: - Event Handlers
    @objc func onChatDeletedByOpposite(notification:Notification) {
        if self.segTabs.selectedSegmentIndex == PK_TAB_CHATS {
            self.showChatDeletedAnimationAndReload(withMsg: notification.userInfo!["msg"] as! String )
        }
    }
    
    @IBAction func onChangeTab(_ sender: Any) {
        self.loadSelectedTab()
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        self.loadSelectedTab()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.segTabs.selectedSegmentIndex == PK_TAB_NOTIFICATIONS {
            return self.arrNotifications.count
        }
        else if self.segTabs.selectedSegmentIndex == PK_TAB_CHATS {
            return self.arrChats.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.segTabs.selectedSegmentIndex == PK_TAB_CHATS {
            return 68
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.segTabs.selectedSegmentIndex == PK_TAB_NOTIFICATIONS {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: notiReuseIdentifier, for: indexPath) as? PKNotificationCell
                else {
                    return UITableViewCell()
            }
            let notification = self.arrNotifications[indexPath.row]
            
            cell.imgViThumb.layer.masksToBounds = true
            cell.imgViThumb.layer.cornerRadius = cell.imgViThumb.frame.size.height / 2.0
            cell.imgViThumb.layer.borderWidth = 0.5
            cell.imgViThumb.layer.borderColor = UIColor.black.cgColor
            
            cell.lblMessage.text = notification.msgText
            switch notification.fromUserType {
            case PKVehicleType.car:
                cell.imgViThumb.image = UIImage(named: "icon_car_h")
                break
            case PKVehicleType.truck:
                cell.imgViThumb.image = UIImage(named: "icon_truck_h2")
                break
            case PKVehicleType.motorcycle:
                cell.imgViThumb.image = UIImage(named: "icon_motorcycle_h")
                break
            case PKVehicleType.spectator:
                cell.imgViThumb.image = UIImage(named: "icon_spectator_h")
                break
            default:
                break
            }
            
            return cell
        }
        else if self.segTabs.selectedSegmentIndex == PK_TAB_CHATS {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: chatReuseIdentifier, for: indexPath) as? PKChatCell
                else {
                    return UITableViewCell()
            }
            let chat = self.arrChats[indexPath.row]
            
            cell.imgViUserPhoto.layer.masksToBounds = true
            cell.imgViUserPhoto.layer.cornerRadius = cell.imgViUserPhoto.frame.size.height / 2.0
            cell.imgViUserPhoto.layer.borderWidth = 0.5
            cell.imgViUserPhoto.layer.borderColor = ColorPalette.pkGreen.cgColor
            
            cell.lblCheckedMarker.layer.masksToBounds = true
            cell.lblCheckedMarker.layer.cornerRadius = cell.lblCheckedMarker.frame.size.height / 2.0
            
            cell.imgViUserPhoto.sd_setImage(with: URL(string: chat.otherUser.arrPhotos.first!), placeholderImage:UIImage(named: "User"),  completed: nil)
            cell.lblWithUserName.text = chat.otherUser.username
            cell.lblLastMessage.text = chat.lastMessage
            cell.lblDate.text = self.sharedManager.stringDateForApp(date: Date.init(timeIntervalSince1970: TimeInterval(chat.createdTimeStamp / 1000)))
            
            if chat.isChecked {
                cell.lblCheckedMarker.isHidden = true
            }
            else {
                cell.lblCheckedMarker.isHidden = false
            }
            
            if chat.otherUser.isBlockedUser(bUserId: self.sharedManager.myUser.uid!) {
                cell.lblBlockingMark.text = "Blocking you"
                cell.lblBlockingMark.isHidden = false
            }
            else if self.sharedManager.myUser.isBlockedUser(bUserId: chat.otherUser.uid!) {
                cell.lblBlockingMark.text = "Blocked"
                cell.lblBlockingMark.isHidden = false
            }
            else {
                cell.lblBlockingMark.isHidden = true
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { action, index in
            print(index)
            
            if self.segTabs.selectedSegmentIndex == self.PK_TAB_NOTIFICATIONS {
                self.deleteNotification(notification: self.arrNotifications[index.row], notiIdxInFeeds: index.row)
            }
            else if self.segTabs.selectedSegmentIndex == self.PK_TAB_CHATS {
                self.deleteChat(chat: self.arrChats[index.row], chatIdxInFeeds: index.row)
            }
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
    
        if self.segTabs.selectedSegmentIndex == PK_TAB_NOTIFICATIONS {
            let notification = self.arrNotifications[indexPath.row]
            if  notification.type == PKNotificationType.like {
                self.checkProfileWithId(userId: notification.fromUserId!, senderCell: tableView.cellForRow(at: indexPath)!)
            }
        }
        else if self.segTabs.selectedSegmentIndex == PK_TAB_CHATS {
            
            let chat = self.arrChats[indexPath.row]

            if chat.otherUser.isBlockedUser(bUserId: self.sharedManager.myUser.uid!) {
                self.present(self.sharedManager.getAppAlert(withMsg: String(format:
                    "%@ is blocking you.", chat.otherUser.username!)), animated: true, completion: nil)
            }
            else if self.sharedManager.myUser.isBlockedUser(bUserId: chat.otherUser.uid!) {
                self.present(self.sharedManager.getAppAlert(withMsg: String(format:
                    "You blocked %@. Unblock to send message.", chat.otherUser.username!)), animated: true, completion: nil)
            }
            else {
                let storyboard = UIStoryboard(name: "Additional", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "PKChatViewController") as! PKChatViewController
                controller.chat = chat
                controller.senderId = self.sharedManager.myUser.uid
                controller.senderDisplayName = self.sharedManager.myUser.username
                controller.targetUser = chat.otherUser
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        }
    }
}
