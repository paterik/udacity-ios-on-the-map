//
//  LocationEditViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

extension LocationEditViewController: LocationPageViewControllerDelegate {
    
    func locationPageViewController(
       _ locationPageViewController: LocationPageViewController,
         didUpdatePageCount count: Int) {
        
        pageControl.numberOfPages = count
    }
    
    func locationPageViewController(
       _ locationPageViewController: LocationPageViewController,
         didUpdatePageIndex index: Int) {
        
        pageControl.currentPage = index
    }
}
