//
//  MoreInfoVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
class otherinfoCell: UITableViewCell
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
}

class MoreInfoVC: UITableViewController {
    
    enum UserInfo : NSInteger
    {
        case school = 0,job,location,hobby,sex,relation,sexP
    }
    
    var selectedrow :NSInteger!
    var arrayLabels: NSArray = [
        ["name": "School or Alma Matter", "value": "Martin Office"]
        ,["name": "Job", "value": "Software Engineer"]
        ,["name": "City or Zip Code", "value": "New York"]
        ,["name": "Hobby", "value": "Football"]
        ,["name": "Gender", "value": "Male"],
         ["name": "Relationship status", "value": "Martin Office"]
        ,["name": "Sex preference", "value": "Martin Office"]
    ]

    override func viewDidLoad() {
        
        self.tableView.reloadData()

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayLabels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CELL_ID = "otherinfoCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! otherinfoCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        
        cell.lblTitle.text=((arrayLabels[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
        let friend = FriendsManager.friendsManager
        
        if indexPath.row == UserInfo.school.rawValue {
            
            cell.lblValue.text=friend.friendSchool
            
            if cell.lblValue.text == "" || cell.lblValue.text == nil {
                cell.lblValue.text = "N/A"
            }
        } else if indexPath.row == UserInfo.job.rawValue {
            
            
            cell.lblValue.text=friend.friendJob
            if cell.lblValue.text == "" || cell.lblValue.text == nil {
                cell.lblValue.text = "N/A"
            }
        } else if indexPath.row == UserInfo.location.rawValue {
            
            cell.lblValue.text=friend.friendCity
            if cell.lblValue.text == "" || cell.lblValue.text == nil {
                cell.lblValue.text = "N/A"
            }
        } else if indexPath.row == UserInfo.hobby.rawValue {
            
            cell.lblValue.text=friend.friendHobby
            if cell.lblValue.text == "" || cell.lblValue.text == nil {
                cell.lblValue.text = "N/A"
            }
        } else if indexPath.row == UserInfo.relation.rawValue {
            
            if friend.friendrelstatus == "a"||friend.friendrelstatus == "A" {
                cell.lblValue.text = "Available"
            } else if friend.friendrelstatus == "u"||friend.friendrelstatus == "U" {
                cell.lblValue.text = "Unavailable"
            }
        } else if indexPath.row == UserInfo.sexP.rawValue {
            
            if friend.friendsexpref == "o"||friend.friendsexpref == "O" {
                cell.lblValue.text = "Opposite"
            } else if friend.friendsexpref == "s"||friend.friendsexpref == "S" {
                cell.lblValue.text = "Same"
            }
        } else if (friend.friendGender != nil) {
            
            if friend.friendGender == "m"||friend.friendGender == "M" {
                cell.lblValue.text = "Male"
            } else if friend.friendGender == "f"||friend.friendGender == "F" {
                cell.lblValue.text = "Female"
            } else if friend.friendGender == "o"||friend.friendGender == "O" {
                cell.lblValue.text = "Transgender"
            }
        } else {
            cell.lblValue.text = "N/A"
        }
        
        // Configure the cell...
        
        return cell
    }
 
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
}
