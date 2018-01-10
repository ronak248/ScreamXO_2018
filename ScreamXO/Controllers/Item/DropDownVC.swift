//
//  DropDownVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 05/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

protocol CategorySelectDelegate  {
    func actionOnFilterCategory(_ reloadData: Bool)
    
}

class DropDownVC: UITableViewController {
    
    var selectedrow :NSInteger!
    let mgrItm = ItemManager.itemManager
    var delegate : CategorySelectDelegate!
    var selectedCategory = ""


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
        return mgrItm.arrayCategories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropCell", for: indexPath)
        
        let lblName : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let strname:String = ((mgrItm.arrayCategories[indexPath.row] as AnyObject).value(forKey: "category_name") as? String)!
        cell.contentView.backgroundColor = UIColor(red: 240/255, green: 239/255, blue: 245/255, alpha: 1.0)
        
        if let cateId = (mgrItm.arrayCategories[indexPath.row] as AnyObject).value(forKey: "id") as? Int {
            if selectedCategory == "\(cateId)" {
                cell.contentView.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
            }
        } else if let cateId = (mgrItm.arrayCategories[indexPath.row] as AnyObject).value(forKey: "id") as? String {
            if selectedCategory == cateId {
                cell.contentView.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
            } else if selectedCategory == "0" && cateId == "" {
                cell.contentView.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
            }
        }
        lblName.text = strname
        return cell
    }
 
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var reloadData = true
        
        if let cID: Int  = (mgrItm.arrayCategories.object(at: indexPath.row) as AnyObject).value(forKey: "id") as? Int {
            if mgrItm.ItemCategoryID == "\(cID)" {
                reloadData = false
            } else {
                mgrItm.ItemCategoryID = "\(cID)"
            }
            
        } else {
        
            mgrItm.ItemCategoryID = ""
        }
        if self.delegate != nil {
            self.delegate.actionOnFilterCategory(reloadData)
        }
        
    }
}
