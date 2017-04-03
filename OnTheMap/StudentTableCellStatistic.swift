//
//  StudentTableCellStatistic.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 03.04.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class StudentTableCellStatistic: UITableViewCell {
 
    @IBOutlet weak var lblMetaLargestDistance: UILabel!
    @IBOutlet weak var lblMetaNumberOfCountries: UILabel!
    @IBOutlet weak var lblMetaLocationsOwned: UILabel!
    @IBOutlet weak var lblMetaLocationsCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
