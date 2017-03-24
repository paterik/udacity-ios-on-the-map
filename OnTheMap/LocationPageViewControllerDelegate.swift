//
//  LocationPageViewControllerDelegate.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

protocol LocationPageViewControllerDelegate: class {
    
    /**
     * executed when the number of pages is updated
     */
    func locationPageViewController(
       _ locationPageViewController: LocationPageViewController,
         didUpdatePageCount count: Int)
    
    /**
     * executed when the current index is updated
     */
    func locationPageViewController(
       _ locationPageViewController: LocationPageViewController,
         didUpdatePageIndex index: Int)
}
