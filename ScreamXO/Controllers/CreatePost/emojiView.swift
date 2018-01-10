//
//  emojiView.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 30/08/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class emojiView: UIView {

    // MARK: Properties
    
    var createPostVC: CreatePostVC?
    
    // MARK: IBOutlets
    
    @IBOutlet var addEmojiButton: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setNeedsUpdateConstraints()
        self.updateFocusIfNeeded()
    }
    
    
    // MARK: IBActions
    
    @IBAction func addEmoji(_ sender: UIButton) {
        if addEmojiButton.tag == 0 {
            createPostVC?.txtPost.resignFirstResponder()
            createPostVC!.txtPost.inputView = createPostVC!.emojiViewCollection.emojiCollectionView
            createPostVC?.txtPost.becomeFirstResponder()
            addEmojiButton.setImage(UIImage(named: "ico-keyboard"), for: UIControlState())
            addEmojiButton.tag = 1
            createPostVC!.txtPost.reloadInputViews()
        } else if addEmojiButton.tag == 1{
            createPostVC?.txtPost.resignFirstResponder()
            createPostVC?.txtPost.inputView = nil
            createPostVC?.txtPost.becomeFirstResponder()
            addEmojiButton.setImage(UIImage(named: "like"), for: UIControlState())
            addEmojiButton.tag = 0
            createPostVC?.txtPost.reloadInputViews()
        } 
    }
}
