//
//  PKEditEmojisViewController.swift

//
//  Created by Khatib H. on 4/3/19.
//  //

import UIKit
import JHSpinner
import Firebase

class PKEditEmojisViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cltViEmojiKeyboard: UICollectionView!
    @IBOutlet weak var cltViEmoji: UICollectionView!
    @IBOutlet weak var viKeyboard: UIView!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var btnDeleteKey: UIButton!
    @IBOutlet weak var btnTapToEdit: UIButton!
    
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var btnEmojiTypeSigns: UIButton!
    @IBOutlet weak var btnEmojiTypeEngines: UIButton!
    @IBOutlet weak var btnEmojiTypeDesigns: UIButton!
    @IBOutlet weak var btnEmojiTypeEnergy: UIButton!
    @IBOutlet weak var btnEmojiTypeHandTools: UIButton!
    @IBOutlet weak var btnEmojisWithLink: UIButton!
    @IBOutlet weak var markSelectedType: UILabel!
    
    private let emojiCellIdentifier = "PKEmojiCollectionCell"
    private let emojiKeyCellIdentifier = "PKEmojiKeyCollectionCell"
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var arrRideEmojis = [PKEmoji]()
    var arrAllEmojis = [PKEmoji]()
    var arrEmojisByType = [PKEmoji]()
    var emojiKeyboardFrame = CGRect()
    var isKeyboardShown = false
    
    var selectedEmojiType = PKEmojiType.signs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "DESCRIBE YOUR RIDE"
        
        let doneButtonItem = UIBarButtonItem(title: "DONE", style: .done, target: self, action: #selector(onDone(_:)))
        self.navigationItem.rightBarButtonItem = doneButtonItem
        
        self.btnDismiss.layer.borderColor = UIColor.white.cgColor
        self.btnDismiss.layer.borderWidth = 1.0
        
        self.btnEmojiTypeSigns.layer.masksToBounds = true
        self.btnEmojiTypeSigns.layer.cornerRadius = 2.0
        self.btnEmojiTypeSigns.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeSigns.layer.borderWidth = 1.5
        
        self.btnEmojiTypeDesigns.layer.masksToBounds = true
        self.btnEmojiTypeDesigns.layer.cornerRadius = 2.0
        self.btnEmojiTypeDesigns.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeDesigns.layer.borderWidth = 1.5
        
        self.btnEmojiTypeEngines.layer.masksToBounds = true
        self.btnEmojiTypeEngines.layer.cornerRadius = 2.0
        self.btnEmojiTypeEngines.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeEngines.layer.borderWidth = 1.5
        
        self.btnEmojiTypeEnergy.layer.masksToBounds = true
        self.btnEmojiTypeEnergy.layer.cornerRadius = 2.0
        self.btnEmojiTypeEnergy.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeEnergy.layer.borderWidth = 1.5
        
        self.btnEmojiTypeHandTools.layer.masksToBounds = true
        self.btnEmojiTypeHandTools.layer.cornerRadius = 2.0
        self.btnEmojiTypeHandTools.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeHandTools.layer.borderWidth = 1.5
        
        self.btnEmojisWithLink.layer.masksToBounds = true
        self.btnEmojisWithLink.layer.cornerRadius = 2.0
        self.btnEmojisWithLink.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojisWithLink.layer.borderWidth = 1.5
        
        self.btnDeleteKey.layer.borderColor = ColorPalette.pkRed.cgColor
        self.btnDeleteKey.layer.borderWidth = 1.0
        
        cltViEmoji.alwaysBounceVertical = true
        cltViEmoji.register(UINib(nibName: "PKEmojiCollectionCell", bundle: nil), forCellWithReuseIdentifier: emojiCellIdentifier)
        cltViEmoji.layer.masksToBounds = true
        cltViEmoji.layer.cornerRadius = 4.0
        cltViEmoji.layer.borderColor = UIColor.lightGray.cgColor
        cltViEmoji.layer.borderWidth = 1.0
        
        cltViEmojiKeyboard.alwaysBounceVertical = true
        cltViEmojiKeyboard.register(UINib(nibName: "PKEmojiKeyCollectionCell", bundle: nil), forCellWithReuseIdentifier: emojiKeyCellIdentifier)
        
        let tapBg = UITapGestureRecognizer(target: self, action: #selector(onTapBg(sender:)))
        self.cltViEmoji.addGestureRecognizer(tapBg)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emojiKeyboardFrame = self.viKeyboard.frame
        self.viKeyboard.frame = CGRect(x: 0, y: self.emojiKeyboardFrame.origin.y + 238, width: SCREEN_WIDTH, height: 238)
        self.getMyRideEmojis()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust cell width to screensize.
        if let layout1 = cltViEmojiKeyboard.collectionViewLayout as? UICollectionViewFlowLayout {
            layout1.itemSize = CGSize(width: 40, height: 40)
            layout1.scrollDirection = .vertical
            layout1.invalidateLayout()
        }
        
        if let layout = cltViEmoji.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 48, height: 48)
            layout.scrollDirection = .vertical
            layout.invalidateLayout()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Own Methods
    func isEmojiAlreadyWritten(emoji: PKEmoji) -> Bool {
        for emojiTemp in self.arrRideEmojis {
            if emojiTemp.emojiId == emoji.emojiId {
                return true
            }
        }
        return false
    }
    
    func reloadEmojiKeysBySelectedKeyType()
    {
        self.btnEmojiTypeSigns.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeEnergy.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeHandTools.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeDesigns.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojiTypeEngines.layer.borderColor = UIColor.clear.cgColor
        self.btnEmojisWithLink.layer.borderColor = UIColor.clear.cgColor

        switch self.selectedEmojiType {
        case PKEmojiType.signs:
            self.btnEmojiTypeSigns.layer.borderColor = ColorPalette.pkGreen.cgColor
            UIView.animate(withDuration: 0.2) {
                self.markSelectedType.frame = CGRect(x: self.btnEmojiTypeSigns.frame.origin.x, y: 44, width: self.btnEmojiTypeSigns.frame.size.width, height: 6)
            }
            break
            
        case PKEmojiType.designs:
            self.btnEmojiTypeDesigns.layer.borderColor = ColorPalette.pkGreen.cgColor
            UIView.animate(withDuration: 0.2) {
                self.markSelectedType.frame = CGRect(x: self.btnEmojiTypeDesigns.frame.origin.x, y: 44, width: self.btnEmojiTypeDesigns.frame.size.width, height: 6)
            }
            break
            
        case PKEmojiType.engineTypes:
            self.btnEmojiTypeEngines.layer.borderColor = ColorPalette.pkGreen.cgColor
            UIView.animate(withDuration: 0.2) {
                self.markSelectedType.frame = CGRect(x: self.btnEmojiTypeEngines.frame.origin.x, y: 44, width: self.btnEmojiTypeEngines.frame.size.width, height: 6)
            }
            break
            
        case PKEmojiType.energy:
            self.btnEmojiTypeEnergy.layer.borderColor = ColorPalette.pkGreen.cgColor
            UIView.animate(withDuration: 0.2) {
                self.markSelectedType.frame = CGRect(x: self.btnEmojiTypeEnergy.frame.origin.x, y: 44, width: self.btnEmojiTypeEnergy.frame.size.width, height: 6)
            }
            break
       
        case PKEmojiType.handTool:
            self.btnEmojiTypeHandTools.layer.borderColor = ColorPalette.pkGreen.cgColor
            UIView.animate(withDuration: 0.2) {
                self.markSelectedType.frame = CGRect(x: self.btnEmojiTypeHandTools.frame.origin.x, y: 44, width: self.btnEmojiTypeHandTools.frame.size.width, height: 6)
            }
            break
            
        case PKEmojiType.withLink:
            self.btnEmojisWithLink.layer.borderColor = ColorPalette.pkGreen.cgColor
            UIView.animate(withDuration: 0.2) {
                self.markSelectedType.frame = CGRect(x: self.btnEmojisWithLink.frame.origin.x, y: 44, width: self.btnEmojisWithLink.frame.size.width, height: 6)
            }
            break
        default:
            break
        }
        
        self.arrEmojisByType.removeAll()
        for emoji in self.arrAllEmojis
        {
            if self.selectedEmojiType == PKEmojiType.withLink {
                if emoji.linkURLString != "" {
                    self.arrEmojisByType.append(emoji)
                }
            }
            else {
                if emoji.type == self.selectedEmojiType {
                    self.arrEmojisByType.append(emoji)
                }
            }
            
        }
        
        self.cltViEmojiKeyboard.reloadData()
    }
    
    func showEmojiKeyboard()
    {
        if self.isKeyboardShown
        {
            return
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.viKeyboard.frame = self.emojiKeyboardFrame
        }) { (complete) in
            self.isKeyboardShown = true
            self.reloadEmojiKeysBySelectedKeyType()
        }
    }
    
    func hideEmojiKeyboard()
    {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viKeyboard.frame = CGRect(x: 0, y: self.emojiKeyboardFrame.origin.y + 238, width: SCREEN_WIDTH, height: 238)
        }) { (complete) in
            self.isKeyboardShown = false
        }
    }
    
    func getMyRideEmojis()
    {
        self.arrRideEmojis.removeAll()
        
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
                
                self.arrRideEmojis.append(emoji)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            spinner.dismiss()
            if self.arrRideEmojis.count > 0 {
                self.btnTapToEdit.isHidden = true
            }
            else {
                self.btnTapToEdit.isHidden = false
            }
            self.cltViEmoji.reloadData()
            self.getAllEmojis()
        }
    }
    
    func getAllEmojis()
    {
        self.arrAllEmojis.removeAll()
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("emojis").observeSingleEvent(of: .value, with: { (snapshot) in
            spinner.dismiss()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    
                    let emoji = PKEmoji()
                    emoji.setEmoji(withDataSnapshot: snap)
                    self.arrAllEmojis.append(emoji)
                }
            }
            self.cltViEmojiKeyboard.reloadData()
            self.showEmojiKeyboard()
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
    }
    
    // MARK: - Event Handlers
    @objc func onTapBg(sender:Any)
    {
        self.showEmojiKeyboard()
    }
    
    @IBAction func onSelectSignsEmoji(_ sender: Any) {
        self.selectedEmojiType = PKEmojiType.signs
        self.reloadEmojiKeysBySelectedKeyType()
    }
    
    @IBAction func onSelectDesignsEmoji(_ sender: Any) {
        self.selectedEmojiType = PKEmojiType.designs
        self.reloadEmojiKeysBySelectedKeyType()

    }
    
    @IBAction func onSelectEnginesEmoji(_ sender: Any) {
        self.selectedEmojiType = PKEmojiType.engineTypes
        self.reloadEmojiKeysBySelectedKeyType()

    }
    
    @IBAction func onSelectEnergyEmoji(_ sender: Any) {
        self.selectedEmojiType = PKEmojiType.energy
        self.reloadEmojiKeysBySelectedKeyType()
    }
    
    @IBAction func onSelectHandToolEmoji(_ sender: Any) {
        self.selectedEmojiType = PKEmojiType.handTool
        self.reloadEmojiKeysBySelectedKeyType()
    }
    
    @IBAction func onSelectLinkedEmoji(_ sender: Any) {
        
        self.selectedEmojiType = PKEmojiType.withLink
        self.reloadEmojiKeysBySelectedKeyType()
    }
    
    @objc func onDone(_ sender: Any) {
        var arrEmojiIdsToPost = [String]()
        for emoji in self.arrRideEmojis
        {
            arrEmojiIdsToPost.append(emoji.emojiId!)
        }
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("ride_emojis").setValue(arrEmojiIdsToPost) { (error, dataRef) in
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.sharedManager.myUser.arrRideEmojis = self.arrRideEmojis
                self.sharedManager.myUser.arrRideEmojiIds = arrEmojiIdsToPost
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func onDismissKeyboard(_ sender: Any) {
        self.hideEmojiKeyboard()
    }
    
    @IBAction func onDelKey(_ sender: Any) {
        if self.arrRideEmojis.count > 0 {
            self.arrRideEmojis.removeLast()
            self.cltViEmoji.reloadData()
        }
    }
    
    @IBAction func onTapToEdit(_ sender: Any) {
        self.showEmojiKeyboard()
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.cltViEmojiKeyboard {
            return self.arrEmojisByType.count
        }
        else {
            return self.arrRideEmojis.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.cltViEmojiKeyboard {
            let emojiKeyCell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiKeyCellIdentifier, for: indexPath) as! PKEmojiKeyCollectionCell
            let emoji = self.arrEmojisByType[indexPath.row]
            
            emojiKeyCell.imgViEmoji.sd_setImage(with: URL(string: emoji.imageURL!), completed: nil)
            
            return emojiKeyCell
        }
        else {
            let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellIdentifier, for: indexPath) as! PKEmojiCollectionCell
            
            let emoji = self.arrRideEmojis[indexPath.row]
            
            emojiCell.imgViEmoji.sd_setImage(with: URL(string: emoji.imageURL!), completed: nil)
            
            return emojiCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.cltViEmojiKeyboard
        {
            let cell = collectionView.cellForItem(at: indexPath) as! PKEmojiKeyCollectionCell
            
            cell.imgViEmoji.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.0)
            UIView.animate(withDuration: 0.2, animations: {
                cell.imgViEmoji.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
            }) { (complete) in
                
                UIView.animate(withDuration: 0.2, animations: {
                    cell.imgViEmoji.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.0)
                })
            }
            
            let emojiSelected = self.arrEmojisByType[indexPath.row]
            
            if self.isEmojiAlreadyWritten(emoji: emojiSelected) {
                self.lblWarning.isHidden = false
            }
            else {
                self.lblWarning.isHidden = true
                if self.arrRideEmojis.count < PK_EMOJI_DESCRIPTION_MAX
                {
                    self.btnTapToEdit.isHidden = true
                    self.arrRideEmojis.append(emojiSelected)
                    self.cltViEmoji.reloadData()
                }
            }
           
        }
    }
    
}
