//
//  LocationPageViewControllerExtension.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 24.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import UIKit

extension LocationPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //
    // MARK: UIPageViewControllerDelegate
    //
    
    func pageViewController(
       _ pageViewController: UIPageViewController,
         didFinishAnimating finished: Bool,
         previousViewControllers: [UIViewController],
         transitionCompleted completed: Bool) {
        
         notifyLocationDelegateOfNewIndex()
    }
    
    //
    // MARK: UIPageViewControllerDataSource
    //
    
    func pageViewController(
       _ pageViewController: UIPageViewController,
         viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(
       _ pageViewController: UIPageViewController,
         viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
