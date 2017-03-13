//
//  StudentMapAnnotation.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 10.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

class StudentMapAnnotation: UIView {
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var studentMediaURL: UIButton!
    @IBOutlet weak var studentDistance: UILabel!
    @IBOutlet weak var studentGraphDistanceBackground: UILabel!
    @IBOutlet weak var studentGraphDistanceValue: UILabel!
    
    
    @IBAction func btnOpenStudentMediaURL(_ sender: Any) {
        
    }
}
