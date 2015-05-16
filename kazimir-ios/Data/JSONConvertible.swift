//
//  JSONConvertible.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

import UIKit

typealias JSON = [String: AnyObject]
typealias ConversionResult = (updated: Bool?, error: NSError?)
typealias RelationInfo = (jsons: [JSON]?, error: NSError?)

protocol JSONConvertible {
    
    static func getIdFromJSON(json: JSON) -> NSNumber?
    func fromJSON(json: JSON) -> ConversionResult
   
}
