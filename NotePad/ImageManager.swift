//
//  ImageManager.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/21.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit


class ImageManager {

    class func saveImage(img: UIImage) -> String {
        let imgID = UUID().uuidString + ".jpg"
        let fileManager = FileManager.default
        let directory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("ImageDirectory")
        let imageData = img.jpegData(compressionQuality: 1.0)
        let dir = directory as NSString
        let path = dir.appendingPathComponent(imgID)
        
        do {
            if !fileManager.fileExists(atPath: directory ){
                try fileManager.createDirectory(atPath: directory as String, withIntermediateDirectories: true, attributes: nil)
            }
            
            fileManager.createFile(atPath: path, contents: imageData, attributes: nil)
            
            }catch let err as NSError {
                NSLog("error: %s", err.localizedDescription)
            }
            return imgID
        }
    
    class func deleteImage(imgIDs: [String], index: Int) {
        let fileManager = FileManager.default
        let directory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("ImageDirectory") as NSString
        
        let path = directory.appendingPathComponent(imgIDs[index])
        
        if fileManager.fileExists(atPath: path ) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch let err as NSError{
                NSLog("error: %s", err.localizedDescription)
            }
        }
    }
    
    class func fetchImageFromDocumentDitectory(_ imgIDs: [String]?) -> [UIImage]  {
       
        let fileManager = FileManager.default
        var imgList: [UIImage] = []
        
        if let imageIDs = imgIDs{
        for imgID in imageIDs {
            let directory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("ImageDirectory")
            let path = (directory as NSString).appendingPathComponent(imgID)
            
            if fileManager.fileExists(atPath: path){
                if let image =  UIImage(contentsOfFile: path){
                    imgList.append(image)
                }
             }
           }
        }
        return imgList
        }
}
