//
//  WordCell.swift
//  NewWord
//
//  Created by 高永效 on 15/11/21.
//  Copyright © 2015年 EgeTart. All rights reserved.
//

import UIKit
import AVFoundation

class WordCell: UITableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var phamLabel: UILabel!
    @IBOutlet weak var phenLabel: UILabel!
    @IBOutlet weak var meansLabel: UILabel!
    
    var phammp3Data: NSData!
    var phenmp3Data: NSData!
    
    var player: AVAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func play(sender: UIButton) {
        
        if sender.tag == 101 {
            player = try! AVAudioPlayer(data: phammp3Data)
        }
        else {
            player = try! AVAudioPlayer(data: phenmp3Data)
        }
        player.prepareToPlay()
        player.play()
        
    }

}
