//
//  CellMsg.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 22/09/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class CellMsg: UITableViewCell {

    // MARK: IBOutlets
    
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblLastMsg: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var imgViewBuySell: UIImageView!
    @IBOutlet var imgViewFriends: RoundImage!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
