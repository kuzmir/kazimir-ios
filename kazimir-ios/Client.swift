//
//  Client.swift
//  kazimir-ios
//
//  Created by Krzysiek on 10/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

class Client {
    
    static let sharedInstance = Client()
    
    let standardError = NSError(domain: "kazimir", code: 1, userInfo: nil)
    let url = NSURL(string: "http://kazimirapp.pl/streets.json")!
    
    func downloadData() -> ([Dictionary<String, AnyObject>]?, NSError?) {
        let request = NSURLRequest(URL: url)
        var response: NSURLResponse? = nil
        var error: NSError? = nil
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        if error != nil { return (nil, error) }
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 { return (nil, error) }
        }
        
        let json = NSJSONSerialization.JSONObjectWithData(data!, options: .allZeros, error: &error) as? [Dictionary<String, AnyObject>]
        if json == nil { return (nil, standardError) }
        return (json, nil)
    }
    
}
