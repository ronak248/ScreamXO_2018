/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

enum OneDriveManagerResult {
    case success
    case failure(OneDriveAPIError)
}

enum OneDriveAPIError: Error {
    case resourceNotFound
    case jsonParseError
    case unspecifiedError(URLResponse?)
    case generalError(Error?)
}

class OneDriveManager : NSObject {
    
    var baseURL: String = Bundle.main.object(forInfoDictionaryKey: "OneDrive base API URL") as! String
    
    var accessToken: String! {
        get {
            return AuthenticationManager.sharedInstance?.accessToken
        }
    }
    
    // MARK: Definitions
    let kAppFolderPath = "OneAPI"
    
    
    override init() {
        super.init()
    }
    
    
    // MARK: Step 1 - folder creation/retrieval
    func getAppFolderId(_ completion: @escaping (OneDriveManagerResult, _ appFolderId: String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(baseURL)/me/drive/special/approot:/")!)
        
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            if let someError = error {
                completion(OneDriveManagerResult.failure(OneDriveAPIError.generalError(someError)), nil)
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            print("status code = \(statusCode)")
            
            switch(statusCode) {
                
            case 200:
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
                    
                    guard let folderId = (json as! NSDictionary)["id"] as? String else {
                        completion(OneDriveManagerResult.failure(OneDriveAPIError.unspecifiedError(response)), nil)
                        return
                    }
                    completion(OneDriveManagerResult.success, folderId)
                }
                catch{
                    completion(OneDriveManagerResult.failure(OneDriveAPIError.jsonParseError),  nil)
                }
                
            case 404:
                completion(OneDriveManagerResult.failure(OneDriveAPIError.resourceNotFound),  nil)
                
            default:
                completion(OneDriveManagerResult.failure(OneDriveAPIError.unspecifiedError(response)),  nil)
                
            }
        })
        
        task.resume()
    }
    
    
    
    func createTextFile(_ fileName:String, folderId:String, completion: @escaping (OneDriveManagerResult) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(baseURL)/me/drive/special/approot:/\(fileName):/content")!)
        request.httpMethod = "PUT"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")


        request.httpBody = ("This is a test text file" as NSString).data(using: String.Encoding.utf8.rawValue)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            
            if let someError = error {
                completion(OneDriveManagerResult.failure(OneDriveAPIError.generalError(someError)))
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            print("status code = \(statusCode)")
            
            switch(statusCode) {
            case 200, 201:
                completion(OneDriveManagerResult.success)
            default:
                completion(OneDriveManagerResult.failure(OneDriveAPIError.unspecifiedError(response)))
            }
        })
        task.resume()
    }

    
    func createFolder(_ folderName:String, folderId:String, completion: @escaping (OneDriveManagerResult) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(baseURL)/me/drive/special/approot:/\(folderName)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let emptyParams = Dictionary<String, String>()
        let params = ["name":folderName,
                      "folder":emptyParams,
                      "@name.conflictBehavior":"rename"] as [String : Any]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            
            if let someError = error {
                completion(OneDriveManagerResult.failure(OneDriveAPIError.generalError(someError)))
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            switch(statusCode) {
            case 200, 201:
                completion(OneDriveManagerResult.success)
            default:
                completion(OneDriveManagerResult.failure(OneDriveAPIError.unspecifiedError(response)))
            }
        })
        task.resume()
    }

    func syncUsingViewDelta(syncToken:String?,
        completion: @escaping (OneDriveManagerResult, _ newSyncToken: String?, _ deltaArray: [DeltaItem]?) -> Void) {
            syncUsingViewDelta(syncToken: syncToken, nextLink: nil, currentDeltaArray: [DeltaItem](), completion: completion)
    }
    
    func syncUsingViewDelta(syncToken:String?, nextLink: String?, currentDeltaArray: [DeltaItem]?,
        completion: @escaping (OneDriveManagerResult, _ newSyncToken: String?, _ deltaArray: [DeltaItem]?) -> Void) {
        var currentDeltaArray = currentDeltaArray

            let request: NSMutableURLRequest
            
            if let nLink = nextLink {
                request = NSMutableURLRequest(url: URL(string: "\(nLink)")!)
            }
            else {
                if let sToken = syncToken {
                    request = NSMutableURLRequest(url: URL(string: "\(baseURL)/me/drive/root/view.delta?token=\(sToken)")!)
                }
                else {
                    request = NSMutableURLRequest(url: URL(string: "\(baseURL)/me/drive/root/view.delta")!)
                }
            }
            
            print("\(request)")
            
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                
                if let someError = error {
                    print("error \(error?.localizedDescription)")
                    completion(OneDriveManagerResult.failure(OneDriveAPIError.generalError(someError)),nil, nil)
                    return
                }
                
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("status code = \(statusCode)\n\n")
                
                switch(statusCode) {
                case 200:
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
                        
                        guard let deltaToken = (json as! NSDictionary)["@delta.token"] as? String else {
                            completion(OneDriveManagerResult.failure(OneDriveAPIError.unspecifiedError(response)), nil, nil)
                            return
                        }
                        
                        print("delta token = \(deltaToken)")
                        
                        if let items = (json as! NSDictionary)["value"] as? [[String: AnyObject]] {
                            for item in items {
                                let fileId: String = item["id"] as! String
                                let lastModifiedRaw = item["lastModifiedDateTime"] as! String
                                let lastModified = self.localTimeStringFromGMTTime(lastModifiedRaw)
                                
                                let fileName: String? = item["name"] as? String
                                var isFolder: Bool
                                var isDelete: Bool
                                var parentId: String?
                                
                                if let _ = item["folder"] {
                                    isFolder = true
                                }
                                else {
                                    isFolder = false
                                }
                                
                                if let _ = item["deleted"] {
                                    isDelete = true
                                }
                                else {
                                    isDelete = false
                                }
                                
                                if let parentReference = item["parentReference"] as? [String: AnyObject] {
                                    parentId = parentReference["id"] as? String!
                                }
                                
                                let deltaItem = DeltaItem(
                                    fileId: fileId,
                                    fileName: fileName,
                                    parentId: parentId,
                                    isFolder: isFolder,
                                    isDelete: isDelete,
                                    lastModified: lastModified)

                                currentDeltaArray?.append(deltaItem)
                            }
                        }
                        
                        if let nextLink = (json as! NSDictionary)["@odata.nextLink"] as? String {
                            self.syncUsingViewDelta(syncToken: syncToken, nextLink: nextLink, currentDeltaArray: currentDeltaArray, completion: completion)
                        }
                        else {
                            completion(OneDriveManagerResult.success, deltaToken, currentDeltaArray)
                        }
                        
                        
                        
                        
                        
                    }
                    catch{
                        completion(OneDriveManagerResult.failure(OneDriveAPIError.jsonParseError), nil, nil)
                    }
                    
                default:
                    completion(OneDriveManagerResult.failure(OneDriveAPIError.unspecifiedError(response)), nil, nil)
                }
            })
            
            task.resume()
    }
    
    func localTimeStringFromGMTTime(_ gmtTime: String) -> String {
        
        let locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterFrom = DateFormatter()
        dateFormatterFrom.locale = locale
        dateFormatterFrom.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatterFrom.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        let lastModifiedDate = dateFormatterFrom.date(from: gmtTime)
        
        let dateFormatterTo = DateFormatter()
        dateFormatterTo.locale = locale
        dateFormatterTo.timeZone = TimeZone.autoupdatingCurrent
        dateFormatterTo.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        
        return dateFormatterTo.string(from: lastModifiedDate!)
    }
    
}








