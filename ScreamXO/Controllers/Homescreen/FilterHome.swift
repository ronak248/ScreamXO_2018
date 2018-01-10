//
//  FilterHome.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 05/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class streamCategoryCell: UITableViewCell {
    
    @IBOutlet var lblCategoryName: UILabel!
    @IBOutlet var btnSelCategoryName: UIButton!
}

protocol Homescreenfilter  {
    func actionFIlterData(_ filterType: String)
    
}

class FilterHome: UITableViewController {
    
    var selectedrow :NSInteger!
    var mediaType = ""
    var privacyType = ""
    let mgrItm = ItemManager.itemManager
    var delegate : Homescreenfilter!
    let mgrPost = PostManager.postManager
    var isTable = String()

    var arrayLabels: NSArray = [
        ["name": "All", "id": ""]
        ,["name": "Video", "id": "1"]
        ,["name": "Audio", "id": "3"]
        ,["name": "Music", "id": "4"]
        ,["name": "Image", "id": "2"]
        ,["name": "Trending", "id": "5"]
    ]
    
    var arrayCategories = [
        ["name": "Public", "id": "2"]
        ,["name": "Friends", "id": "1"],
         ["name": "Private", "id": "0"],
        ["name": "Trending", "id": "3"]
    ]
    
    var arrayWalletCategories = [
        ["name": "Send Money", "id": "1"],
         ["name": "Contact Support", "id": "0"]
    ]
    
    var arrayQueryCategories : NSArray = [
        ["name": "General Enquiry", "id": "6"],
        ["name": "Dispute Transaction", "id": "5"],
        ["name": "How to send Money", "id": "4"],
        ["name": "How to request money", "id": "3"],
        ["name": "Invoices & Reporting", "id": "2"],
        ["name": "How to withdraw Xocash", "id": "1"],
        ["name": "Technical & Bugs", "id": "0"]
        
    ]
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 240/255, green: 239/255, blue: 245/255, alpha: 1.0)

        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isTable == "media" {
            return arrayLabels.count
        } else if  isTable == "wallet" {
             return arrayWalletCategories.count
        } else if isTable == "query" {
            return arrayQueryCategories.count
        }else {
            return arrayCategories.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isTable == "media" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropCell", for: indexPath)
            
            if (mediaType == ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "id") as? String)) {
                
                cell.contentView.backgroundColor = UIColor.lightGray
            }
            
            let lblName : UILabel = cell.contentView.viewWithTag(101) as! UILabel
            let strname:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            lblName.text = strname
            
            return cell
        } else if isTable == "wallet"  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropCell", for: indexPath)
            
            if (mediaType == ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "id") as? String)) {
                
                cell.contentView.backgroundColor = UIColor.lightGray
            }
            
            let lblName : UILabel = cell.contentView.viewWithTag(101) as! UILabel
            let strname:String = ((arrayWalletCategories[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            lblName.text = strname
            
            return cell
        } else if isTable == "query"  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropCell", for: indexPath)
            if (mediaType == ((arrayQueryCategories[indexPath.row] as AnyObject).value(forKey: "id") as? String)) {
                cell.contentView.backgroundColor = UIColor.lightGray
            }
            let lblName : UILabel = cell.contentView.viewWithTag(101) as! UILabel
            let strname:String = ((arrayQueryCategories[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            lblName.text = strname
            return cell
        }
        
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "streamCategoryCell", for: indexPath) as! streamCategoryCell
            
            if (privacyType == (arrayCategories[indexPath.row]["id"])) {
                
                cell.btnSelCategoryName.setImage(UIImage(named: "checked"), for: UIControlState())
            }
            cell.lblCategoryName.text = arrayCategories[indexPath.row]["name"]
            
            return cell
        }
    }
 
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isTable == "media" {
            
            if self.delegate != nil {
                 print((arrayLabels.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String)
                mgrPost.mediaType = (arrayLabels.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String
                self.delegate.actionFIlterData("media")
            }
        } else if isTable == "wallet" {
            
            if indexPath.row == 0 {
                if self.delegate != nil {
                    mgrPost.mediaType = (arrayLabels.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String
                    self.delegate.actionFIlterData("wallet")
                }
            } else {
                mgrPost.mediaType = (arrayLabels.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String
                self.delegate.actionFIlterData("walletsupport")
            }
            
        } else if isTable == "query" {
            if self.delegate != nil {
                mgrPost.mediaType = (arrayLabels.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String
                let queryQuestion = (arrayQueryCategories.object(at: indexPath.row) as AnyObject).value(forKey: "name") as! String
                self.delegate.actionFIlterData(queryQuestion)
            }
        }else {
            if self.delegate != nil {
                print(arrayCategories[indexPath.row]["id"]!)
                mgrPost.privacyType = arrayCategories[indexPath.row]["id"]!
                self.delegate.actionFIlterData("stream")
            }
        }
    }
}
