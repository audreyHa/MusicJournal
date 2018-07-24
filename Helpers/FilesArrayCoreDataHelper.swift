//
//  FilesArrayCoreDataHelper.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/23/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct FilesArrayCoreDataHelper{
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        return context
    }()
    
    static func newFilesArray() -> FilesArray{
        var myFilesArray = NSEntityDescription.insertNewObject(forEntityName: "FilesArray", into: context) as! FilesArray
        return myFilesArray
        
    }
    
    static func saveFilesArray(){
        do{
            try context.save()
        } catch let error{
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func deleteFilesArray(filesArray: FilesArray){
        
        context.delete(filesArray)
        saveFilesArray()
    }
    
    static func retrieveArrayOfFilesArray() -> [FilesArray]{
        do{
            let fetchRequest = NSFetchRequest<FilesArray>(entityName: "FilesArray")
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error{
            print("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
}


