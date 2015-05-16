//
//  Client.swift
//  kazimir-ios
//
//  Created by Krzysztof Cieplucha on 10/05/15.
//  Copyright (c) 2015 Kazimir. All rights reserved.
//

class Client {
    
    static let sharedInstance = Client()
    
    let clientError = NSError(domain: "kazimir", code: 1, userInfo: nil)
    let apiUrl = NSURL(string: "http://kazimirapp.pl/streets.json")!
    let resourcesBundleURL = NSBundle.mainBundle().URLForResource("Resources", withExtension: "bundle")!
    
    private init() {}
    
    func getData(#locally: Bool) -> ([JSON]?, NSError?) {
        return locally ? self.loadLocalData() : self.downloadData()
    }
    
    func getImageData(#urlString: String) -> (NSData?, NSError?) {
        var url = NSURL(string: urlString, relativeToURL: resourcesBundleURL)
        if url != nil && url!.fileURL {
            let data = NSData(contentsOfURL: url!)
            if data != nil { return (data, nil) }
        }
        else {
            url = NSURL(string: urlString)
            if url == nil { return (nil, clientError) }
            let data = NSData(contentsOfURL: url!)
            if data != nil { return (data, nil) }
        }
        return (nil, clientError)
    }
    
    private func downloadData() -> ([JSON]?, NSError?) {
        let request = NSURLRequest(URL: apiUrl)
        var response: NSURLResponse? = nil
        var error: NSError? = nil
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        if error != nil { return (nil, error) }
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode != 200 { return (nil, error) }
        }
        
        let json = NSJSONSerialization.JSONObjectWithData(data!, options: .allZeros, error: &error) as? [JSON]
        if json == nil { return (nil, clientError) }
        return (json, nil)
    }
    
    private func loadLocalData() -> ([JSON]?, NSError?) {
        let resourcesBundle = NSBundle(URL: resourcesBundleURL)!
        let resourcesJSONPath = resourcesBundle.pathForResource("resources", ofType: "json")!
        let resourcesJSONData = NSData(contentsOfFile: resourcesJSONPath)
        let json = NSJSONSerialization.JSONObjectWithData(resourcesJSONData!, options: .allZeros, error: nil) as! [JSON]
        return (json, nil)
    }
    
}
