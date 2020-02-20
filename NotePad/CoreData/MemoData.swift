//
//  MemoData.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit
import CoreData

class MemoData {
    
    var title: String?
    var contents: String?
    var date: Date?
    var thumbnail: UIImage?
    var objectID: NSManagedObjectID?
    var imgIDs: [String]?
    
}
