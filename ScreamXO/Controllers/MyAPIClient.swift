//
//  MyAPIClient.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 02/06/17.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import Foundation
import Stripe

class MyAPIClient: NSObject, STPBackendAPIAdapter {
    static let sharedClient = MyAPIClient()

    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        
    }
    
    func attachSource(toCustomer source: STPSourceProtocol, completion: @escaping STPErrorBlock) {
        
    }
    
    func selectDefaultCustomerSource(_ source: STPSourceProtocol, completion: @escaping STPErrorBlock) {
        
    }
}
