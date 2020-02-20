//
//  CollectionViewLayout.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class CollectionViewGridLayout: UICollectionViewFlowLayout {
    
    var numberOfColumns: Int = 3
    
    init(numberofColumns: Int) {
        super.init()
        self.numberOfColumns = numberofColumns
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init fail")
    }
    
    override var itemSize: CGSize {
        get{
            if let collectionView = collectionView {
                let collectionViewWidth = collectionView.frame.width
                let itemWidth = (collectionViewWidth/CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
                let itemHeight: CGFloat = itemWidth
                return CGSize(width: itemWidth, height: itemHeight)
            }
            return CGSize(width: 365/2, height: 365/2)
        }
        set{
            super.itemSize = newValue
        }
    }
}
