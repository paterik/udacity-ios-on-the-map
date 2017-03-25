//
//  PageSetDetailViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class PageSetDetailViewController: PageSetViewController {

    //
    // MARK: IBOutlet Variables
    //
    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    
    //
    // MARK: IBAction Methods
    //
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
