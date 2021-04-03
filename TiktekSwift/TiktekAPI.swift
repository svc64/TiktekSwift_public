//
//  TiktekAPI.swift
//  TiktekSwift
//
//  Created by svc64 on 01/04/2021.
//

import UIKit
// this is torture
// anyways, here's the tiktek API in swift
struct Book {
    let image: UIImage
    let name: String
    let info: String
    let ID: String
    let imagesDirectory: String // the directory in tiktek's servers where the solution images are saved for this book
}
struct Answer {
    let imageName: String
    let page: String
    let question: String
    let creator: String // username of whoever uploaded this
    let correctness: String
}
class TiktekAPI {
    let PARAM_CLIENT_ID = "TT-Client_ID"
    let host = "https://tiktek.com"
    let clientIDRequest = "/il/services/Clients.asmx/GetClientID2"
    let bookListRequest = "/il/services/MobileSearch.asmx/GetMobileBooks2"
    let answersListRequest = "/il/services/MobileSearch.asmx/GetSolsEssaysAndMedia"
    let modelCode = "iPhone12,1"
    let systemVersionString = "14.4.0"
    let NO_CLIENT_ID = "iOS_NoClientID"
    var clientID: String
    var userAgent: String // a legit looking user agent
    var deviceInfo: String // cuz we need this
    let deviceIDSemaphore = DispatchSemaphore(value: 0)
    var requestingDeviceID = false
    init() {
        deviceInfo = "\(modelCode) - ios \(systemVersionString)"
        userAgent = "Tiktek for iOS v200 on \(deviceInfo)"
        clientID = NO_CLIENT_ID
    }
    func getBooks(subjectID: String) -> [Book]? {
        var books: [Book] = []
        let booksRequest: [String: String] = ["subjectID" : subjectID]
        let booksResponse = jsonPost(url: host+bookListRequest, jsonBody: booksRequest)
        if let resultData = booksResponse!["ResultData"] as? [String: Any]? {
            if let booksArray = resultData!["Books"] as! [[String: Any]]? {
                // every single tiktek employee who took part in designing this mess deserves to get shot
                // for legal reasons the above text is just a joke
                for book in booksArray {
                    let image = UIImage(data: Data(base64Encoded: book["Icon"] as! String)!)!
                    let name = book["Title"] as! String
                    let info = (book["Title1"] as! String) + "\n" + (book["Title2"] as! String) + "\n" + (book["Title3"] as! String)
                    let parsedBook = Book(image: image, name: name, info: info, ID: book["ID"] as! String, imagesDirectory: book["Subdir"] as! String)
                    books.append(parsedBook)
                }
                return books
            }
        }
        return nil
    }
    func getAnswers(bookID: String, page: String, question: String) -> [Answer] {
        var answers: [Answer] = []
        let answersRequest: [String: String] = [
            "bookID" : bookID,
            "page" : page,
            "question" : question,
            "sq" : "",
            "ssq" : "",
            "userID" : ""
        ]
        let answersResponse = jsonPost(url: host+answersListRequest, jsonBody: answersRequest)
        if let resultData = answersResponse!["ResultData"] as? [String: Any]? {
            if let answersArray = resultData!["Solutions"] as! [[String: Any]]? {
                for answer in answersArray {
                    let parsedAnswer = Answer(imageName: answer["Image"] as! String, page: String(answer["Page"] as! Int), question: String(answer["Question"] as! Int), creator: answer["UserName"] as! String, correctness: String(answer["Correct"] as! Int))
                    answers.append(parsedAnswer)
                }
            }
        }
        return answers
    }
    // The function that downloads images doesn't use a custom UA or sends anything tiktek related in the request...
    public func downloadImage(imageName: String, bookDir: String, bookID: String) -> UIImage {
        var result: UIImage? = nil
        let url = URL(string: host+"/il/tt-resources/solution-images/"+bookDir+"_"+bookID+"/"+imageName)
        while result == nil {
            let semaphore = DispatchSemaphore(value: 0)
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "request failed... trying again!")
                    sleep(2)
                    semaphore.signal()
                    return
                }
                result = UIImage(data: data)
                semaphore.signal()
            }
            task.resume()
            semaphore.wait()
        }
        return result!
    }
    // [String: [String: Any]?]?
    private func jsonPost(url: String, jsonBody: [String: Any]) -> [String: Any]? {
        // hold til we have a client ID
        let deviceIDRequestURL = host+clientIDRequest
        if url != deviceIDRequestURL {
            if requestingDeviceID {
                deviceIDSemaphore.wait()
            }
            if clientID == NO_CLIENT_ID && url != deviceIDRequestURL {
                /* The tiktek app fetches a unique device ID on first launch, then it sends that device ID in all requests.
                    This can be abused to track users (and probably used for this) so we'll fetch a new device ID every launch to look legit and prevent tracking.
                 */
                self.requestingDeviceID = true
                let idRequest: [String: String] = ["deviceInfo" : deviceInfo]
                let idResponse = jsonPost(url: deviceIDRequestURL, jsonBody: idRequest)
                clientID = idResponse!["ResultData"] as! String
                print("Got client ID! \(clientID)")
                requestingDeviceID = false
                deviceIDSemaphore.signal()
            }
        }
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
                    if responseJSON == nil {
                        // rip
                        return
                    }
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
