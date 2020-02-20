//
//  ImageDetailViewController.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {

    @IBOutlet var imageCollection: UICollectionView!
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var imgList: [UIImage]?
    var idxPath: IndexPath?
    var onceOnly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollection.dataSource = self
        imageCollection.delegate = self
    }
}

extension ImageDetailViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
          imageCollection.scrollToItem(at: idxPath!, at: .centeredHorizontally, animated: false)
          onceOnly = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageDetailCell", for: indexPath) as! ImageCell
        cell.imgView.image = imgList?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: imageCollection.frame.height )
    }
 }


