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
import Crashlytics // If using Answers with Crashlytics


class RecordMusicViewController: UIViewController, AVAudioRecorderDelegate{
    
    static var recordingSession: AVAudioSession!
    var isPaused = Bool()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recording: Recording?

    var hasSegued = false
    var seconds = 100
    var hours = 100
    var minutes = 100
    static var timer=Timer()
    var countingTime=3
    var cancelOutArray = [String]()
    var deleteSaving = [String]()
    var titleArray = [String]()
    var eventArray = [String]()
    var compArray = [String]()
    var timeArray = [Int]()
    @IBOutlet weak var pauseRecording: UIButton!
    
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
        
        if self.recording?.filename != nil && cancelOutArray.count==0{
            deleteSaving.append((self.recording?.filename!)!)
        }
        
        self.recording?.filename="\((Date().convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: ""))).m4a"
        self.cancelOutArray.append((self.recording?.filename)!)
        var filename: URL?
        
        let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        
        
        filename = fileManager!.appendingPathComponent((self.recording?.filename)!)
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        do{
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            //                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            audioRecorder = try AVAudioRecorder(url: filename!, settings: settings)
            audioRecorder.delegate=self
            audioRecorder.record()
            startNewRecording.setTitle("  Stop  ", for: .normal)
        }
        catch{
            UserDefaults.standard.set("failToRecord",forKey: "typeShortAlert")
            makeShortAlert()
        }
    }
    
    func makeShortAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ShortAlertVC") as! ShortAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
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
         RecordMusicViewController.timer.invalidate()
        if isPaused==true{
            startNewRecording.setTitle("  Stop  ", for: .normal)
            audioRecorder.record()
            isPaused=false
            RecordMusicViewController.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecordMusicViewController.action), userInfo: nil, repeats: true)
        }else if audioRecorder == nil{ //Starting a new one (not ending)
            
            if recording?.filename != nil{
                if cancelOutArray.count>0{
                    UserDefaults.standard.set("startOver",forKey: "typeYesNoAlert")
                    makeYesNoAlert()
                }else{
                    Answers.logCustomEvent(withName: "Started Over")
                    runTimer()
                }
            } else{
                Answers.logCustomEvent(withName: "Started New Recording")
                runTimer()
            }

        } else{ //Stopping
            //Stop Audio Recording
            
            audioRecorder.stop()
            
            RecordMusicViewController.timer.invalidate()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)

        }
    }
    
//    @objc func anImportantUserAction() {
//
//        Answers.logCustomEvent(withName: "Saved New Recording")
//    }

    
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var composerText: UILabel!
    @IBOutlet weak var songText: UILabel!
    
    @IBOutlet weak var songLabel: UITextField!
    @IBOutlet weak var composerLabel: UITextField!
    @IBOutlet weak var eventLabel: UITextField!
    
    @IBAction func pauseRecordingPressed(_ sender: Any) {
        if audioRecorder != nil{
            audioRecorder.pause()
            RecordMusicViewController.timer.invalidate()
            isPaused=true
            startNewRecording.setTitle("  Continue  ", for: .normal)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        songLabel.text=recording?.songTitle
        eventLabel.text=recording?.songEvent
        composerLabel.text=recording?.songComposer
        
        if recording?.songTitle != nil{
            titleArray.append((recording?.songTitle)!)
        }
        
        if recording?.songComposer != nil{
            compArray.append((recording?.songComposer)!)
        }
        
        if recording?.songEvent != nil{
            eventArray.append((recording?.songEvent)!)
        }
        
        if recording?.hours != nil{
            timeArray.append(Int((recording?.hours)!))
            timeArray.append(Int((recording?.minutes)!))
            timeArray.append(Int((recording?.seconds)!))
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier = segue.identifier,
            let destination=segue.destination as? MyRecordingsTableViewController
            else {return}
        
        switch identifier{
        case "save":
            if hours != 100 && minutes != 100 && seconds != 100{
                recording?.hours=Double(hours)
                recording?.minutes=Double(minutes)
                recording?.seconds=Double(seconds)
            }

            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if recording == nil{
                recording = CoreDataHelper.newRecording()
                Answers.logCustomEvent(withName: "Saved New Recording")
            }
            
            if deleteSaving.count>0{
                for toBeDeleted in deleteSaving{
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
            
            if audioRecorder != nil{
                audioRecorder.stop()
                audioRecorder = nil
                startNewRecording.setTitle("  Start Over  ", for: .normal)
            }
            
            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if songLabel.text==""{
                recording?.songTitle="No Title"
            }else{
                recording?.songTitle=songLabel.text
            }
            
            if eventLabel.text==""{
                recording?.songEvent="No Event"
            }else{
                recording?.songEvent=eventLabel.text
            }
            
            if composerLabel.text==""{
                recording?.songComposer="No Composer"
            }else{
                recording?.songComposer=composerLabel.text
            }
            
            recording?.lastModified=Date()

            CoreDataHelper.saveRecording()
            
            cancelOutArray=[]
            deleteSaving=[]
            titleArray=[]
            eventArray=[]
            compArray=[]
            timeArray=[]
            
        case "cancel":
            
            if audioRecorder != nil{
                audioRecorder.stop()
                RecordMusicViewController.timer.invalidate()
                audioRecorder = nil
                startNewRecording.setTitle("  Start Over  ", for: .normal)
            }
            
            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if recording?.lastModified==nil{ //If it's the first round and hasn't been saved yet
                if recording==nil{
                    recording=CoreDataHelper.newRecording()
                }
                
                if cancelOutArray.count>0{
                    deleteEverything()
                }
                CoreDataHelper.saveRecording()
                Answers.logCustomEvent(withName: "Canceled: 1st Round Not Saved")
            } else{
                if deleteSaving.count>0{
                    recording?.filename=deleteSaving[0]
                }
                
                recording?.songTitle=titleArray[0]
                recording?.songComposer=compArray[0]
                recording?.songEvent=eventArray[0]
                recording?.hours=Double(timeArray[0])
                recording?.minutes=Double(timeArray[1])
                recording?.seconds=Double(timeArray[2])
                recording?.lastModified=Date()
                
                if cancelOutArray.count>0{
                    deleteEverything()
                }
                
                cancelOutArray=[]
                deleteSaving=[]
                titleArray=[]
                eventArray=[]
                compArray=[]
                timeArray=[]
                CoreDataHelper.saveRecording()
                Answers.logCustomEvent(withName: "Canceled: Later Round Undid Changes")
            }
         
        default:
            print("unexpected segue!")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        pauseRecording.layer.cornerRadius=8
        startNewRecording.layer.cornerRadius=8
        startNewRecording.setTitle("  Start NEW  ", for: .normal)
        
        if recording?.lastModified == nil{
            startNewRecording.setTitle("  Start NEW  ", for: .normal)
        } else{
            startNewRecording.setTitle("  Start Over  ", for: .normal)
        }
        //Setting up session
        RecordMusicViewController.recordingSession = AVAudioSession.sharedInstance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecordMusicViewController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: RecordMusicViewController.recordingSession)
            
        AVAudioSession.sharedInstance().requestRecordPermission {(hasPermission) in
            if hasPermission{
                print("Accepted!")
            }
        }
       
        //self.songText.layer.cornerRadius=8
        //self.composerText.layer.cornerRadius=8
        //self.eventText.layer.cornerRadius=8
        self.hideKeyboardWhenTappedAround()
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("startOver"), object: nil)
    }
    
    //Function for handling receiving notification
    @objc func methodOfReceivedNotification(notification: Notification) {
        Answers.logCustomEvent(withName: "Started Over")
        self.countingTime=3
        self.runTimer()
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSessionInterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey] as Any)
                return }
        switch interruptionType {
        case .began:
            if audioRecorder != nil{
                audioRecorder.stop()
            }
            
            RecordMusicViewController.timer.invalidate()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)
           
            
        default :
            if audioRecorder != nil{
                audioRecorder.stop()
            }
            
            RecordMusicViewController.timer.invalidate()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)
        }
    }
    
    @objc func appMovedToBackground() {
        if hours != 100 && minutes != 100 && seconds != 100{
            recording?.hours=Double(hours)
            recording?.minutes=Double(minutes)
            recording?.seconds=Double(seconds)
        }
        
        RecordMusicViewController.timer.invalidate()
        countingTime=3
        
        if recording == nil{
            recording = CoreDataHelper.newRecording()
        }
        
        if audioRecorder != nil{
            audioRecorder.stop()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)
        }
        
        if songLabel.text==""{
            recording?.songTitle="No Title"
        }else{
            recording?.songTitle=songLabel.text
        }
        
        if eventLabel.text==""{
            recording?.songEvent="No Event"
        }else{
            recording?.songEvent=eventLabel.text
        }
        
        if composerLabel.text==""{
            recording?.songComposer="No Composer"
        }else{
            recording?.songComposer=composerLabel.text
        }
        
        CoreDataHelper.saveRecording()
        
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
            let new = differentEachDate!
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
            let new = differentEachDate!
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
    
    func makeYesNoAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "YesNoAlertVC") as! YesNoAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
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
