//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//


import UIKit
import Foundation

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
    let cellIdentifier = "studentLocationCell"
    let locationNoData = ""
    
    //
    // MARK: Variables
    //
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    //
    // MARK: UIView Methods (overrides)
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // let views = Bundle.main.loadNibNamed("StudentMapAnnotation", owner: nil, options: nil)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StudentTableCell!
        let studentLocationMeta = clientParse.students.locations[indexPath.row]
        
        cell?.lblStudentName.text = NSString(
            format: "%@ %@ %@",
            studentLocationMeta.firstName ?? locationNoData,
            studentLocationMeta.lastName ?? locationNoData,
            studentLocationMeta.flag
        ) as String
        
        cell?.lblStudentMapString.text = NSString(
            format: "%@",
            studentLocationMeta.mapString ?? locationNoData
        ) as String
        
        cell?.lblStudentDistance.text = studentLocationMeta.distance
        
        return cell!
    }
}
