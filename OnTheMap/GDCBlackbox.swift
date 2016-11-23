//
//  GDCBlackbox.swift
//  OnTheMap
//
//  Created by Patrick Paechnatz on 22.11.16.
//  Copyright © 2016 Patrick Paechnatz. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping () -> Void) {
    
    DispatchQueue.main.async {
        updates()
    }
}