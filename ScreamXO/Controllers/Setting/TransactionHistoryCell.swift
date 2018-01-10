//
//  TransactionHistoryCell.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-04.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class TransactionHistoryCell: UITableViewCell {

    @IBOutlet weak var transactionDetailLbl: UILabel!
    @IBOutlet weak var transactionAmountLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var transactionTypeImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
