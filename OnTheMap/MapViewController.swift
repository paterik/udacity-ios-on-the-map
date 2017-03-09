//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 27.12.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//
import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var annotations = [MKPointAnnotation]()
    
    var parseClient = PRSClient.sharedInstance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLocations()
        activitySpinner.center = self.view.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    private func updateLocations () {
        mapView.removeAnnotations(annotations)
        fetchAllStudentLocations()
    }
    
    private func fetchAllStudentLocations () {

        parseClient.getAllStudentLocations () { (success, error) in
            
            if error == nil {
                
                self.makeMapAnnotationsArray()
                
            } else {
                
                let alertController = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.alert)
                let Action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    // error? do something ...
                }
                
                alertController.addAction(Action)
                OperationQueue.main.addOperation {
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }
    }
    
    private func makeMapAnnotationsArray () {

        let students = PRSStudentLocations.sharedInstance
        for dictionary in students.locations {
            
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude, longitude: dictionary.longitude)
            let annotation = MKPointAnnotation()
            let title = NSString(format: "%@ %@", dictionary.firstName, dictionary.lastName)
        
            annotation.coordinate = coordinate
            annotation.title = title as String
            annotation.subtitle = dictionary.mediaURL
            
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
        }
    }
}
