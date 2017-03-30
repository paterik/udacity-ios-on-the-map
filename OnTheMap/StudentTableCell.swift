//
//  StudentTableCell.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 29.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class StudentTableCell: UITableViewCell {
    
    @IBOutlet weak var lblStudentDistance: UILabel!
    @IBOutlet weak var lblStudentName: UILabel!
    @IBOutlet weak var lblStudentMapString: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
