//
//  MemoDAO.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit
import CoreData

class MemoDAO {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotePad")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func fetch() -> [MemoData] {
        var memoList = [MemoData]()
        let fetchRequest: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        // 최신글 순으로 정렬
        let dateDesc = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateDesc]
        
        do{
            let result = try self.context.fetch(fetchRequest)
            for record in result {
                let data = MemoData()
                
                data.title = record.title
                data.contents = record.contents
                data.date = record.date
                data.objectID = record.objectID
                data.imgIDs = record.imgIDs
                
                if let thumbnailData = record.thumbnail {
                    data.thumbnail = UIImage(data:thumbnailData)
                }
                memoList.append(data)
            }
        } catch let err as NSError {
            NSLog("error: %s", err.localizedDescription)
        }
        return memoList
    }
    
    func insert(_ data: MemoData) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! Memo

        object.title = data.title
        object.contents = data.contents
        object.date = data.date
        object.imgIDs = data.imgIDs
        
        if let image = data.thumbnail {
            object.thumbnail = image.pngData()
        }
        
        do{
            try self.context.save()
        } catch let err as NSError{
            NSLog("error: %s", err.localizedDescription)
        }
    }
    
    func update(_ data: MemoData,_ objectID: NSManagedObjectID)  {
        let object = self.context.object(with: objectID) as! Memo
        
        object.title = data.title
        object.contents = data.contents
        object.date = data.date
        object.imgIDs = data.imgIDs
        
        if let image = data.thumbnail {
            object.thumbnail = image.pngData()
        } else {
            object.thumbnail = nil
        }
        
        do{
            try self.context.save()
        } catch let err as NSError{
            NSLog("error: %s", err.localizedDescription)
        }
    }
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        
        let object = self.context.object(with: objectID) as! Memo
        
        if let imgIDs = object.imgIDs{
        for i in 0..<imgIDs.count{
            ImageManager.deleteImage(imgIDs: imgIDs, index: i)
        }
        }
        
        self.context.delete(object)
        
        do{
            try self.context.save()
            return true
        } catch let err as NSError{
            NSLog("error: %s", err.localizedDescription)
            return false
        }
    }
}
