//
//  RecordMusicViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class RecordMusicViewController: UIViewController, AVAudioRecorderDelegate{
    
    static var recordingSession: AVAudioSession!
    static var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recording: Recording?
    var hasSegued = false
    var seconds: Int = 0
    var hours: Int = 0
    var minutes: Int=0
    static var timer=Timer()
    var countingTime=3
    var cancelOutArray = [String]()
    var deleteAfterSaving = [String]()
    
    func runTimer(){
        self.hours=0
        self.seconds = 0
        self.minutes=0
        RecordMusicViewController.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RecordMusicViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func newRecord(){
       
        
        if self.recording == nil{
            self.recording = CoreDataHelper.newRecording()
        }
        
        if (self.recording?.lastModified != nil && self.cancelOutArray.count==0) && self.recording?.dateSpace != nil{
            self.deleteAfterSaving.append("\((self.recording?.dateSpace!.convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: ""))!).m4a")
        }
        
        self.recording?.dateSpace=Date()
        
        let improvedDatespace=(self.recording?.dateSpace!.convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: ""))!
        self.cancelOutArray.append("\(improvedDatespace).m4a")
        var filename: URL?
        
        let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        
        
        filename = fileManager!.appendingPathComponent("\(improvedDatespace).m4a")
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        do{
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            //                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            RecordMusicViewController.audioRecorder = try AVAudioRecorder(url: filename!, settings: settings)
            RecordMusicViewController.audioRecorder.delegate=self
            RecordMusicViewController.audioRecorder.record()
            startNewRecording.setTitle("  Stop Recording  ", for: .normal)
        }
        catch{
            self.displayAlert(title: "Failed to record", message: "Recording failed")
        }
    }
    
    
    
    @objc func updateTimer(){
        if countingTime > 0{
            timeLabel.text="Starting in \(countingTime)"
            countingTime-=1
        }else{
            RecordMusicViewController.timer.invalidate()
            RecordMusicViewController.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecordMusicViewController.action), userInfo: nil, repeats: true)
            newRecord()
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
   
    @IBOutlet weak var startNewRecording: UIButton!
    @IBAction func startNewRecording(_ sender: Any) {
        if RecordMusicViewController.audioRecorder == nil{ //Starting a new one (not ending)
            
            if recording?.dateSpace != nil && cancelOutArray.count>0{ //if they're starting over
                createAlert(title: "Are you sure you want to start over?", message: "You cannot undo this action")
            } else{
                
               RecordMusicViewController.timer.invalidate()
                runTimer()
            }

        } else{ //Stopping
            //Stop Audio Recording
            
            RecordMusicViewController.audioRecorder.stop()
            
            RecordMusicViewController.timer.invalidate()
            RecordMusicViewController.audioRecorder = nil
            startNewRecording.setTitle("  Press To Start Over  ", for: .normal)

        }
    }
    
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var composerText: UILabel!
    @IBOutlet weak var songText: UILabel!
    
    @IBOutlet weak var songLabel: UITextField!
    @IBOutlet weak var composerLabel: UITextField!
    @IBOutlet weak var eventLabel: UITextField!
    

    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        songLabel.text=recording?.songTitle
        eventLabel.text=recording?.songEvent
        composerLabel.text=recording?.songComposer
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier = segue.identifier,
            let destination=segue.destination as? MyRecordingsTableViewController
            else {return}
        
        switch identifier{
        case "save":
           
            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if recording == nil{
                recording = CoreDataHelper.newRecording()
            }
            
            if deleteAfterSaving.count>0{ //if they're editting and they DID make a new recording
                recording?.hours=Double(hours)
                recording?.minutes=Double(minutes)
                recording?.seconds=Double(seconds)
            } else if deleteAfterSaving.count==0 && recording?.lastModified != nil{//editting but did not change the recording
                recording?.hours=Double((recording?.hours)!)
                recording?.minutes=Double((recording?.minutes)!)
                recording?.seconds=Double((recording?.seconds)!)
            }else{
                recording?.hours=Double(hours)
                recording?.minutes=Double(minutes)
                recording?.seconds=Double(seconds)
            }
            
            if deleteAfterSaving.count>0{
                for toBeDeleted in deleteAfterSaving{
                    var filePath = ""
                    
                    let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                    
                    if dirs.count > 0 {
                        let dir = dirs[0] //documents directory
                        filePath = dir.appendingFormat("/" + toBeDeleted)
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
                            print("got original to be deleted")
                        } else {
                            print("File does not exist for deleting after saving")
                        }
                        
                    }
                    catch let error as NSError {
                        print("An error took place: \(error)")
                    }
                }
                
            }
            
            if cancelOutArray.count>1{
                everythingButLast()
            }
            
            if RecordMusicViewController.audioRecorder != nil{
                RecordMusicViewController.audioRecorder.stop()
                RecordMusicViewController.audioRecorder = nil
                startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
            }
            
            RecordMusicViewController.timer.invalidate()
            countingTime=3

            recording?.songTitle=songLabel.text ?? ""
            recording?.songEvent=eventLabel.text ?? ""
            recording?.songComposer=composerLabel.text ?? ""
            
            if recording?.songTitle == ""{
                recording?.songTitle="No Title Entered"
            }
            
            if recording?.songComposer == ""{
                recording?.songComposer="No Composer Entered"
            }
            
            if recording?.songEvent == ""{
                recording?.songEvent="No Event Entered"
            }
            
            if let datespace=recording?.dateSpace{
                recording?.songDate=datespace
                recording?.filename="\((recording?.songDate!.convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: ""))!).m4a"
            }
            
            recording?.lastModified=Date()
            
           
            CoreDataHelper.saveRecording()
            
        case "cancel":
            
            if RecordMusicViewController.audioRecorder != nil{
                RecordMusicViewController.audioRecorder.stop()
                
                RecordMusicViewController.timer.invalidate()
                RecordMusicViewController.audioRecorder = nil
                startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
            }
            
            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if recording?.lastModified==nil{ //If it's the first round and hasn't been saved yet
                if cancelOutArray.count>0{
                    deleteEverything()
                }
                
                if recording?.dateSpace==nil{//didn't make a recording
                    MyRecordingsTableViewController.firstCancel=false
                    print("didn't record")
                } else{ //did make a recording
                    recording?.songTitle=songLabel.text ?? ""
                    recording?.songEvent=eventLabel.text ?? ""
                    recording?.songComposer=composerLabel.text ?? ""
                    
                    if recording?.songTitle==""{
                        recording?.songTitle="No Title Entered"
                    }
                    
                    if recording?.songComposer==""{
                        recording?.songComposer="No Composer Entered"
                    }
                    
                    if recording?.songEvent==""{
                        recording?.songEvent="No Event Entered"
                    }
                    recording?.songDate=recording?.dateSpace
                    recording?.filename="\((recording?.songDate?.convertToString().removingWhitespacesAndNewlines)!).m4a"
                    recording?.lastModified=Date()
                    CoreDataHelper.saveRecording()
                    MyRecordingsTableViewController.firstCancel=true
                }
            } else{
                if cancelOutArray.count>0{
                    deleteEverything()
                }
                MyRecordingsTableViewController.firstCancel=false
                recording?.dateSpace=recording?.songDate
                recording?.filename=recording?.filename
            }
           
         
        default:
            print("unexpected segue!")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        startNewRecording.layer.cornerRadius=8
        startNewRecording.setTitle("  Press To Start New Recording  ", for: .normal)
        
        if recording?.songDate == nil{
            startNewRecording.setTitle("  Press To Start New Recording  ", for: .normal)
        } else{
            startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
        }
        //Setting up session
        RecordMusicViewController.recordingSession = AVAudioSession.sharedInstance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecordMusicViewController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: RecordMusicViewController.recordingSession)
            
        AVAudioSession.sharedInstance().requestRecordPermission {(hasPermission) in
            if hasPermission{
                print("Accepted!")
            }
        }
       
        self.songText.layer.cornerRadius=8
        self.composerText.layer.cornerRadius=8
        self.eventText.layer.cornerRadius=8
        self.hideKeyboardWhenTappedAround()
       
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSessionInterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey])
                return }
        switch interruptionType {
        case .began:
            RecordMusicViewController.audioRecorder.stop()
            
            RecordMusicViewController.timer.invalidate()
            RecordMusicViewController.audioRecorder = nil
            startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
            
        default :
            RecordMusicViewController.audioRecorder.stop()
            
            RecordMusicViewController.timer.invalidate()
            RecordMusicViewController.audioRecorder = nil
            startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
            
        }
    }
    
    @objc func appMovedToBackground() {
        print("it should be working...")
        RecordMusicViewController.timer.invalidate()
                    countingTime=3
        
                    if RecordMusicViewController.audioRecorder != nil{
                        RecordMusicViewController.audioRecorder.stop()
                        RecordMusicViewController.audioRecorder = nil
                        startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
                    }
        
                    if recording == nil{
                        recording = CoreDataHelper.newRecording()
                    }
        
        
                        recording?.hours=Double(hours)
                        recording?.minutes=Double(minutes)
                        recording?.seconds=Double(seconds)
        
        
                    if deleteAfterSaving.count>0{
                        for toBeDeleted in deleteAfterSaving{
                            var filePath = ""
        
                            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        
                            if dirs.count > 0 {
                                let dir = dirs[0] //documents directory
                                filePath = dir.appendingFormat("/" + toBeDeleted)
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
                                    print("got original to be deleted")
                                } else {
                                    print("File does not exist for deleting after saving")
                                }
        
                            }
                            catch let error as NSError {
                                print("An error took place: \(error)")
                            }
                        }
        
                    }
        
                    if cancelOutArray.count>1{
                        everythingButLast()
                    }
        
                    recording?.songTitle=songLabel.text ?? ""
                    recording?.songEvent=eventLabel.text ?? ""
                    recording?.songComposer=composerLabel.text ?? ""
        
                    if recording?.songTitle == ""{
                        recording?.songTitle="No Title Entered"
                    }
        
                    if recording?.songComposer == ""{
                        recording?.songComposer="No Composer Entered"
                    }
        
                    if recording?.songEvent == ""{
                        recording?.songEvent="No Event Entered"
                    }
        
                    if let datespace=recording?.dateSpace{
                        recording?.songDate=datespace
                        recording?.filename="\((recording?.songDate!.convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: ""))!).m4a"
                    }
        
                    recording?.lastModified=Date()
        
        
                    CoreDataHelper.saveRecording()
        
//        var nextViewController=MyRecordingsTableViewController()
//        present(nextViewController, animated: true, completion: nil)
    } //end of function
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    
    //Gets path to directory
    func getDirectory() -> URL{
        
        var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //function that displays an alert
    func displayAlert(title: String, message: String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func action(){
        seconds+=1
        if seconds>59{ //more than 60 seconds
            displaying()
            seconds-=60
            minutes+=1
        }
        
        if minutes>59{
            displaying()
            minutes-=60
            hours+=1
        }
        if minutes<=59 && seconds<=59{
            displaying()
        }
        
        
    }
    //func displaying
    func displaying(){
        if hours==0{
            if minutes<10{
                if seconds<10{
                    timeLabel.text = String("0\(hours) : 0\(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("0\(hours) : 0\(minutes) : \(seconds)")
                }
            } else{
                if seconds<10{
                    timeLabel.text = String("0\(hours) : \(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("0\(hours) : \(minutes) : \(seconds)")
                }
            }
        } else{
            if minutes<10{
                if seconds<10{
                    timeLabel.text = String("\(hours) : 0\(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("\(hours) : 0\(minutes) : \(seconds)")
                }
            } else{
                if seconds<10{
                    timeLabel.text = String("\(hours) : \(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("\(hours) : \(minutes) : \(seconds)")
                }
            }
        }
    }
    //functions for deleting old recordings
    
    func everythingButLast(){
        for index in 0...cancelOutArray.count-2{
            var differentEachDate: String?
            differentEachDate = cancelOutArray[index]
            var new = differentEachDate!
            var filePath = ""
            
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/\(new)")
                
                
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
                    print("it works")
                } else {
                    print("For everything but last file does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
    
    func deleteEverything(){
        
        for eachDate in cancelOutArray{
            
            var filePath = ""
            let differentDeleting: String?
            var differentEachDate: String?
            differentEachDate = eachDate
            var new = differentEachDate!
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/\(new)")
                print("This is the filePath: \(filePath)")
                
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
                    print("it works")
                } else {
                    print("File does not exist for delete everything")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
    
    
    func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            self.timeLabel.text="Starting in 3"
            self.runTimer()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            print("They did not want to rerecord")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
} //end of class

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    var removingWhitespacesAndNewlines: String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
}


