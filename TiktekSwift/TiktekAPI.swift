//
//  TiktekAPI.swift
//  TiktekSwift
//
//  Created by svc64 on 01/04/2021.
//

import UIKit
// this is torture
// anyways, here's the tiktek API in swift
class TiktekAPI {
    let PARAM_CLIENT_ID = "TT-Client_ID"
    let host = "https://tiktek.com"
    let clientIDRequest = "/il/services/Clients.asmx/GetClientID2"
    let modelCode = "iPhone12,1"
    let systemVersionString = "14.4.0"
    
    var clientID = "iOS_NoClientID"
    var userAgent: String // a legit looking user agent
    var deviceInfo: String // cuz we need this
    init() {
        /* The tiktek app fetches a unique device ID on first launch, then it sends that device ID in all requests.
            This can be abused to track users (and probably used for this) so we'll fetch a new device ID every launch to look legit and prevent tracking.
         */
        deviceInfo = "\(modelCode) - ios \(systemVersionString)"
        userAgent = "Tiktek for iOS v200 on \(deviceInfo)"
        let idRequest: [String: String] = ["deviceInfo" : deviceInfo]
        let idResponse = jsonPost(url: host+clientIDRequest, jsonBody: idRequest)
        clientID = idResponse!["ResultData"] as! String
        print("Got client ID! \(clientID)")
    }
    // [String: [String: Any]?]?
    private func jsonPost(url: String, jsonBody: [String: Any]) -> [String: Any]? {
        var retval: [String: Any]? = nil
        while retval == nil {
            let semaphore = DispatchSemaphore(value: 0)
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            request.setValue(clientID, forHTTPHeaderField: "TT-Client_ID")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            // insert json data to the request
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "request failed... trying again!")
                    sleep(2)
                    semaphore.signal()
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: [String: Any]?]? {
                    semaphore.signal()
                    retval = responseJSON!["d"]!
                    return
                }
            }
            task.resume()
            semaphore.wait()
        }
        return retval
    }
}
