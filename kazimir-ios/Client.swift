//
//  Client.swift
//  kazimir-ios
//
//  Created by Krzysiek on 10/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

class Client {
    
    static let sharedInstance = Client()
    
    let url = NSURL(string: "http://kazimirapp.pl/streets.json")!
    
    func downloadData() -> [Dictionary<String, AnyObject>] {
        let request = NSURLRequest(URL: url)
        var response: NSURLResponse? = nil
        var error: NSError? = nil
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)!
        
        let jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error) as! [Dictionary<String, AnyObject>]
        return jsonObject
    }
    
}
