//
//  Word+CoreDataProperties.swift
//  NewWord
//
//  Created by 高永效 on 15/11/20.
//  Copyright © 2015年 EgeTart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Word {

    @NSManaged var word: String?
    @NSManaged var means: String?
    @NSManaged var pham: String?
    @NSManaged var phen: String?
    @NSManaged var phammp3Data: NSData?
    @NSManaged var phenmp3Data: NSData?
    @NSManaged var firstChar: String?
    @NSManaged var date: String?

}
