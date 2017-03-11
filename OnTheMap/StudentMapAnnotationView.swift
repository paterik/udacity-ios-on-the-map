//
//  StudentMapAnnotationView.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 10.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import MapKit

class StudentMapAnnotationView: MKAnnotationView
{
    override func hitTest(
        _ point: CGPoint,
          with event: UIEvent?)
        
        -> UIView? {
        
        let hitView = super.hitTest(point, with: event)
        
        if (hitView != nil) {
            self.superview?.bringSubview(toFront: self)
        }
        
        return hitView
    }
    
    override func point(
        inside point: CGPoint,
        with event: UIEvent?)
        
        -> Bool {
        
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        
        if (!isInside) {
            
            for view in self.subviews  {
                isInside = view.frame.contains(point)
                if isInside { break }
            }
        }
        
        return isInside
    }
}
