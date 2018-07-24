//
//  RecordingsTableViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MyRecordingsTableViewController: UITableViewController, AVAudioRecorderDelegate{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    static var recordingFiles = [URL]()
    static var recordingFilesInts = [Int]()
    
    var count: Int = 0
    var fileInt: Int = 0
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var startNew: UIButton!
    
    
    var eventArray = [String]()
    
    //you need this recordings array. it's going to store the song, event, and composer for each of the recordings. Core data is doing all of it's work with the each of the array items in the array "recordings"
    
    var arrayOfRecordingsInfo = [Recording](){
        didSet{
            myTableView.reloadData()
        }
    }
   
    @IBAction func startNewPressed(_ sender: Any) {
        //check if we have an active recorder
       
        if audioRecorder == nil{
            count+=1
            fileInt += 1
            var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let filename = paths[0].appendingPathComponent("\(fileInt).m4a")
            MyRecordingsTableViewController.recordingFiles.append(filename)
            MyRecordingsTableViewController.recordingFilesInts.append(fileInt)
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            do{
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate=self
                audioRecorder.record()
                startNew.setTitle("Stop Recording", for: .normal)
            }
            catch{
                displayAlert(title: "Failed to record", message: "Recording failed")
            }
            
        } else{
            //Stop Audio Recording
            audioRecorder.stop()
            audioRecorder = nil
            UserDefaults.standard.set(count, forKey: "myNumber")
            UserDefaults.standard.set(fileInt, forKey: "myFileInt")
            UserDefaults.standard.set(MyRecordingsTableViewController.recordingFiles, forKey: "recordingFilesPersistingArray")
            UserDefaults.standard.set(MyRecordingsTableViewController.recordingFilesInts, forKey: "recordingFilesIntsPersistingArray")
            
            myTableView.reloadData()
            startNew.setTitle("Press To Start NEW Recording", for: .normal)
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "secondViewController") as! RecordMusicViewController
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    
   
    
    override func viewDidLoad(){
        super.viewDidLoad()
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        tableView.delegate=self
        tableView.dataSource=self
        self.songButton.layer.cornerRadius=8
        self.dateButton.layer.cornerRadius=8
        self.composerButton.layer.cornerRadius=8
        self.eventButton.layer.cornerRadius=8
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            count = number
        }
        
        if let fileNumber: Int = UserDefaults.standard.object(forKey: "myFileInt") as? Int{
            fileInt = fileNumber
        }
        
        if let newRecordingFilesPersistingArray: [URL] = UserDefaults.standard.object(forKey: "recordingFilesPersistingArray") as? [URL]{
            MyRecordingsTableViewController.recordingFiles = newRecordingFilesPersistingArray
        }
        
        if let newRecordingFilesIntsPersistingArray: [Int] = UserDefaults.standard.object(forKey: "recordingFilesIntsPersistingArray") as? [Int]{
            MyRecordingsTableViewController.recordingFilesInts = newRecordingFilesIntsPersistingArray
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission {(hasPermission) in
            if hasPermission{
                print("Accepted!")
            }
        }
    }
    
    @IBAction func unwindToMyRecordings(_ segue: UIStoryboardSegue){
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrayOfRecordingsInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "myRecordingsTableViewCell", for: indexPath) as! myRecordingsTableViewCell
        let recording=arrayOfRecordingsInfo[indexPath.row]
       
        cell.songTitle.text=recording.songTitle
        cell.songDate.text=recording.songDate?.convertToString()
        cell.songComposer.text=recording.songComposer
        cell.songEvent.text=recording.songEvent
        if cell.songTitle.text==""{
            cell.songTitle.text="No Title Entered"
        }
        if cell.songEvent.text==""{
            cell.songEvent.text="No Event Entered"
        }
        if cell.songComposer.text==""{
            cell.songComposer.text="No Composer Entered"
        }
        
        cell.rowOfCellForRecording=indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let recordingToDelete = arrayOfRecordingsInfo[indexPath.row]
            CoreDataHelper.deleteRecording(recording: recordingToDelete)
            arrayOfRecordingsInfo=CoreDataHelper.retrieveRecording()
            
            // Got the following code from: swiftdeveloperblog.com/code-examples/delete-file-example-in-swift/
            
            let fileNameToDelete = ("\(MyRecordingsTableViewController.recordingFilesInts[indexPath.row]).m4a")
            var filePath = ""
            
            // Fine documents directory on device
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
                    print("succesfully removed")
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            //
            
            MyRecordingsTableViewController.recordingFiles.remove(at: indexPath.row)
            MyRecordingsTableViewController.recordingFilesInts.remove(at: indexPath.row)
            count -= 1
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
    
    //Gets path to directory
    func getDirectory() -> URL{
        
        var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentDirectory = paths[0]
        return documentDirectory
    }
    
    //function that displays an alert
    func displayAlert(title: String, message: String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}
