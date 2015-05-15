//
//  JSONConvertible.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

typealias JSON = [String: AnyObject]
typealias Relations = [String: [JSON]]

protocol JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber?
    static func getUpdateDateFromJSON(json: JSON) -> NSDate?
    func fromJSON(json: JSON) -> (Relations?, NSError?)
   
}
