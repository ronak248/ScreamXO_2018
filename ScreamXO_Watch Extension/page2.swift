//
//  page2.swift
//  WatchKitDemo
//
//  Created by Jatin Kathrotiya on 21/06/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import WatchKit
import Foundation


class page2: WKInterfaceController {
   @IBOutlet var mainGroup : WKInterfaceGroup!
    var dataDic : NSDictionary?
    @IBOutlet var imgView:WKInterfaceImage!
    
    @IBOutlet var groupthumb: WKInterfaceGroup!
    @IBOutlet var moviePlayer: WKInterfaceMovie!
    
   // @IBOutlet var mediaGroup : WKInterfaceGroup!
     @IBOutlet var btnImage : WKInterfaceButton!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        dataDic = context as? NSDictionary
       // mainGroup.setBackgroundColor(UIColor(red:CGFloat(arc4random()%255)/255.0, green:CGFloat(arc4random()%255)/255.0, blue:CGFloat(arc4random()%255)/255.0,alpha:1.0))
        self.setupView()
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
    func setupView()  {
        
        
        let strmediaType:String?=dataDic!.value(forKey: "media_type")! as? String
        
        
        if strmediaType == "audio/m4a" || strmediaType == "audio/mp3"
        {
            let strimgname:String?=dataDic!.value(forKey: "media_url") as? String
            
            //moviePlayer.setMovieURL(NSURL(string: "https://admin.thebeermeapp.com/Media/BarImages/4W38VhsWx6qBH3jpCmVEBKXXH.mov")!)
           
           // moviePlayer.setPosterImage(WKImage(imageName: "audio_w"))
            //self.mediaGroup.setHidden(false)
             self.btnImage.setHidden(true)
            
          
                        //self.groupthumb.setBackgroundImageNamed("audio_w")
            
            
            let url:String=dataDic!.value(forKey: "media_thumb")! as! String
            
            let strimg:String=dataDic!.value(forKey: "media_thumb")! as! String

            URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
                if (data != nil && error == nil) {
                    let image = UIImage(data: data!, scale: 1.0)
                    
                    DispatchQueue.main.async {
                        
                        self.imgView.setImageWithUrl(strimg)
                        //self.mediaGroup.setHidden(true)
                        self.btnImage.setHidden(false)
                        //self.moviePlayer.setPosterImage(WKImage(image: image!))
                    }
                }
                }) .resume()
            
                      //  self.imgView.setImageNamed("cat2")
                        //self.mediaGroup.setHidden(true)
                        self.btnImage.setHidden(false)
                        //self.moviePlayer.setPosterImage(WKImage(image: image!))
            
        }
        else if(strmediaType == "video/quicktime"){
            let strimgname:String?=dataDic!.value(forKey: "media_url") as? String
            
         //   moviePlayer.setMovieURL(NSURL(string: "https://admin.thebeermeapp.com/Media/BarImages/4W38VhsWx6qBH3jpCmVEBKXXH.mov")!)
            let strimg:String=dataDic!.value(forKey: "media_thumb")! as! String

            let url:String=dataDic!.value(forKey: "media_thumb")! as! String
            
            
            URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
                if (data != nil && error == nil) {
                    let image = UIImage(data: data!, scale: 1.0)
                    
                    DispatchQueue.main.async {
                        
                        self.imgView.setImageWithUrl(strimg)
                        //self.mediaGroup.setHidden(true)
                        self.btnImage.setHidden(false)
                        //self.moviePlayer.setPosterImage(WKImage(image: image!))
                    }
                 }
            }) .resume()
            
            //moviePlayer.setPosterImage(WKImage(imageName: "buff_w"))
           // self.mediaGroup.setHidden(false)
             self.btnImage.setHidden(false)
        }
        else
        {
           
            let strimg:String=dataDic!.value(forKey: "media_thumb")! as! String
            
           self.imgView.setImageWithUrl(strimg)
            //self.mediaGroup.setHidden(true)
             self.btnImage.setHidden(false)
            
            
            
            
        }
        
    }
    @IBAction func btnMediaClicked(_ sender:AnyObject?){
        let strmediaType:String?=dataDic!.value(forKey: "media_type")! as? String
        
        
        if strmediaType == "audio/m4a" || strmediaType == "audio/mp3" || strmediaType == "video/quicktime" || strmediaType == "video/mp4"
        {
            
            
            let strimgname:String?=dataDic!.value(forKey: "media_url") as? String
            
           
           // var Dicdata:NSDictionary!
            
            //Dicdata = ["media_url":"https://admin.thebeermeapp.com/Media/BarImages/4W38VhsWx6qBH3jpCmVEBKXXH.mov"]
            
           // pushControllerWithName("Movieplayer_watch", context: Dicdata)
            
            presentMediaPlayerController(
                with: (URL(string: strimgname!)!),
                options: [WKMediaPlayerControllerOptionsAutoplayKey: true]) { (didPlayToEnd, endTime, error) -> Void in
                    
                    print(error);
                    
                    //self.playLabel.setText("didPlayToEnd:\(didPlayToEnd), endTime:\(endTime), error:\(error)")
            }
            
            
        }
        else
        {
            
            self.presentController(withName: "ImageVIewer", context: dataDic!.value(forKey: "media_url"))
            
        }
    }
    
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if(segueIdentifier == "playmovie")
        {
            
            
            return dataDic!
            
        }
        
        return nil
        
    }

}
