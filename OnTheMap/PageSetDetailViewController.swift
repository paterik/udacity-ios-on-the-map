//
//  PageSetDetailViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class PageSetDetailViewController: PageSetViewController {

    @IBOutlet weak var btnCloseView: UIBarButtonItem!
    
    @IBAction func btnCloseViewAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
