//
//  RecordingsTableViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit

class MyRecordingsTableViewController: UITableViewController{
    
    var arrayOfRecordingsInfo = [Recording](){
        didSet{
            myTableView.reloadData()
        }
    }
    
    static var firstCancel: Bool!
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
  
    override func viewDidLoad(){
        super.viewDidLoad()
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        tableView.delegate=self
        tableView.dataSource=self
        self.songButton.layer.cornerRadius=8
        self.dateButton.layer.cornerRadius=8
        self.composerButton.layer.cornerRadius=8
        self.eventButton.layer.cornerRadius=8
    
    }
    
    @IBAction func unwindToMyRecordingsSave(_ segue: UIStoryboardSegue){
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
    }
    
    @IBAction func unwindToMyRecordingsCancel(_ segue: UIStoryboardSegue){
        
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        if MyRecordingsTableViewController.firstCancel==true{
            let cancelingOutFile = ("\(arrayOfRecordingsInfo.last?.filename).m4a")
                    var filePath = ""
            
                    let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
                    if dirs.count > 0 {
                        let dir = dirs[0] //documents directory
                        filePath = dir.appendingFormat("/" + cancelingOutFile)
                        print("Local path = \(filePath)")
            
                    } else {
                        print("Could not find local directory to store file")
                        return
                    }
            
            
                    do {
                        let fileManager = FileManager.default
            
                        // Check if file exists
                        if fileManager.fileExists(atPath: filePath) {
                            // Delete file
                            try fileManager.removeItem(atPath: filePath)
                        } else {
                            print("File does not exist")
                        }
            
                    }
                    catch let error as NSError {
                        print("An error took place: \(error)")
                    }
            
            if let recordingToCancelOut=arrayOfRecordingsInfo.last{
                CoreDataHelper.deleteRecording(recording: recordingToCancelOut)
                arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
            }
            
                    //end
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrayOfRecordingsInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "myRecordingsTableViewCell", for: indexPath) as! myRecordingsTableViewCell
        let currentRecording=arrayOfRecordingsInfo[indexPath.row]
        
        cell.songTitle.text=currentRecording.songTitle
        cell.lastModified.text="Last Modified at \(currentRecording.lastModified!.convertToString())"
        cell.songComposer.text=currentRecording.songComposer
        cell.songEvent.text=currentRecording.songEvent
        
        if cell.songTitle.text==""{
            cell.songTitle.text="No Title Entered"
        }
        if cell.songEvent.text==""{
            cell.songEvent.text="No Event Entered"
        }
        if cell.songComposer.text==""{
            cell.songComposer.text="No Composer Entered"
        }
        
        cell.pressPlayFile = currentRecording.filename
        
        if currentRecording.filename==nil{
            let redColor = UIColor(red: 232/255, green: 90/255, blue: 69/255, alpha: 1)
            cell.emptyLabel.textColor=redColor
        }else{
            let lightBeigeBackground = UIColor(red: 234/255, green: 231/255, blue: 220/255, alpha: 1)
            cell.emptyLabel.textColor=lightBeigeBackground
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            // Got the following code from: swiftdeveloperblog.com/code-examples/delete-file-example-in-swift/
            // Find documents directory on device
            let fileNameToDelete = ("\(arrayOfRecordingsInfo[indexPath.row].filename).m4a")
            var filePath = ""
            
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/" + fileNameToDelete)
                print("Local path = \(filePath)")
                
            } else {
                print("Could not find local directory to store file")
                return
            }
            
            
            do {
                let fileManager = FileManager.default
                
                // Check if file exists
                if fileManager.fileExists(atPath: filePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: filePath)
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            // End of code for deleting from the document directory also
            
            let recordingToDelete=arrayOfRecordingsInfo[indexPath.row]
            CoreDataHelper.deleteRecording(recording: recordingToDelete)
            arrayOfRecordingsInfo=CoreDataHelper.retrieveRecording()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier=segue.identifier else {return}

        switch identifier{
        case "displayMade":
            guard let indexPath=tableView.indexPathForSelectedRow else{return}
            let recording=arrayOfRecordingsInfo[indexPath.row]
            let destination=segue.destination as! RecordMusicViewController
            destination.recording=recording

        case "new":
            print("create note bar button item tapped")

        default:
            print("unexpected segue identifier")

        }
    }
}


