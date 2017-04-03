//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit
import BGTableViewRowActionWithImage
import YNDropDownMenu

class TableViewController: BaseController, UITableViewDataSource, UITableViewDelegate, ControllerCommandProtocol {

    //
    // MARK: IBOutlet variables
    //
    
    @IBOutlet weak var tableView: UITableView!
    
    //
    // MARK: Constants (Normal)
    //
    
    let locationNoData = ""
    let locationCellHeight: CGFloat = 90.0
    let cellNormalIdentifier = "studentLocationCell"
    let cellStatisticIdentifier = "locationStatisticsCell"
    
    //
    // MARK: Variables
    //
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var locations: [PRSStudentData]!
    
    //
    // MARK: UIView Methods (overrides)
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "StudentTableCell", bundle: nil), forCellReuseIdentifier: cellNormalIdentifier)
        tableView.register(UINib(nibName: "StudentTableCellStatistic", bundle: nil), forCellReuseIdentifier: cellStatisticIdentifier)
        
        initMenu()
        initListView( false )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear( animated )
        initListView( false )
        
        activitySpinner.center = self.view.center
    }
    
    func tableView(
       _ tableView: UITableView,
         numberOfRowsInSection section: Int) -> Int {
        
        return locations.count
    }
    
    func tableView(
       _ tableView: UITableView,
         cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellNormal = tableView.dequeueReusableCell(withIdentifier: cellNormalIdentifier) as! StudentTableCell!
        let cellStatistic = tableView.dequeueReusableCell(withIdentifier: cellStatisticIdentifier) as! StudentTableCellStatistic!
        
        if indexPath.row == 0 {
            
            let _numberOfUniqueCountries: Int = clientParse.getNumberOfCountriesFromStudentMeta()
            let _longestDistance: Double = clientParse.getLongestDistanceOfStudentMeta()
            var _longestDistanceString: String! = NSString(format: "%.0f %@", _longestDistance, "m") as String
            
            if  _longestDistance >= 1000.0 {
                _longestDistanceString = NSString(format: "%.0f %@", (_longestDistance / 1000.0), "km") as String
            }
            
            cellStatistic?.lblMetaLocationsOwned.text = "\(clientParse.students.myLocations.count)"
            cellStatistic?.lblMetaLocationsCount.text = "\(clientParse.students.locations.count)"
            cellStatistic?.lblMetaLargestDistance.text = _longestDistanceString
            cellStatistic?.lblMetaNumberOfCountries.text = "\(_numberOfUniqueCountries)"
        }
        
        if indexPath.row > 0 {
            
            let studentLocationMeta = locations[indexPath.row]
            
            cellNormal?.lblStudentName.text = NSString(
                format: "%@ %@",
                studentLocationMeta.firstName ?? locationNoData,
                studentLocationMeta.lastName ?? locationNoData
                ) as String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = PRSClient.sharedInstance.metaDateTimeFormat
            dateFormatter.locale = Locale.init(identifier: NSLocale.current.languageCode!)
            
            let dateObj = dateFormatter.date(from: studentLocationMeta._createdAtRaw as String)
            dateFormatter.dateFormat = metaDateTimeFormat
            
            // check mapString provided by student, take location country if mapstring seems to be empty
            var _mapString: String? = studentLocationMeta.mapString ?? ""
            if  _mapString!.isEmpty {
                _mapString = studentLocationMeta.country
            }
            
            // check flagString for studentLocation, take default one if flagString seems to be empty
            var _flagString: String? = studentLocationMeta.flag
            if  _flagString!.isEmpty {
                _flagString = ("--").getFlagByCountryISOCode()
            }
            
            // set student meta createdAt timestamp as formatted date
            cellNormal?.lblStudentDataTimeStamp.text = "\(dateFormatter.string(from: dateObj!))"
            // set provided mapString, if nothing found take enriched meta for country
            cellNormal?.lblStudentMapString.text = _mapString
            // set calculated distance from your device to student
            cellNormal?.lblStudentDistance.text = studentLocationMeta.distance
            // set country flag for student using enriched data
            cellNormal?.lblStudentMapFlag.text = _flagString
        }
        
        return indexPath.row == 0
            ? cellStatistic!
            : cellNormal!
    }
    
    func tableView(
       _ tableView: UITableView,
         heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.locationCellHeight;
    }
    
    func tableView(
       _ tableView: UITableView,
         editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.row == 0 {
            return []
        }
        
        let currentCellLocation = locations[indexPath.row] as PRSStudentData
        
        // definition for my linkButton using 3rd party lib BGTableViewRowActionWithImage
        let link = BGTableViewRowActionWithImage.rowAction(
            with: UITableViewRowActionStyle.default,
            title: "Profile",
            
            backgroundColor: UIColor(netHex: 0x33383C), // alt.color = 0x33383C
            image: UIImage(named: "icnTableCellProfile_v2"),
            forCellHeight: UInt(self.locationCellHeight)) { (action, index) in
                
                self.openMediaURL(currentCellLocation.mediaURL)
        }
        
        // check if selected row is realy "owned" by current authenticated and show further options
        if currentCellLocation.uniqueKey == clientParse.clientUdacity.clientSession?.accountKey! {

            // definition for my editButton using 3rd party lib BGTableViewRowActionWithImage
            let edit = BGTableViewRowActionWithImage.rowAction(
                with: UITableViewRowActionStyle.default,
                title: " Edit ",
            
                backgroundColor: UIColor(netHex: 0x33383C), // alt.color = 0x174881
                image: UIImage(named: "icnTableCellEdit_v2"),
                forCellHeight: UInt(self.locationCellHeight)) { (action, index) in
                
                    self.userLocationEditFromRow(currentCellLocation)
            }
        
            // definition for my deleteButton also using 3rd party lib BGTableViewRowActionWithImage
            let delete = BGTableViewRowActionWithImage.rowAction(
                with: UITableViewRowActionStyle.destructive,
                title: "Delete",
            
                backgroundColor: UIColor(netHex: 0x33383C), // alt.color = 0xD30038
                image: UIImage(named: "icnTableCellDelete_v2"),
                forCellHeight: UInt(self.locationCellHeight)) { (action, index) in
                
                    let locationDestructionWarning = UIAlertController(
                        title: "Removal Warning ...",
                        message: "Do you really want to delete this location?",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    
                    let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
                        self.userLocationDeleteFromRow(currentCellLocation.objectId!, [indexPath])
                    }
                    
                    let dlgBtnCancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) in
                        return
                    }
                    
                    locationDestructionWarning.addAction(dlgBtnYesAction)
                    locationDestructionWarning.addAction(dlgBtnCancelAction)
                    
                    
                    self.present(locationDestructionWarning, animated: true, completion: nil)
                    
            }
            
            return [link!, edit!, delete!]
        }
        
        return [link!]
    }
    
    /*
     * edit a aspecific userLocation
     */
    func userLocationEditFromRow(
       _ userLocationObject: PRSStudentData) {
        
        appDelegate.inEditMode = true
        appDelegate.forceMapReload = true
        appDelegate.currentUserStudentLocation = userLocationObject
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PageSetRoot") as! LocationEditViewController
        let locationRequestController = UIAlertController(
            title: "Let's start ...",
            message: "Do you want to use your current device location as default for your next steps?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
            
            self.appDelegate.useCurrentDeviceLocation = true
            self.present(vc, animated: true, completion: nil)
        }
        
        let dlgBtnNoAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction!) in
            
            self.appDelegate.useCurrentDeviceLocation = false
            self.present(vc, animated: true, completion: nil)
        }
        
        locationRequestController.addAction(dlgBtnYesAction)
        locationRequestController.addAction(dlgBtnNoAction)
        
        present(locationRequestController, animated: true, completion: nil)
    }
    
    /*
     * delete a specific userLocation from parse api persitence layer
     */
    func userLocationDeleteFromRow(
       _ userLocationObjectId: String!,
       _ indexPath: [IndexPath]) {
        
        self.clientParse.deleteStudentLocation (userLocationObjectId) {
            
            (success, error) in
            
            if success == true {
                
                OperationQueue.main.addOperation {
                    self.clientParse.students.removeByObjectId(userLocationObjectId)
                    self.appDelegate.forceMapReload = true
                    self.initListView( false )
                }
                
            } else {
                
                // client error deleting location? show corresponding message and return ...
                let btnOkAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in return }
                let alertController = UIAlertController(
                    title: "Alert",
                    message: error,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                alertController.addAction(btnOkAction)
                OperationQueue.main.addOperation {
                    self.appDelegate.forceMapReload = true
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
