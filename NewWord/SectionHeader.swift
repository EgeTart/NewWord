//
//  SectionHeader.swift
//  NewWord
//
//  Created by 高永效 on 15/11/21.
//  Copyright © 2015年 EgeTart. All rights reserved.
//

import UIKit

class SectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var expandImageView: UIImageView!
    
    @IBOutlet weak var stateButton: UIButton!
    
    @IBOutlet weak var recordCountLabel: UILabel!
    
    
    var section = 0
    
    @IBAction func stateChange(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("stateChanged", object: nil, userInfo: ["section": section])
    }
    
}
