//
//  FilesIntsArrayCoreDataHelper.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/23/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct FilesIntsArrayCoreDataHelper{
   
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        return context
    }()
    
    static func newFilesIntsArray() -> FilesIntsArray{
        var myFilesIntsArray = NSEntityDescription.insertNewObject(forEntityName: "FilesIntsArray", into: context) as! FilesIntsArray
        return myFilesIntsArray
        
    }
    
    static func saveFilesIntsArray(){
        do{
            try context.save()
        } catch let error{
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func deleteFilesIntsArray(filesIntsArray: FilesIntsArray){
        
        context.delete(filesIntsArray)
        saveFilesIntsArray()
    }
    
    static func retrieveArrayOfFilesIntsArray() -> [FilesIntsArray]{
        do{
            let fetchRequest = NSFetchRequest<FilesIntsArray>(entityName: "FilesIntsArray")
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error{
            print("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
}


