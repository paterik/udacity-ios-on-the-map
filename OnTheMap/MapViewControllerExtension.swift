//
//  MapViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 09.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit
import MapKit
import Foundation

extension MapViewController: MKMapViewDelegate {
    
    func mapView(
        _ mapView: MKMapView,
          viewFor annotation: MKAnnotation)
        
        -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
        if pinView == nil {
                
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
        } else {
                
            pinView!.annotation = annotation
                
        }
            
        return pinView
    }
    
    
    func mapView(
        _ mapView: MKMapView,
          annotationView view: MKAnnotationView,
          calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            
            if var mediaURL = (view.annotation?.subtitle!)! as String? {
                
                if (mediaURL.hasPrefix("www")) {
                    mediaURL = "https://" + mediaURL
                }
                
                let nsURL = URL(string: mediaURL)!
                let isOpenable = app.canOpenURL(nsURL)
            }
        }
    }
}
