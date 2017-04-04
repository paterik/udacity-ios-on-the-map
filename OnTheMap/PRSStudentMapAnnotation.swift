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
    
    //
    // MARK: Variables
    //
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var url: String?
    var distance: String?
    var image: UIImage?
    var determined: Date?
    var ownLocation: Bool! = false
    var objectId: String?
    var flag: String?
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
