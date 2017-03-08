//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 26.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import UIKit

class LocationViewController: UITabBarController {
    
    var client = PRSClient.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        client.getAllStudentLocations() { (success, error) in
            
            
            
        }
    }
}
