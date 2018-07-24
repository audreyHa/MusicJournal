//
//  CoreDataHelper.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/23/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CoreDataHelper{
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        return context
    }()
    
    static func newRecording() -> Recording{
        var myRecording = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: context) as! Recording
        return myRecording
    }
    
    static func saveRecording(){
        do{
            try context.save()
        } catch let error{
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func deleteRecording(recording: Recording){
       
        context.delete(recording)
        saveRecording()
    }
    
    static func retrieveRecording() -> [Recording]{
        do{
            let fetchRequest = NSFetchRequest<Recording>(entityName: "Recording")
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error{
            print("Could not fetch \(error.localizedDescription)")
            return []
        }
    }
}

