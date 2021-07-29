//
//  PKSearchViewController.swift

//
//  Created by Khatib H. on 3/10/19.
//  //

import UIKit
import JHSpinner
import Firebase
import ActionSheetPicker_3_0

class PKSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    private let reuseIdentifier = "PKProfileCell"
    @IBOutlet weak var segSearchFields: UISegmentedControl!
    
    @IBOutlet weak var tblViResults: UITableView!
    @IBOutlet weak var viFilter: UIView!
    @IBOutlet weak var tfSearch: TextField!
    @IBOutlet weak var btnSearch: UIButton!
    
    @IBOutlet weak var btnFilterCar: UIButton!
    @IBOutlet weak var btnFilterTruck: UIButton!
    @IBOutlet weak var btnFilterMotorcycle: UIButton!
    @IBOutlet weak var btnFilterMake: UIButton!
    @IBOutlet weak var switchFilterFemale: UISwitch!
    
    @IBOutlet weak var btnFilterDefault: UIButton!
    @IBOutlet weak var btnFilterDone: UIButton!
    
    let sharedManager:Singleton = Singleton.sharedInstance

    var isCarSelected = true
    var isTruckSelected = true
    var isCycleSelected = true
    var isFemaleOnly = false
    
    var arrProfiles = [PKUser]()
    var arrProfilesWithKeyword = [PKUser]()
    var selectedProfile = PKUser()
    var arrMakes = [String]()
    
    var selectedSearchField = PKSearchField.model
    var selectedMake = ""
    var initMakeIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "SEARCH"
        
        for tabBarItem in (self.tabBarController?.tabBar.items!)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        let filterButtonItem = UIBarButtonItem.init(image: UIImage(named: "icon_filter"), style: .done, target: self, action: #selector(onShowFilter(_:)))
        
        self.navigationItem.rightBarButtonItem = filterButtonItem
        
        tblViResults.register(UINib(nibName: "PKProfileCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        //let navBarHeight = self.navigationController!.navigationBar.frame.height
        //let tabBarHeight = self.tabBarController!.tabBar.frame.height
        
        //tblViResults.frame = CGRect(x: 0, y: 60, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 60 - navBarHeight - tabBarHeight)

        
        btnFilterCar.layer.masksToBounds = true
        btnFilterCar.layer.borderColor = ColorPalette.pkGreen.cgColor
        btnFilterCar.layer.cornerRadius = btnFilterCar.frame.size.height/2.0
        btnFilterCar.layer.borderWidth = 1.0
        
        btnFilterTruck.layer.masksToBounds = true
        btnFilterTruck.layer.borderColor = ColorPalette.pkGreen.cgColor
        btnFilterTruck.layer.cornerRadius = btnFilterTruck.frame.size.height/2.0
        btnFilterTruck.layer.borderWidth = 1.0
        
        btnFilterMotorcycle.layer.masksToBounds = true
        btnFilterMotorcycle.layer.borderColor = ColorPalette.pkGreen.cgColor
        btnFilterMotorcycle.layer.cornerRadius = btnFilterMotorcycle.frame.size.height/2.0
        btnFilterMotorcycle.layer.borderWidth = 1.0
        
        btnFilterMake.layer.masksToBounds = true
        btnFilterMake.layer.borderColor = UIColor.darkGray.cgColor
        btnFilterMake.layer.cornerRadius = btnFilterMake.frame.size.height/2.0
        btnFilterMake.layer.borderWidth = 1.0
        
        btnFilterDefault.layer.masksToBounds = true
        btnFilterDefault.layer.borderColor = ColorPalette.pkGreen.cgColor
        btnFilterDefault.layer.cornerRadius = btnFilterDefault.frame.size.height/2.0
        btnFilterDefault.layer.borderWidth = 1.0
        
        btnFilterDone.layer.masksToBounds = true
        btnFilterDone.layer.cornerRadius = btnFilterDone.frame.size.height/2.0
        
        tfSearch.layer.masksToBounds = true
        tfSearch.layer.borderColor =  UIColor.lightGray.cgColor
        tfSearch.layer.cornerRadius = tfSearch.frame.size.height/2.0
        tfSearch.layer.borderWidth = 1.0
        
        btnSearch.layer.masksToBounds = true
        btnSearch.layer.cornerRadius = btnSearch.frame.size.height/2.0
        
        self.reloadDefaultFilters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getProfilesByFilters()
        
        self.arrMakes.removeAll()
        self.arrMakes.append(MAKE_FILTER_NONE)
        if self.isCarSelected || self.isTruckSelected {
            self.arrMakes += self.sharedManager.arrVehicleMakes
        }
        
        if self.isCycleSelected {
            self.arrMakes += self.sharedManager.arrCycleMakes
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
        
        if segue.identifier == "showFilteredProfiles" {
            let viCtrlProfiles = segue.destination as! PKBrowseViewController
            viCtrlProfiles.browseMode = PKProfileBrowseMode.filtered
            
            if self.tfSearch.text?.replacingOccurrences(of: " ", with: "") == "" {
                viCtrlProfiles.arrProfiles = self.arrProfiles
            }
            else {
                viCtrlProfiles.arrProfiles = self.arrProfilesWithKeyword
            }
        }
        else if segue.identifier == "showSingleProfile" {
            let viCtrlProfiles = segue.destination as! PKBrowseViewController
            viCtrlProfiles.browseMode = PKProfileBrowseMode.single
            viCtrlProfiles.arrProfiles = [self.selectedProfile]
        }
        
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfSearch
        {
            textField.resignFirstResponder()
        }
        return true
    }

    // MARK: - Event Handlers
    
    @IBAction func onExploreAll(_ sender: Any) {
        
    }
    
    @IBAction func onSearchTextChange(_ sender: Any) {
        self.arrProfilesWithKeyword.removeAll()
        
        for profile in self.arrProfiles
        {
            switch self.selectedSearchField
            {
            case PKSearchField.model:
                if (profile.vehicleModel?.lowercased().contains(self.tfSearch.text!.lowercased()))!
                {
                    self.arrProfilesWithKeyword.append(profile)
                }
                break
            case PKSearchField.username:
                if (profile.username?.lowercased().contains(self.tfSearch.text!.replacingOccurrences(of: "@", with: "").lowercased()))!
                {
                    self.arrProfilesWithKeyword.append(profile)
                }
                break
                
            case PKSearchField.hashtag:
                if (profile.hashtag?.lowercased().contains(self.tfSearch.text!.replacingOccurrences(of: "#", with: "").lowercased()))!
                {
                    self.arrProfilesWithKeyword.append(profile)
                }
                break
                
            case PKSearchField.lflp:
                if (profile.LFLP?.lowercased().contains(self.tfSearch.text!.lowercased()))!
                {
                    self.arrProfilesWithKeyword.append(profile)
                }
                break
                
            default:
                    break
            }
        }
        self.tblViResults.reloadData()
    }
    
    @objc func onShowFilter(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.viFilter.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 320)
        }) { (complete) in
        }
    }
    
    @IBAction func onFemaleSwitch(_ sender: Any) {
        print(self.switchFilterFemale.isOn)
        self.isFemaleOnly = self.switchFilterFemale.isOn
    }
    
    
    @IBAction func onFilterCar(_ sender: Any) {
        self.isCarSelected =  !self.isCarSelected
        self.selectedMake = ""
        self.reloadFiltersSelected()
    }
    
    @IBAction func onFilterTruck(_ sender: Any) {
        self.isTruckSelected = !self.isTruckSelected
        self.selectedMake = ""
        self.reloadFiltersSelected()
    }
    
    @IBAction func onFilterCycle(_ sender: Any) {
        self.isCycleSelected = !self.isCycleSelected
        self.selectedMake = ""
        self.reloadFiltersSelected()
    }
    
    @IBAction func onFilterDefault(_ sender: Any) {
        self.reloadDefaultFilters()
    }
    
    @IBAction func onFilterDone(_ sender: Any) {

        UIView.animate(withDuration: 0.3, animations: {
            self.viFilter.frame = CGRect(x: 0, y: -320, width: SCREEN_WIDTH, height: 320)
        }) { (complete) in
            self.getProfilesByFilters()
        }
    }
    
    @IBAction func onSelectMake(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Select a Make", rows: self.arrMakes, initialSelection: self.initMakeIdx, doneBlock: { (picker, selectedIdx, selectedValue) in
            self.initMakeIdx = selectedIdx
            self.selectedMake = selectedValue as! String
            
            if self.selectedMake == "" {
                self.btnFilterMake.setTitleColor(UIColor.lightGray, for: .normal)
            }
            else {
                self.btnFilterMake.setTitleColor(UIColor.black, for: .normal)
            }
            
            self.btnFilterMake.setTitle(self.selectedMake, for: .normal)
        }, cancel: { (picker) in
            
        }, origin: sender)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        self.tfSearch.resignFirstResponder()
    }
    
    @IBAction func onSelectSearchField(_ sender: Any) {
        self.selectedSearchField = self.segSearchFields.selectedSegmentIndex
        self.tfSearch.resignFirstResponder()
        self.resetBySelectedSearchField()
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
    
    // MARK: - Own Methods
    
    func getProfilesByFilters()
    {
        self.arrProfiles.removeAll()
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        var arrTypeFilters = [Int]()
        if self.isCarSelected {
            arrTypeFilters.append(PKVehicleType.car)
        }
        if self.isTruckSelected {
            arrTypeFilters.append(PKVehicleType.truck)
        }
        if self.isCycleSelected {
            arrTypeFilters.append(PKVehicleType.motorcycle)
        }
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").observeSingleEvent(of: .value, with: { (snapshot) in
            spinner.dismiss()
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    
                    if let uid = (snap.value as! NSDictionary)["uid"] as? String {
                        if uid != "" {
                            let profile = PKUser()
                            profile.setUser(withDataSnapshot: snap)
                            
                            var isFilteredProfile = true
                            
                            if arrTypeFilters.contains(profile.vehicleType) {
                                isFilteredProfile = true
                            }
                            else {
                                continue
                            }
                            
                            if self.isFemaleOnly
                            {
                                if profile.gender == PKGender.female {
                                    isFilteredProfile = true
                                }
                                else {
                                    continue
                                }
                            }
                            
                            if self.selectedMake != "" && self.selectedMake != MAKE_FILTER_NONE {
                                if self.selectedMake.lowercased() == profile.vehicleMake?.lowercased() {
                                    isFilteredProfile = true
                                }
                                else {
                                    continue
                                }
                            }
                            
                            if isFilteredProfile {
                                self.arrProfiles.append(profile)
                            }
                            
                        }
                    }
                    
                }
            }
            self.tblViResults.reloadData()
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
    }
    
    func reloadDefaultFilters()
    {
        self.isCarSelected = true
        self.isTruckSelected = true
        self.isCycleSelected = true
        
        self.isFemaleOnly = false
        
        self.selectedMake = ""
        
        self.reloadFiltersSelected()
    }
    
    func reloadTypeFilters()
    {
        self.arrMakes.removeAll()
        self.arrMakes.append(MAKE_FILTER_NONE)
        if self.isCarSelected || self.isTruckSelected {
            self.arrMakes += self.sharedManager.arrVehicleMakes
        }
        
        if self.isCycleSelected {
            self.arrMakes += self.sharedManager.arrCycleMakes
        }
        
        if self.isCarSelected
        {
            btnFilterCar.layer.borderColor = UIColor.black.cgColor
            btnFilterCar.backgroundColor = ColorPalette.pkGreen
        }
        else {
            btnFilterCar.layer.borderColor = ColorPalette.pkGreen.cgColor
            btnFilterCar.backgroundColor = UIColor.white
        }
        
        if self.isTruckSelected
        {
            btnFilterTruck.layer.borderColor = UIColor.black.cgColor
            btnFilterTruck.backgroundColor = ColorPalette.pkGreen
        }
        else {
            btnFilterTruck.layer.borderColor = ColorPalette.pkGreen.cgColor
            btnFilterTruck.backgroundColor = UIColor.white
        }
        
        if self.isCycleSelected
        {
            btnFilterMotorcycle.layer.borderColor = UIColor.black.cgColor
            btnFilterMotorcycle.backgroundColor = ColorPalette.pkGreen
        }
        else {
            btnFilterMotorcycle.layer.borderColor = ColorPalette.pkGreen.cgColor
            btnFilterMotorcycle.backgroundColor = UIColor.white
        }
    }
    
    func reloadFiltersSelected()
    {
        
        self.reloadTypeFilters()
        self.switchFilterFemale.isOn = self.isFemaleOnly
        
        if self.selectedMake == ""
        {
            self.btnFilterMake.setTitle("Select a Make", for: .normal)
            self.btnFilterMake.setTitleColor(UIColor.lightGray, for: .normal)
        }
        else {
            self.btnFilterMake.setTitle(self.selectedMake, for: .normal)
            self.btnFilterMake.setTitleColor(UIColor.black, for: .normal)
        }
       
    }
    
    func resetBySelectedSearchField()
    {
        self.tfSearch.text = ""

        switch self.selectedSearchField
        {
        case PKSearchField.username:
            self.tfSearch.placeholder = "Search @username"
            self.tfSearch.keyboardType = .default
            break
            
        case PKSearchField.hashtag:
            self.tfSearch.placeholder = "Search #hashtag"
            self.tfSearch.keyboardType = .default
            break
            
        case PKSearchField.model:
            self.tfSearch.placeholder = "Search vehicle model"
            self.tfSearch.keyboardType = .default
            break
            
        case PKSearchField.lflp:
            self.tfSearch.placeholder = "Search last four of LP"
            self.tfSearch.keyboardType = .numbersAndPunctuation

            break
        default:
            break
        }
        
        self.tblViResults.reloadData()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tfSearch.text?.replacingOccurrences(of: " ", with: "") == "" {
            return self.arrProfiles.count
        }
        else {
            return self.arrProfilesWithKeyword.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? PKProfileCell
            else {
                return UITableViewCell()
        }
        var profile = PKUser()
        
        if self.tfSearch.text?.replacingOccurrences(of: " ", with: "") == "" {
            profile = self.arrProfiles[indexPath.row]
        }
        else {
            profile = self.arrProfilesWithKeyword[indexPath.row]
        }
        
        cell.imgViGender.layer.masksToBounds = true
        cell.imgViGender.layer.cornerRadius = cell.imgViGender.frame.size.height / 2.0
        cell.imgViGender.layer.borderWidth = 0.5
        cell.imgViGender.layer.borderColor = UIColor.darkGray.cgColor
        
        cell.btnHashtag.layer.masksToBounds = true
        cell.btnHashtag.layer.cornerRadius = cell.btnHashtag.frame.size.height / 2.0
        cell.btnHashtag.layer.borderWidth = 0.5
        cell.btnHashtag.layer.borderColor = ColorPalette.pkGreen.cgColor
        
        cell.imgViGender.layer.masksToBounds = true
        cell.imgViGender.layer.cornerRadius = cell.imgViGender.frame.size.height / 2.0
        cell.imgViGender.layer.borderColor = UIColor.darkGray.cgColor
        cell.imgViGender.layer.borderWidth = 0.5
        
        cell.lblUsername.text = profile.username
        
        if profile.isVerified {
            
            let userNameWidth = profile.username!.widthOfString(usingFont: UIFont.systemFont(ofSize: 14, weight: .medium))
            cell.markVerified.frame = CGRect(x: 70 + userNameWidth + 6, y: 8, width: 16, height: 18)
            cell.markVerified.isHidden = false
        }
        else {
            cell.markVerified.isHidden = true
        }
        
        cell.lblMakeModel.text = profile.vehicleMake! + " " + profile.vehicleModel!
        
        if profile.gender == PKGender.male {
            cell.imgViGender.image = UIImage(named: "male_empty")
        }
        else if profile.gender == PKGender.female
        {
            cell.imgViGender.image = UIImage(named: "female_empty")
        }
        else if profile.gender == PKGender.neutral
        {
            cell.imgViGender.image = UIImage(named: "alien_empty")
        }
        
        let hashTagString = "#" + profile.hashtag!
        let hashButtonWidth = hashTagString.size(withAttributes:[.font: UIFont.systemFont(ofSize:12.0)]).width + 16
        
        cell.btnHashtag.frame = CGRect(x: SCREEN_WIDTH - 16 - hashButtonWidth, y: cell.btnHashtag.frame.origin.y, width: hashButtonWidth, height: 28)
        cell.btnHashtag.setTitle(hashTagString, for: .normal)
        cell.btnHashtag.tag = indexPath.row
        cell.btnHashtag.addTarget(self, action: #selector(self.onTapHashTag(sender:)), for: .touchDown)
        
        if profile.vehicleType == PKVehicleType.car {
            cell.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_car_h"),  completed: nil)
        }
        else if profile.vehicleType == PKVehicleType.truck {
            cell.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_truck_h2"),  completed: nil)
        }
        else if profile.vehicleType == PKVehicleType.motorcycle {
            cell.imgViPhoto.sd_setImage(with: URL(string: profile.arrPhotos.first!), placeholderImage:UIImage(named: "icon_motorcycle_h"),  completed: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        if self.tfSearch.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.selectedProfile = self.arrProfiles[indexPath.row]
        }
        else {
            self.selectedProfile = self.arrProfilesWithKeyword[indexPath.row]
        }
        
        performSegue(withIdentifier: "showSingleProfile", sender: tableView.cellForRow(at: indexPath))
        
    }
    
}
