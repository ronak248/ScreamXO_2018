//
//  ImageVIewer.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 18/05/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit
import Foundation


class ImageVIewer: WKInterfaceController {

    var strImage :String?

    @IBOutlet var imgfullscreen: WKInterfaceImage!
    override func awake(withContext context: Any?) {
        strImage = context as? String
        
        _ = imgfullscreen.setImageWithUrl(strImage!)!
        super.awake(withContext: context)
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
