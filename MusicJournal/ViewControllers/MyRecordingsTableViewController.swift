//
//  RecordingsTableViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MyRecordingsTableViewController: UITableViewController, AVAudioRecorderDelegate{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    static var recordingFiles = [URL]()
    
    var count: Int = 0
    var fileInt: Int = 0
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var startNew: UIButton!
    
    @IBAction func startNewPressed(_ sender: Any) {
        //check if we have an active recorder
        if audioRecorder == nil{
            count+=1
            fileInt += 1
            var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let filename = paths[0].appendingPathComponent("\(fileInt).m4a")
            MyRecordingsTableViewController.recordingFiles.append(filename)
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
//            UserDefaults.standard.set(recordingFiles, forKey: "myStuff")
            myTableView.reloadData()
            startNew.setTitle("Press To Start NEW Recording", for: .normal)
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "secondViewController") as! RecordMusicViewController
            
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    
    var eventArray = [String]()
    var recordings = [Recording](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        recordings = CoreDataHelper.retrieveRecording()
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
        
//        if let myRecordingFilesArray: [URL] = UserDefaults.standard.object(forKey: "myStuff") as? [URL]{
//            recordingFiles = myRecordingFilesArray
//        }
        
        AVAudioSession.sharedInstance().requestRecordPermission {(hasPermission) in
            if hasPermission{
                print("Accepted!")
            }
        }
    }
    
    @IBAction func unwindToMyRecordings(_ segue: UIStoryboardSegue){
        recordings = CoreDataHelper.retrieveRecording()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return recordings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "myRecordingsTableViewCell", for: indexPath) as! myRecordingsTableViewCell
        let recording=recordings[indexPath.row]
       
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //var path=getDirectory().appendingPathComponent("\(indexPath.row+1).m4a")
       
//        var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let path=recordingFiles[indexPath.row]
//
//        do{
//            audioPlayer = try AVAudioPlayer(contentsOf: path)
//            audioPlayer.play()
//        } catch{
//            print("Something went wrong!!!")
//        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let recordingToDelete = recordings[indexPath.row]
            CoreDataHelper.deleteRecording(recording: recordingToDelete)
            recordings=CoreDataHelper.retrieveRecording()
            
            MyRecordingsTableViewController.recordingFiles.remove(at: indexPath.row)
            count -= 1
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier=segue.identifier else {return}
        
        switch identifier{
        case "displayMade":
            guard let indexPath=tableView.indexPathForSelectedRow else{return}
            
            let recording=recordings[indexPath.row]
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
