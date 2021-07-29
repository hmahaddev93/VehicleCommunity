//
//  PKEditProfileViewController.swift

//
//  Created by Khatib H. on 3/17/19.
//  //

import UIKit
import Firebase
import JHSpinner
import ActionSheetPicker_3_0

class PKEditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tblViProfile: UITableView!
    
    @IBOutlet weak var viInput: UIView!
    @IBOutlet weak var viInputInner: UIView!
    @IBOutlet weak var lblInputTitle: UILabel!
    
    @IBOutlet weak var tfInputValue1: UITextField!
    @IBOutlet weak var tfInputValue2: UITextField!
    
    @IBOutlet weak var btnInputOk: UIButton!
    @IBOutlet weak var btnInputCancel: UIButton!
    
    private let textCellReuseIdentifier = "EditTextTableViewCell"
    private let arrVehicleTypes = ["Car", "Truck", "Motorcycle", "I'm Spectator"]
    
    var nSelectedEditFieldIdx = SELECTED_NONE
    let sharedManager:Singleton = Singleton.sharedInstance
    var arrFields = [[String: String]]()
    
    var arrMakes = [String]()
    var selectedMakeIdx = 0
    var selectedVehicleType = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "EDIT PROFILE"
        
        tblViProfile.register(UINib(nibName: "EditTextTableViewCell", bundle: nil), forCellReuseIdentifier: textCellReuseIdentifier)
        
        self.viInputInner.layer.masksToBounds = true
        self.viInputInner.layer.cornerRadius = 6.0
        
        self.btnInputOk.layer.masksToBounds = true
        self.btnInputOk.layer.cornerRadius = self.btnInputOk.frame.size.height / 2.0
        
        self.tfInputValue1.layer.masksToBounds = true
        self.tfInputValue1.layer.cornerRadius = self.tfInputValue1.frame.size.height / 2.0
        
        self.tfInputValue2.layer.masksToBounds = true
        self.tfInputValue2.layer.cornerRadius = self.tfInputValue2.frame.size.height / 2.0
        
        self.btnInputCancel.layer.masksToBounds = true
        self.btnInputCancel.layer.cornerRadius = self.btnInputCancel.frame.size.height / 2.0
        self.btnInputCancel.layer.borderWidth = 1.0
        self.btnInputCancel.layer.borderColor = ColorPalette.pkGreen.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedVehicleType = self.sharedManager.myUser.vehicleType
        self.reloadFields()
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
    func reloadFields()
    {
        var emailValue = ""
        if self.sharedManager.myUser.isInstagramLogin {
            emailValue = ""
        }
        else {
            emailValue = self.sharedManager.myUser.email!
        }
        
        self.arrFields = [
            ["title": "Change your @username", "value": self.sharedManager.myUser.username, "type": "text"],
            ["title": "Change your email address", "value": emailValue, "type": "text"],
            ["title": "Change your password", "value": "TAP HERE TO CHANGE", "type": "text"],
            ["title": "Change your zipcode", "value": self.sharedManager.myUser.zipCode, "type": "text"],
            //["title": "Change your vehicle type", "value": self.arrVehicleTypes[self.sharedManager.myUser.vehicleType], "type": "picker"],
            //["title": "Change the make of your vehicle", "value": self.sharedManager.myUser.vehicleMake, "type": "picker"],
            ["title": "Change your model name", "value": self.sharedManager.myUser.vehicleModel, "type": "text"],
            ["title": "Change your LFLP", "value": self.sharedManager.myUser.LFLP, "type": "text"],
            ["title": "Change your #hashtag", "value": self.sharedManager.myUser.hashtag, "type": "text"]
            ] as! [[String : String]]
        
        self.tblViProfile.reloadData()
    }
    
    func showAnimationWithText(msgText:String)
    {
        let lblText = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 210)/2.0, y: 150 - 15, width: 210, height: 30))
        lblText.font = UIFont.systemFont(ofSize: 18.0)
        lblText.textColor = UIColor.white
        lblText.text = msgText
        lblText.textAlignment = .center
        lblText.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        lblText.layer.masksToBounds = true
        lblText.layer.cornerRadius = 4.0
        
        self.view.addSubview(lblText)
        
        lblText.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            lblText.alpha = 1.0
        }) { (complete) in
            UIView.animate(withDuration: 0.5, animations: {
                lblText.alpha = 0.0
            }) { (complete) in
                lblText.removeFromSuperview()
            }
        }
    }
    
    func showMakePicker(sender:Any)
    {
        if self.sharedManager.myUser.vehicleType == PKVehicleType.motorcycle {
            self.arrMakes = self.sharedManager.arrCycleMakes
        }
        else {
            self.arrMakes = self.sharedManager.arrVehicleMakes
        }
        
        ActionSheetStringPicker.show(withTitle: "Select a make", rows: self.arrMakes, initialSelection: self.selectedMakeIdx, doneBlock: { (picker, selectedIdx, selectedValue) in
            self.selectedMakeIdx = selectedIdx
            self.updateEdited()
            
        }, cancel: { (picker) in
            
        }, origin: sender)
        
    }
    
    func showVehicleTypePicker(sender:Any)
    {
        ActionSheetStringPicker.show(withTitle: "Select your vehicle type", rows: self.arrVehicleTypes, initialSelection: self.selectedVehicleType, doneBlock: { (picker, selectedIdx, selectedValue) in
            self.selectedVehicleType = selectedIdx
            self.updateEdited()
            
        }, cancel: { (picker) in
            
        }, origin: sender)
        
    }
    
    func showInputView()
    {
        
        let fieldData = self.arrFields[self.nSelectedEditFieldIdx]
        self.lblInputTitle.text = fieldData["title"]?.uppercased()
        
        if self.nSelectedEditFieldIdx == 2 {
            self.viInputInner.frame = CGRect(x: self.viInputInner.frame.origin.x, y: self.viInputInner.frame.origin.y, width: self.viInputInner.frame.size.width, height: 220.0)
            
            self.tfInputValue2.isHidden = false
            self.tfInputValue1.frame = CGRect(x: 16, y: 60, width: 268, height: 36)
            self.tfInputValue2.frame = CGRect(x: 16, y: 106, width: 268, height: 36)
            
            self.tfInputValue1.text = ""
            self.tfInputValue1.placeholder = "Old Password"
            self.tfInputValue2.text = ""
            self.tfInputValue2.placeholder = "New Password"
            
            self.tfInputValue1.isSecureTextEntry = true
            self.tfInputValue2.isSecureTextEntry = true
            
            self.tfInputValue1.returnKeyType = .next
            self.tfInputValue2.returnKeyType = .done
            
        }
        else if self.nSelectedEditFieldIdx == 1 {
            self.viInputInner.frame = CGRect(x: self.viInputInner.frame.origin.x, y: self.viInputInner.frame.origin.y, width: self.viInputInner.frame.size.width, height: 220.0)
            
            self.tfInputValue2.isHidden = false
            self.tfInputValue1.frame = CGRect(x: 16, y: 60, width: 268, height: 36)
            self.tfInputValue2.frame = CGRect(x: 16, y: 106, width: 268, height: 36)
            
            self.tfInputValue1.text = ""
            self.tfInputValue1.placeholder = "New Email Address"
            self.tfInputValue2.text = ""
            self.tfInputValue2.placeholder = "Your Password"
            
            self.tfInputValue1.isSecureTextEntry = false
            self.tfInputValue2.isSecureTextEntry = true
            
            self.tfInputValue1.returnKeyType = .next
            self.tfInputValue2.returnKeyType = .done
            
        }
        else {
            self.viInputInner.frame = CGRect(x: self.viInputInner.frame.origin.x, y: self.viInputInner.frame.origin.y, width: self.viInputInner.frame.size.width, height: 190.0)

            self.tfInputValue2.isHidden = true
            self.tfInputValue1.frame = CGRect(x: 16, y: 70, width: 268, height: 36)
            
            self.tfInputValue1.placeholder = fieldData["title"]
            self.tfInputValue1.text = fieldData["value"]
            
            self.tfInputValue1.isSecureTextEntry = false
            self.tfInputValue1.returnKeyType = .done
        }
        
        if self.nSelectedEditFieldIdx == 1
        {
            self.tfInputValue1.keyboardType = .emailAddress
        }
        else if self.nSelectedEditFieldIdx == 3 //ZipCode
        {
            self.tfInputValue1.keyboardType = .numberPad
        }
        else if self.nSelectedEditFieldIdx == 5 //LFLP
        {
            self.tfInputValue1.keyboardType = .numbersAndPunctuation
        }
        else
        {
            self.tfInputValue1.keyboardType = .default
        }
        
        self.viInput.alpha = 0
        self.viInput.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viInput.alpha = 1.0
        }) { (complete) in
            self.tfInputValue1.becomeFirstResponder()
        }
    }
    
    func validateZipCode(spinner: JHSpinnerView)
    {
        let strZipcode = tfInputValue1.text
        if strZipcode!.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please enter your Zip Code."), animated: true)
            spinner.dismiss()
            return
        }
        
        if !self.sharedManager.isValidUSZipCode(postalCode: strZipcode!)
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Invalid zipcode. Please enter your correct zipcode."), animated: true)
            spinner.dismiss()
            return
        }
        
        let zipCodeInfoUrl = URL(string: String(format: ZipCodeAPI.getLocationInfoURLFormat, ZipCodeAPI.apiKey, strZipcode!))!
        
        let task = URLSession.shared.dataTask(with: zipCodeInfoUrl) {(data, response, error) in
            if(error != nil){
                spinner.dismiss()
                print("Error \(String(describing: error))")
            }
            else {
                
                do {
                    
                    let fetchedDataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    if let errorMessage = fetchedDataDictionary?.object(forKey: "error_msg")
                    {
                        self.present(self.sharedManager.getAppAlert(withMsg: errorMessage as! String), animated: true)
                        spinner.dismiss()
                        return
                    }
                    else {
                        
                        let dbRef = Database.database().reference().child("user_data").child(self.sharedManager.myUser.uid!)
                        let strCity = fetchedDataDictionary?.object(forKey: "city") as! String
                        dbRef.child("city").setValue(strCity, withCompletionBlock: { (error, dataRef) in
                            self.sharedManager.myUser.city = strCity
                        })
                        
                        let strState = fetchedDataDictionary?.object(forKey: "state") as! String
                        dbRef.child("state").setValue(strState, withCompletionBlock: { (error, dataRef) in
                            self.sharedManager.myUser.state = strState
                        })
                        
                        let zipLatitude = fetchedDataDictionary?.object(forKey: "lat")
                        dbRef.child("latitude").setValue(zipLatitude, withCompletionBlock: { (error, dataRef) in
                            self.sharedManager.myUser.zipcodeLatitude = zipLatitude as! Double
                        })
                        
                        let zipLongitude = fetchedDataDictionary?.object(forKey: "lng")
                        dbRef.child("longitude").setValue(zipLongitude, withCompletionBlock: { (error, dataRef) in
                            self.sharedManager.myUser.zipcodeLongitude = zipLongitude as! Double
                        })
                        
                        dbRef.child("zipcode").setValue(strZipcode!, withCompletionBlock: { (error, dataRef) in
                            spinner.dismiss()
                            self.sharedManager.myUser.zipCode = strZipcode
                            
                            self.reloadFields()
                        })
                        
                    }
                    
                }
                catch let error as NSError {
                    spinner.dismiss()
                    print(error.debugDescription)
                }
            }
        }
        task.resume()
    }
    
    
    func updateEdited()
    {
        var fieldName:String = ""
        var valueToUpdate:Any
        
        switch self.nSelectedEditFieldIdx {
        case 0:
            fieldName = "username"
            break
        /*case 4:
            fieldName = "v_type"
            break
        case 5:
            fieldName = "v_make"
            break*/
        case 4:
            fieldName = "v_model"
            break
        case 5:
            fieldName = "LFLP"
            break
        case 6:
            fieldName = "hashtag"
            break
            
        default:
            break
        }
        
        if self.nSelectedEditFieldIdx == 0 && self.tfInputValue1.text!.count > 15 { //username
            self.present(self.sharedManager.getAppAlert(withMsg: "15 characters max for @username!"), animated: true) {
                self.showInputView()
                self.tfInputValue1.becomeFirstResponder()
            }
            return
        }
        
        if self.nSelectedEditFieldIdx == 6 && self.tfInputValue1.text!.count > 15 { //hashtag
            self.present(self.sharedManager.getAppAlert(withMsg: "15 characters max for #hashtag!"), animated: true) {
                self.showInputView()
                self.tfInputValue1.becomeFirstResponder()
            }
            return
        }
        
        if self.nSelectedEditFieldIdx == 5 && self.tfInputValue1.text!.count > 4 { //lflp
            self.present(self.sharedManager.getAppAlert(withMsg: "4 characters max for LFLP!"), animated: true) {
                self.showInputView()
                self.tfInputValue1.becomeFirstResponder()
            }
            return
        }
        
        /*if self.nSelectedEditFieldIdx == 4 {
            valueToUpdate = self.selectedVehicleType
        }
        else if self.nSelectedEditFieldIdx == 5 {
            valueToUpdate = self.arrMakes[self.selectedMakeIdx]
        }
        else {
        }*/
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
 
        valueToUpdate = self.tfInputValue1.text as Any

        if self.nSelectedEditFieldIdx == 1 {
            self.reAuthAndUpdateEmail()
        }
        else if self.nSelectedEditFieldIdx == 2 {
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: self.sharedManager.myUser.email!, password: self.tfInputValue1.text!)
            
            user?.reauthenticateAndRetrieveData(with: credential, completion: { (dataResult, error) in
                if let error = error {
                    // An error happened.
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                    
                } else {
                    // User re-authenticated.
                    Auth.auth().currentUser?.updatePassword(to: self.tfInputValue2.text!) { (error) in
                        
                        if let error = error {
                            // An error happened.
                            spinner.dismiss()
                            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                            
                        } else {
                            spinner.dismiss()
                            self.showAnimationWithText(msgText: "✓ Password changed!")
                        }
                    }
                }
            })
            
        }
        else if self.nSelectedEditFieldIdx == 3 {
            self.validateZipCode(spinner: spinner)
        }
        else {
            
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child(fieldName).setValue(valueToUpdate) { (error, dataRef) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    
                    switch self.nSelectedEditFieldIdx {
                    case 0:
                        self.sharedManager.myUser.username = (valueToUpdate as! String)
                        break
                    /*case 4:
                        self.sharedManager.myUser.vehicleType = self.selectedVehicleType
                        break
                    case 5:
                        self.sharedManager.myUser.vehicleMake = (valueToUpdate as! String)
                        break*/
                    case 4:
                        self.sharedManager.myUser.vehicleModel = (valueToUpdate as! String)
                        break
                    case 5:
                        self.sharedManager.myUser.LFLP = (valueToUpdate as! String)
                        break
                    case 6:
                        self.sharedManager.myUser.hashtag = (valueToUpdate as! String)
                        break
                        
                    default:
                        break
                    }
                    
                    self.reloadFields()
                    
                }
            }
        }
    }
    
    func reAuthAndUpdateEmail() {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let credential = EmailAuthProvider.credential(withEmail: (Auth.auth().currentUser?.email)!, password: self.tfInputValue2.text!)
        
        Auth.auth().currentUser!.reauthenticateAndRetrieveData(with: credential, completion: { (dataResult, error) in
            if let error = error {
                // An error happened.
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                
            } else {
                // User re-authenticated.
                
                Auth.auth().currentUser?.updateEmail(to: self.tfInputValue1.text!, completion: { (error) in
                    if error != nil{
                        spinner.dismiss()
                        self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                    }
                    else {
                        spinner.dismiss()
                        
                        let dbRef = Database.database().reference()
                        dbRef.child("user_data").child(Auth.auth().currentUser!.uid).child("email").setValue(self.tfInputValue1.text)
                        self.sharedManager.myUser.email = self.tfInputValue1.text
                        
                        self.showAnimationWithText(msgText: "✓ Email changed!")
                    }
                })
                
            }
        })
    }
    
// MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfInputValue1 {
            if self.nSelectedEditFieldIdx == 2 {
                self.tfInputValue2.becomeFirstResponder()
            }
            else {
                self.tfInputValue1.resignFirstResponder()
            }
        }
        else if textField == self.tfInputValue2 {
            self.tfInputValue2.resignFirstResponder()
        }
        return true
    }
    
// MARK: - Event Handlers
    @IBAction func onInputOk(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viInput.alpha = 0.0
            
        }) { (complete) in
            self.viInput.isHidden = true
            self.tfInputValue1.resignFirstResponder()
            self.tfInputValue2.resignFirstResponder()
            self.updateEdited()
        }
    }
    
    @IBAction func onInputCancel(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viInput.alpha = 0.0
            
        }) { (complete) in
            self.viInput.isHidden = true
            self.tfInputValue1.resignFirstResponder()
            self.tfInputValue2.resignFirstResponder()
        }
    }
    
    @objc func onLogout(sender: Any) {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        try! Auth.auth().signOut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            spinner.dismiss()
            
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    // MARK: - UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrFields.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
        let btnSignOut = UIButton(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
        btnSignOut.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        btnSignOut.setTitle("LOG OUT", for: .normal)
        btnSignOut.setTitleColor(ColorPalette.pkRed, for: .normal)
        btnSignOut.addTarget(self, action: #selector(onLogout(sender:)), for: .touchUpInside)
        
        footer.addSubview(btnSignOut)
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let fieldData = self.arrFields[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: textCellReuseIdentifier, for: indexPath) as? EditTextTableViewCell
            else {
                return UITableViewCell()
        }
        cell.lblLabel.text = fieldData["title"]?.uppercased()
        cell.lblTitle.text = fieldData["value"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        self.nSelectedEditFieldIdx = indexPath.row
        
        let fieldData = self.arrFields[indexPath.row]
        
        if fieldData["type"] == "picker"
        {
            /*if indexPath.row == 4 { // Vehicle Type Picker
                self.showVehicleTypePicker(sender: tableView.cellForRow(at: indexPath) as Any)
            }
            else if indexPath.row == 5 { // Vehicle Make Picker
                self.showMakePicker(sender: tableView.cellForRow(at: indexPath) as Any)
            }*/
        }
        else {
            self.showInputView()
        }
        
    }
}
