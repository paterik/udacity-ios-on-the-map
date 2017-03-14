//
//  ProfileEditViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 13.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController, EditViewProtocol {
    
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    @IBOutlet weak var btnSaveProfile: UIBarButtonItem!
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSaveProfileAction(_ sender: Any) {
    
    }
}
