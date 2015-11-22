//
//  WordListController.swift
//  NewWord
//
//  Created by 高永效 on 15/11/20.
//  Copyright © 2015年 EgeTart. All rights reserved.
//

import UIKit

class WordListController: UIViewController {
    
    @IBOutlet weak var wordTableView: UITableView!
    let request = HTTPTask()
    
    let baseURL = "http://dict-co.iciba.com/api/dictionary.php?type=json&key=E75BB6EEFE4CAF2A1BA0C6C179002746&w="

    var results = [Word]()
    
    var sortWord = [[String: [Word]]]()
    var sectionTitles = [String]()
    var isExpand = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordTableView.estimatedRowHeight = 44
        wordTableView.rowHeight = UITableViewAutomaticDimension
        wordTableView.tableFooterView = UIView(frame: CGRectZero)
        
        wordTableView.registerNib(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addWord:", name: "addNewWord", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showOrHide:", name: "stateChanged", object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sortWordByFirstChar()
    }
    
    func getNewWordData(newWord: String) {
        let queryURL = baseURL + newWord
        
        request.GET(queryURL, parameters: nil) { (response: HTTPResponse) -> Void in
            
            if response.responseObject != nil {
                let result = try! NSJSONSerialization.JSONObjectWithData(response.responseObject as! NSData, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
                let important = result["symbols"] as! NSMutableArray
                
                let newWord = NewWord(word: newWord, content: important[0] as! [String : AnyObject])
                print(newWord.means)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    newWord.getMp3Data()
                })
            }
        }
    }
    
    
    @IBAction func addNewWord(sender: AnyObject) {
        
        let wordAlert = UIAlertController(title: nil, message: "添加新单词", preferredStyle: UIAlertControllerStyle.Alert)
        wordAlert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.placeholder = "Add New Word"
        }
        
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default) { (_) -> Void in
            let newWord = (wordAlert.textFields![0] as UITextField).text
            
            let isExist = (Word.findByAttribute("word", withValue: newWord).count == 0) ? false : true
            
            if !isExist {
                self.getNewWordData(newWord!)
            }
        }
        
        let cancleAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: nil)
        
        wordAlert.addAction(okAction)
        wordAlert.addAction(cancleAction)
        
        presentViewController(wordAlert, animated: true, completion: nil)
    }
    
    func addWord(notification: NSNotification) {

        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.sortWordByFirstChar()
        }
    }
    
    func sortWordByFirstChar() {
        
        sortWord.removeAll()
        sectionTitles.removeAll()
        isExpand.removeAll()
        
        let words = Word.MR_findAllSortedBy("word", ascending: true) as! [Word]
        
        let firstChar = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        
        for char in firstChar {
            let wordGroup = words.filter { (word: Word) -> Bool in
                return word.firstChar?.uppercaseString == char
            }
            if wordGroup.count > 0 {
                sortWord.append([char: wordGroup])
                sectionTitles.append(char)
            }
        }
        isExpand = [Bool](count: sectionTitles.count, repeatedValue: false)
        wordTableView.reloadData()
    }

}

extension WordListController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isExpand[section] == false {
            return 0
        }
        
        let firstChar = sectionTitles[section]
        return sortWord[section][firstChar]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wordCell", forIndexPath: indexPath) as! WordCell
        
        let firstChar = sectionTitles[indexPath.section]
        let words = sortWord[indexPath.section][firstChar]!
        
        cell.wordLabel.text = words[indexPath.row].word
        cell.phamLabel.text = words[indexPath.row].pham
        cell.phenLabel.text = words[indexPath.row].phen
        cell.meansLabel.text = words[indexPath.row].means
        cell.phammp3Data = words[indexPath.row].phammp3Data
        cell.phenmp3Data = words[indexPath.row].phenmp3Data
        
        return cell
    }
}

extension WordListController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let firstChar = sectionTitles[indexPath.section]
            var words = sortWord[indexPath.section][firstChar]!
            
            let wordToDelete = words[indexPath.row]
            wordToDelete.MR_deleteEntity()
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            
            sortWord[indexPath.section][firstChar]?.removeAtIndex(indexPath.row)
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! SectionHeader
        sectionHeader.titleLabel.text = sectionTitles[section]
        
        let firstChar = sectionTitles[section]
        let recordCount = sortWord[section][firstChar]!.count
        sectionHeader.recordCountLabel.text = "\(recordCount) record(s) here"
        
        sectionHeader.section = section
        if isExpand[section] == true {
            sectionHeader.expandImageView.image = UIImage(named: "up")
        }
        else {
            sectionHeader.expandImageView.image = UIImage(named: "down")
        }
        return sectionHeader
    }
    
    func showOrHide(notification: NSNotification) {
        let section = notification.userInfo!["section"] as! Int
        isExpand[section] = !isExpand[section]
        wordTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
}
