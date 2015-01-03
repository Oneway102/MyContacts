//
//  LogHelper.swift
//  MyContacts
//
//  Created by Wei  Wang on 15/1/3.
//  Copyright (c) 2015年 Wei  Wang. All rights reserved.
//

import Foundation

class LogHelper {
    var logEnabled = true
    
    init() {
        
    }

    func log(tag:String, _ content:String) -> Void {
        println("[\(tag)] \(content)")
    }
}