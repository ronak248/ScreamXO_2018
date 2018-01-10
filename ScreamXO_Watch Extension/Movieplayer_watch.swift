//
//  Movieplayer_watch.swift
//  ScreamXO
//
//  Created by Ronak Barot on 18/05/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit
import Foundation


class Movieplayer_watch: WKInterfaceController {
    
    
    var DictinaryData = NSDictionary()


    @IBOutlet var moviePlayer: WKInterfaceMovie!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        DictinaryData = context as! NSDictionary
        let strimgname:String?=DictinaryData.value(forKey: "media_url") as? String

        moviePlayer.setMovieURL(URL(string: strimgname!)!)
        

        moviePlayer.setPosterImage(WKImage(imageName: "buff_w"))
        
        
        presentMediaPlayerController(
            with: (URL(string: strimgname!)!),
            options: [WKMediaPlayerControllerOptionsAutoplayKey: true]) { (didPlayToEnd, endTime, error) -> Void in
                
                print(error);
                
                //self.playLabel.setText("didPlayToEnd:\(didPlayToEnd), endTime:\(endTime), error:\(error)")
        }
        // Configure interface objects here.
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
