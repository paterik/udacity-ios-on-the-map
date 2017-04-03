//
//  StudentListMenu.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 02.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class StudentListMenu: UIView {

    //
    // MARK: IBOutlet Variables
    //
    
    @IBOutlet weak var btnShowAllLocations: UIButton!
    @IBOutlet weak var btnShowOwnLocations: UIButton!
    @IBOutlet weak var btnLogOut: UIButton!
    
    //
    // MARK: Variables
    //
    
    var delegate: ControllerCommandProtocol?
    
    //
    // MARK: IBAction Methods
    //
    
    @IBAction func btnShowAllLocationsAction(_ sender: UIButton) {
        
        if let del = delegate { del.handleDelegateCommand("loadAllLocationsFromMenu") }
    }
    
    @IBAction func btnShowOwnLocationsAction(_ sender: UIButton) {
        
        if let del = delegate { del.handleDelegateCommand("loadOwnLocationsFromMenu") }
    }
    
    @IBAction func btnLogOutAction(_ sender: UIButton) {
        
        if let del = delegate { del.handleDelegateCommand("logOutUserFromMenu") }
    }
    
}
