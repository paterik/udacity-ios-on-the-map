//
//  ControllerCommandProtocol.swift
//  OnTheMap
//
//  This protocol will be used for all inter-class communication handlers
//
//  Created by Patrick Paechnatz on 25.03.17.
//  Copyright © 2017 Patrick Paechnatz. All rights reserved.
//

import Foundation

protocol ControllerCommandProtocol {
    
    func handleDelegateCommand(_ command: String)
}
