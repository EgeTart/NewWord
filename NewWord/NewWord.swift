//
//  NewWord.swift
//  NewWord
//
//  Created by 高永效 on 15/11/20.
//  Copyright © 2015年 EgeTart. All rights reserved.
//

//Optional((
//    {
//        parts =         (
//            {
//                means =                 (
//                    "\U8d70",
//                    "\U79bb\U5f00",
//                    "\U53bb\U505a",
//                    "\U8fdb\U884c"
//                );
//                part = "vi.";
//            },
//            {
//                means =                 (
//                    "\U53d8\U5f97",
//                    "\U53d1\U51fa\U2026\U58f0\U97f3",
//                    "\U6210\U4e3a",
//                    "\U5904\U4e8e\U2026\U72b6\U6001"
//                );
//                part = "vt.";
//            },
//            {
//                means =                 (
//                    "\U8f6e\U5230\U7684\U987a\U5e8f",
//                    "\U7cbe\U529b",
//                    "\U5e72\U52b2",
//                    "\U5c1d\U8bd5"
//                );
//                part = "n.";
//            }
//        );
//        "ph_am" = "go\U028a";
//        "ph_am_mp3" = "http://res.iciba.com/resource/amp3/1/0/34/d1/34d1f91fb2e514b8576fab1a75a89a6b.mp3";
//        "ph_en" = "g\U0259\U028a";
//        "ph_en_mp3" = "http://res.iciba.com/resource/amp3/0/0/34/d1/34d1f91fb2e514b8576fab1a75a89a6b.mp3";
//        "ph_other" = "";
//        "ph_tts_mp3" = "http://res-tts.iciba.com/3/4/d/34d1f91fb2e514b8576fab1a75a89a6b.mp3";
//    }
//))

import Foundation

class NewWord {
    
    var word = ""
    var pham = ""
    var phen = ""
    var means = ""
    var phammp3 = ""
    var phenmp3 = ""
    var phammp3Data: NSData?
    var phenmp3Data: NSData?
    
    let request1 = HTTPTask()
    let request2 = HTTPTask()
    
    //let newWord = Word.MR_createEntity()
    
    
    init(word: String, content: [String: AnyObject]) {
        
        self.word = word
        self.pham = content["ph_am"] as! String
        self.phen = content["ph_en"] as! String
        self.phammp3 = content["ph_am_mp3"] as! String
        self.phenmp3 = content["ph_en_mp3"] as! String
        
        let meansArray = content["parts"] as! NSMutableArray
        
        for element in meansArray {
            let mean = element["means"] as! [String]
            for (index, item) in EnumerateSequence(mean) {
                self.means += ("\(index + 1)." + item + " ")
            }
            self.means += "\n"
        }
        let length = (self.means as NSString).length
        self.means = (self.means as NSString).substringToIndex(length - 1)
        
    }
    
    func getMp3Data() {
        
        let newWord = Word.MR_createEntity()
        
        newWord.word = self.word
        newWord.means = self.means
        newWord.pham = self.pham
        newWord.phen = self.phen
        newWord.firstChar = (self.word as NSString).substringToIndex(1).lowercaseString
        
        let date = NSDate()
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "YYYY-MM-dd"
        newWord.date = dateFormater.stringFromDate(date)

        
        request1.GET(phenmp3, parameters: nil) { (response: HTTPResponse) -> Void in
            if response.responseObject != nil {
                
                self.phenmp3Data = response.responseObject as? NSData
                newWord.phenmp3Data = self.phenmp3Data
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()

            }
        }
        
        request2.GET(phammp3, parameters: nil) { (response: HTTPResponse) -> Void in
            if response.responseObject != nil {
                self.phammp3Data = response.responseObject as? NSData
                newWord.phammp3Data = self.phammp3Data
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                
                NSNotificationCenter.defaultCenter().postNotificationName("addNewWord", object: nil, userInfo: ["newWord": self.word])
            }
        }
    }
    
}
