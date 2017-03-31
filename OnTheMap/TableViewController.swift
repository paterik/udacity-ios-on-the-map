//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//


import UIKit
import BGTableViewRowActionWithImage

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //
    // MARK: IBOutlet variables
    //
    
    @IBOutlet weak var tableView: UITableView!
    
    //
    // MARK: Constants (Normal)
    //
    
    let debugMode: Bool = false
    let clientParse = PRSClient.sharedInstance
    let clientUdacity = UDCClient.sharedInstance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationNoData = ""
    let locationCellHeight: CGFloat = 90.0
    let cellIdentifier = "studentLocationCell"
    let metaDateTimeFormat = "dd.MM.Y hh:mm"
    
    //
    // MARK: Variables
    //
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var locations: [PRSStudentData] { return clientParse.students.locations }
    
    //
    // MARK: UIView Methods (overrides)
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "StudentTableCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView!.reloadData()
        activitySpinner.center = self.view.center
    }
    
    func tableView(
       _ tableView: UITableView,
         numberOfRowsInSection section: Int) -> Int {
        
        return clientParse.students.locations.count
    }
    
    func tableView(
       _ tableView: UITableView,
         cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StudentTableCell!
        let studentLocationMeta = locations[indexPath.row]
        
        cell?.lblStudentName.text = NSString(
            format: "%@ %@",
            studentLocationMeta.firstName ?? locationNoData,
            studentLocationMeta.lastName ?? locationNoData
        ) as String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = PRSClient.sharedInstance.metaDateTimeFormat
        dateFormatter.locale = Locale.init(identifier: NSLocale.current.languageCode!)
        
        let dateObj = dateFormatter.date(from: studentLocationMeta._createdAtRaw as String)
        dateFormatter.dateFormat = metaDateTimeFormat
        
        // set student meta createdAt timestamp as formatted date
        cell?.lblStudentDataTimeStamp.text = "\(dateFormatter.string(from: dateObj!))"
        // set provided mapString, if nothing found take enriched meta for country
        cell?.lblStudentMapString.text = studentLocationMeta.mapString ?? studentLocationMeta.country
        // set distance to student
        cell?.lblStudentDistance.text = studentLocationMeta.distance
        // set country flag for student using enriched data
        cell?.lblStudentMapFlag.text = studentLocationMeta.flag
        
        return cell!
    }
    
    func tableView(
       _ tableView: UITableView,
         heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.locationCellHeight;
    }
    
    func tableView(
       _ tableView: UITableView,
         editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentCellLocation = self.locations[indexPath.row] as PRSStudentData
        
        // definition for my linkButton using 3rd party lib BGTableViewRowActionWithImage
        let link = BGTableViewRowActionWithImage.rowAction(
            with: UITableViewRowActionStyle.default,
            title: "Profile",
            
            backgroundColor: UIColor(netHex: 0x33383C), // 0x33383C
            image: UIImage(named: "icnTableCellProfile_v2"),
            forCellHeight: UInt(self.locationCellHeight)) { action, index in
                
                print (currentCellLocation)
        }
        
        // check if selected row is realy "owned" by current authenticated and show further options
        if currentCellLocation.uniqueKey == clientParse.clientUdacity.clientSession?.accountKey! {

            // definition for my editButton using 3rd party lib BGTableViewRowActionWithImage
            let edit = BGTableViewRowActionWithImage.rowAction(
                with: UITableViewRowActionStyle.default,
                title: " Edit ",
            
                backgroundColor: UIColor(netHex: 0x33383C), // 0x174881
                image: UIImage(named: "icnTableCellEdit_v2"),
                forCellHeight: UInt(self.locationCellHeight)) { action, index in
                
                    print (currentCellLocation)
            }
        
            // definition for my deleteButton also using 3rd party lib BGTableViewRowActionWithImage
            let delete = BGTableViewRowActionWithImage.rowAction(
                with: UITableViewRowActionStyle.destructive,
                title: "Delete",
            
                backgroundColor: UIColor(netHex: 0x33383C), // 0xD30038
                image: UIImage(named: "icnTableCellDelete_v2"),
                forCellHeight: UInt(self.locationCellHeight)) { action, index in
                
                    let locationDestructionWarning = UIAlertController(
                        title: "Removal Warning ...",
                        message: "Do you really want to delete this location?",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    
                    let dlgBtnYesAction = UIAlertAction(title: "Yes", style: .default) { (action: UIAlertAction!) in
                        // execute api call to delete user location object
                        print ("_ delete: ")
                        print (currentCellLocation)
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
    
    func userLocationEditFromRow(
       _ objectId: String!) {
    
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
                
                // remove object id from all corresponding collections
                self.clientParse.students.removeByObjectId(userLocationObjectId)
                self.appDelegate.forceMapReload = true
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
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
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
