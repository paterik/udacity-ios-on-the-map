//
//  PRSStudentMapAnnotation.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 10.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit

class PRSStudentMapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var url: String?
    var eta: String?
    var distance: String?
    var image: UIImage?
    var evaluated: Date?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}