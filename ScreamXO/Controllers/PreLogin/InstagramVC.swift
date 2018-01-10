//
//  InstagramVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 03/06/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AFNetworking

class InstagramVC: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var wbView: UIWebView!
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResult)  -> Void
    var isFromLogin:Bool?
    var _currentBlock:ServiceComplitionBlock!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func authenticateUser()  {
        wbView.stopLoading()
        let fullURL: String = "\(APIManager.APIConstants.KAUTHURL)?client_id=\(APIManager.APIConstants.KCLIENTID)&redirect_uri=http://\(APIManager.APIConstants.kREDIRECTURI)&response_type=token&scope=follower_list"
        
        
        let url: URL = URL(string: fullURL)!
        let requestObj: URLRequest = URLRequest(url: url)
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
        wbView.loadRequest(requestObj)
        wbView.delegate = self
    }
    
    
    
    func getuserDetail(_ block:@escaping ServiceComplitionBlock){
        _currentBlock = block
        if let token = UserDefaults.standard.object(forKey: APIManager.APIConstants.kACCESSTOKEN) as? String {
            
         let fullURL: String = "\(APIManager.APIConstants.kAPIURl)\(APIManager.APIConstants.kUSER)?access_token=" + token
          
            let manager  =  AFHTTPSessionManager()
            
            manager.responseSerializer.acceptableContentTypes=NSSet(array: ["application/json"]) as? Set<String>
            
            
            manager.get(fullURL, parameters: nil, progress: nil, success: { operation, responseObject in
                let responseDict = responseObject as! Dictionary<String, AnyObject>
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil);
                })
                print(responseDict)
                self._currentBlock(responseDict as NSDictionary,APIResult.apiSuccess)
                } , failure: {
                    operation, error in
                    let errorDict = ["error": error]
                    print(errorDict)
                   self._currentBlock(errorDict as NSDictionary,APIResult.apiError)
                  
                
                   
            })

        }else{
            isFromLogin = true
            self.authenticateUser()
        }
      
    }
    
    func getUserFollows(_ block:@escaping ServiceComplitionBlock) {
         _currentBlock = block
        if let token = UserDefaults.standard.object(forKey: APIManager.APIConstants.kACCESSTOKEN) as? String {
            let fullURL: String = "\(APIManager.APIConstants.kAPIURl)\(APIManager.APIConstants.kUSER)followed-by?access_token=" + token + "&count=100"
            
            let manager  =  AFHTTPSessionManager()
            
            manager.responseSerializer.acceptableContentTypes=NSSet(array: ["application/json"]) as? Set<String>
            
            SVProgressHUD.show()
            manager.get(fullURL, parameters: nil, progress: nil, success: { operation, responseObject in
                SVProgressHUD.dismiss()
                let responseDict = responseObject as! Dictionary<String, AnyObject>
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil);
                })
                print(responseDict)
               self._currentBlock(responseDict as NSDictionary,APIResult.apiSuccess)
                }, failure: {
                    operation, error in
                    let errorDict = ["error": error]
                    print(errorDict)
                    self._currentBlock(errorDict as NSDictionary,APIResult.apiError)
                    
            })
            
            
        }else{
            isFromLogin = false
            self.authenticateUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        if (self.presentingViewController != nil) {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var urlString: String = request.url!.absoluteString
        NSLog("URL STRING : %@ ", urlString)
//        var UrlParts: [AnyObject] = urlString.componentsSeparatedByString("\(APIManager.APIConstants.kREDIRECTURI)")
//        if UrlParts.count > 1 {
//            urlString = UrlParts[1] as! String
          //Range? = urlString.rangeOfString("#access_token=") as Range!
            if NSString(string: urlString).contains("#access_token=") {
//                let strAccessToken: String = urlString.substringWithRange(accessToken!)
                // Add contant key #define KACCESS_TOKEN @”access_token” in contant //class [[NSUserDefaults standardUserDefaults] setValue:strAccessToken forKey: KACCESS_TOKEN]; [[NSUserDefaults standardUserDefaults] synchronize];
                
                var urlParts = urlString.components(separatedBy: "#access_token=")
                
                let accessToken = urlParts.last
                let token = accessToken //urlString.stringByReplacingOccurrencesOfString(strAccessToken, withString: "")
                print("AccessToken = " + token!)
                UserDefaults.standard.set(token,forKey: APIManager.APIConstants.kACCESSTOKEN)
                UserDefaults.standard.synchronize()
                if isFromLogin == true {
                     self.getuserDetail(_currentBlock)
                }else{
                    self.getUserFollows(_currentBlock)
                }
               
                 return false
            }
            return true;
//        }
        return true;
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        print(error)
    }
    func webViewDidFinishLoad(_ webView: UIWebView){
        
    }
}
