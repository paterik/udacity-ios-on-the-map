//
//  StudentMapMenu.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 02.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class StudentMapMenu: UIView {

    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var btnReloadMap: UIButton!
    @IBOutlet weak var btnShowStatistics: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnAddLocation: UIButton!

    //
    // MARK: Variables
    //
    
    var delegate: ControllerCommandProtocol?
    
    //
    // MARK: IBAction Methods
    //
    
    @IBAction func btnAddLocationAction(_ sender: UIButton) {
        
        if let del = delegate { del.handleDelegateCommand("addUserLocationFromMenu") }
    }
    
    @IBAction func btnReloadMapAction(_ sender: UIButton) {
        
        if let del = delegate { del.handleDelegateCommand("reloadUserLocationMapFromMenu") }
    }
    
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        
        if let del = delegate { del.handleDelegateCommand("logOutUserFromMenu") }
    }
    
    @IBAction func btnShowStatisticsAction(_ sender: UIButton) {
        
        print ("show statistics")
    }
}
