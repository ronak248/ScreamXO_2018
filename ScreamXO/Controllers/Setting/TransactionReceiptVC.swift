//
//  TransactionReceiptVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-11.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class TransactionReceiptVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var receipReport: UIWebView!
    var myHTMLString: String!
    var walletId: String!
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
    }

    override func viewWillAppear(_ animated: Bool) {
        let strURL = "https://api.screamxo.com/mobileservice/Walletorderpayment/generateReceipt/" + "\(userId!)/" + "\(walletId!)"
        print(strURL)
        let url = URL(string: strURL)
        if let unwrappedURL = url {
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    self.receipReport.loadRequest(request)
                } else {
                    mainInstance.showSomethingWentWrong()
                    print("ERROR: \(error)")
                }
            }
            
            task.resume()
            
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  }
