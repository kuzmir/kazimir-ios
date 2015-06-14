//
//  TimeContext.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 14/06/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

enum TimeContext: Int {
    case Old
    case New
}

extension TimeContext {
    
    static func getTimeContextForPlace(place: Place) -> TimeContext {
        return place.present.boolValue ? TimeContext.New : TimeContext.Old
    }
    
    static func getTimeContextFromSegueIdentifier(segueIdentifier: String) -> TimeContext? {
        switch segueIdentifier {
        case TimeContext.Old.getSegueIdentifier():
            return .Old
        case TimeContext.New.getSegueIdentifier():
            return .New
        default:
            return nil
        }
    }
    
    func getSegueIdentifier() -> String {
        return self == .Old ? "pushStreetViewControllerOld" : "pushStreetViewControllerNew"
    }
    
    func getImageName() -> String {
        return self == .Old ? "button_flip_new" : "button_flip_old"
    }
    
    func getOppositeTimeContext() -> TimeContext {
        return self == .Old ? .New : .Old
    }
    
}
