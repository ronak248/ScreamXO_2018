//
//  ItemDetailsWatch.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit

class ItemDetailsWatch: WKInterfaceController {
    
    @IBOutlet var itmDescription: WKInterfaceLabel!
    @IBOutlet var itmPrice: WKInterfaceLabel!
    @IBOutlet var lblitmname: WKInterfaceLabel!
    
    @IBOutlet var btnimage: WKInterfaceButton!
    @IBOutlet var imgItmimage: WKInterfaceImage!
    var DictinaryData = NSDictionary()
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        
        DictinaryData = context as! NSDictionary
        
        
        lblitmname.setText(DictinaryData.value(forKey: "item_name") as? String)
        itmDescription.setText(DictinaryData.value(forKey: "item_description") as? String)
        
        if let price = DictinaryData.value(forKey: "item_price")
        {
        itmPrice.setText("$" + (price as! String))
        }

        let strimgname:String?=(DictinaryData.value(forKey: "media_url") as? String)
        
        btnimage.setbackgroundImageWithUrl(strimgname!)

        
        // Configure interface objects here.
    }
    
    @IBAction func btnFullimageClicked() {
        
        pushController(withName: "ImageVIewer", context: (DictinaryData.value(forKey: "media_url") as? String))

    }
    override func willActivate() {
        
        
        
        
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
}
