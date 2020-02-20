//
//  MemoCell.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class MemoCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var creationDate: UILabel!
    @IBOutlet var contents: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var trailConstOfTitle: NSLayoutConstraint!
    
}


