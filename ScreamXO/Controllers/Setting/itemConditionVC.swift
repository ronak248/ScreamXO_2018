//
//  itemConditionVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-30.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

protocol addItemConditionDelegate: class {
    func addItemConditionDelegate(conditionTxt :String )
}


class itemConditionCell :UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesType: UILabel!

    
    override func awakeFromNib() {
        
    }
    
    override func layoutSubviews() {
       
    }
}


class itemConditionVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var backBtn: UIButton!
    var conditionArr: NSArray!
    var conditionNameArr: NSArray!

    var itemConditionDelegate: addItemConditionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let origImage = UIImage(named: "backi");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backBtn.setImage(tintedImage, for: .normal)
        
        
        
        conditionArr = ["New", "Like New", "Refurbished", "Fair", "Poor"]
        conditionNameArr = ["New With Tags (NWT), unused, unopened packaging",
                            "New Without Tags (NWOT), unused, no sign of wear",
                            "Gently used, functional, one/few minnor flaws",
                            "Used, functional, multiples flaws/defects",
                            "Major flwas, may be damaged, for parts"
    ]
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backAction(_ sender: Any) {
     self.navigationController?.popViewController(animated: true)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditionArr.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "itemConditionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath as IndexPath) as? itemConditionCell
        cell?.lblName.text = conditionArr[indexPath.row] as? String
        cell?.lblDesType.text = conditionNameArr[indexPath.row] as? String
        return cell!
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemConditionDelegate?.addItemConditionDelegate(conditionTxt: (conditionArr[indexPath.row] as? String)!)
        self.navigationController?.popViewController(animated: true)
    }

}
