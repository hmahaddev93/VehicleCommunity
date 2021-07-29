//
//  PKChatViewController.swift

//
//  Created by Khatib H. on 4/19/19.
//  //

import UIKit
import JSQMessagesViewController
import Firebase
import SDWebImage
import JHSpinner

class PKChatViewController: JSQMessagesViewController {

    // MARK: - Properties
    var messages = [JSQMessage]()
    var targetUser = PKUser()
    var immediateMsgText:String = ""
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var chat: PKChat? {
        didSet {
            //title = chat?.title
        }
    }
    private var chatMessagesRef: DatabaseReference!
    private lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    private lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chatId = chat?.id else {
            return
        }
        
        chatMessagesRef = Database.database().reference().child("messages").child(chatId)
        
        // Pull existing messages and watch for new messages in the chat.
        observeMessages(chatId: chatId)
        
        // Remove avatars from messages.
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Remove media attachment icon.
        inputToolbar.contentView.leftBarButtonItem = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChatDeletedByOpposite(notification:)), name: NSNotification.Name(rawValue: "PKChatDeleted"), object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "@" + targetUser.username!
        
        var imgTargetUser = UIImage(named: "User")
        imgTargetUser = imgTargetUser?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: imgTargetUser, style:.plain, target: self, action: #selector(onTargetUserProfile(sender:)))
        
        if self.immediateMsgText != "" {
            inputToolbar.contentView.textView.text = self.immediateMsgText
            self.immediateMsgText = ""
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateMyLastCheckTimeForChat()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    /**
     Adds messages to JSQMessages.
     Message's displayName (user's name) is not being used at the moment.
     Updates chat's last message.
     */
    private func addMessage(_ message: PKMessage) {
        messages.append(JSQMessage(senderId: message.senderId, displayName: "test", text: message.text))
        
        // Update chat's new message, so when returning to previous screen, last message is properly updated.
        chat?.lastMessage = message.text
    }
    
    /**
     Populates messages and watches for new messages.
     */
    private func observeMessages(chatId: String) {
        // Observe for new messages from reference to chat's messages.
        chatMessagesRef.queryOrdered(byChild: "created_time_stamp").observe(.childAdded, with: { (snapshot) in
            
            let message = PKMessage()
            message.setMessage(withDataSnapshot: snapshot)
            
            self.addMessage(message)
            self.finishReceivingMessage()
        })
    }
    
    /**
     Sets up outgoing bubble image for UI.
     */
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    /**
     Sets up incoming bubble image for UI.
     */
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    // MARK: - Own Methods
    func updateMyLastCheckTimeForChat() {
        
        //let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        //self.view.addSubview(spinner)
        let updateValue = ["id": self.chat!.id as Any,
                           "last_check_time": ServerValue.timestamp()]
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("chats").child(self.chat!.id!).setValue(updateValue) { (error, dataRef) in
            
            //spinner.dismiss()
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                print("chat check date updated")
            }
            
        }
    }
    
    func writeChatMessage(chatId: String, senderId: String, messageText: String) {
        
        if self.messages.count == 0 {
            self.sharedManager.sendNotificationTo(targetUserToken: targetUser.fcmToken, msgTitle: targetUser.username! + " sent a message", msgBody: messageText, type: PKNotificationType.newChat)
        }
        
        let chatMessageRef = Database.database().reference().child("messages/\(chatId)").childByAutoId()
        let message: [String: Any] = [
            "sender_id": senderId,
            "text": messageText,
            "created_time_stamp": ServerValue.timestamp()
        ]
        
        chatMessageRef.setValue(message)
        updateChatLastMessage(chatId: chatId, messageText: messageText)
    }
    
    func updateChatLastMessage(chatId: String, messageText: String) {
        let chatRef1 = Database.database().reference().child("chats/\(chatId)/last_message")
        chatRef1.setValue(messageText)
        
        let chatRef2 = Database.database().reference().child("chats/\(chatId)/created_time_stamp")
        chatRef2.setValue(ServerValue.timestamp())

    }
    
    func showDeletedAnimationAndExit()
    {
        let lblText = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 300)/2.0, y: 250 - 15, width: 300, height: 30))
        lblText.font = UIFont.systemFont(ofSize: 18.0)
        lblText.textColor = UIColor.white
        lblText.text = "Counterpart deleted this chat."
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
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Event Handlers
    
    @objc func onChatDeletedByOpposite(notification:Notification) {
        self.showDeletedAnimationAndExit()
    }
    
    @objc func onTargetUserProfile(sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKBrowseViewController") as! PKBrowseViewController
        controller.browseMode = PKProfileBrowseMode.single
        controller.arrProfiles = [self.targetUser]
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - JSQMessagesViewController
    // Respond to send button press.
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard let chatId = chat?.id else {
            return
        }
        
        writeChatMessage(chatId: chatId, senderId: senderId, messageText: text)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    // Get JSQMessage for the index.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    // Determine which bubble image view to use depending on who sent the message.
    override func collectionView(_ collectionView: UICollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    // Set message bubble text color based on message sender.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    // Remove avatars.
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

}
