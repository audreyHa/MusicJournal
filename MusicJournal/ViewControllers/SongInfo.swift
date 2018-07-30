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

class RecordMusicViewController: UIViewController, AVAudioRecorderDelegate{
    
    static var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recording: Recording?
    
    var seconds: Int = 0
    var hours: Int = 0
    var minutes: Int=0
    var timer=Timer()
    var countingTimer=Timer()
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startNewRecording: UIButton!
    @IBAction func startNewRecording(_ sender: Any) {
        if audioRecorder == nil{ //Starting a new one (not ending)
            
                self.timeLabel.text=("Starting in 3")
            
                delay(1){
                self.timeLabel.text=("Starting in 2")
                    self.delay(1){
                        self.timeLabel.text=("Starting in 1")
                    }
                }
            
            
            
            delay(3){
                self.timer.invalidate()
                self.timeLabel.text = "00 : 00 : 00"
                self.hours=0
                self.seconds=0
                self.minutes=0
                
                
                if self.recording == nil{
                    self.recording = CoreDataHelper.newRecording()
                }
                
                self.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecordMusicViewController.action), userInfo: nil, repeats: true)
                
                self.recording?.dateSpace=Date()
                
                var filename: URL?
                
                let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                filename = fileManager!.appendingPathComponent("\(self.recording?.dateSpace?.convertToString().removingWhitespacesAndNewlines).m4a")
                
                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                do{
                    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
//                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                    self.audioRecorder = try AVAudioRecorder(url: filename!, settings: settings)
                    self.audioRecorder.delegate=self
                    self.audioRecorder.record()
                    self.startNewRecording.setTitle("  Stop Recording  ", for: .normal)
                }
                catch{
                    self.displayAlert(title: "Failed to record", message: "Recording failed")
                }
            }
            
        } else{ //Stopping
            //Stop Audio Recording
            
            audioRecorder.stop()
            
            timer.invalidate()
            audioRecorder = nil
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
            if audioRecorder != nil{
                audioRecorder.stop()
                
                timer.invalidate()
                audioRecorder = nil
                startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
            }
            
            if recording == nil{
                recording = CoreDataHelper.newRecording()
            }
            
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
            recording?.filename=recording?.songDate?.convertToString().removingWhitespacesAndNewlines
            recording?.lastModified=Date()
           
            CoreDataHelper.saveRecording()
            
        case "cancel":
            //might just wanna check whether they made changes or not
            if recording?.lastModified==nil{ //If it's the first round and hasn't been saved yet
                if recording?.dateSpace==nil{//didn't make a recording
                    MyRecordingsTableViewController.firstCancel=false
                    print("First and didn't record")
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
                    recording?.filename=recording?.songDate?.convertToString().removingWhitespacesAndNewlines
                    recording?.lastModified=Date()
                    CoreDataHelper.saveRecording()
                    MyRecordingsTableViewController.firstCancel=true
                }
            } else{
                MyRecordingsTableViewController.firstCancel=false
                recording?.dateSpace=recording?.songDate
                recording?.filename=recording?.filename
            }
            
                
//            if (recording?.filename != nil){ //If it's not the first time
//                MyRecordingsTableViewController.firstCancel=false
//                recording?.dateSpace=recording?.songDate
//                recording?.filename=recording?.filename
//
//
//            }
//            if (recording?.filename == nil){ //If it is the first time or if they didn't make a recording last time
//
//                CoreDataHelper.saveRecording()
//                MyRecordingsTableViewController.firstCancel=true
//
//            }
           

        default:
            print("unexpected segue!")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        startNewRecording.setTitle("  Press To Start New Recording  ", for: .normal)
        
        if recording?.songDate == nil{
            startNewRecording.setTitle("  Press To Start New Recording  ", for: .normal)
        } else{
            startNewRecording.setTitle("  Press To Start Over  ", for: .normal)
        }
        //Setting up session
        RecordMusicViewController.recordingSession = AVAudioSession.sharedInstance()
        
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
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    @objc func action(){
        seconds += 1
        if seconds>59{ //more than 60 seconds
            seconds-=60
            minutes+=1
        }
        
        if minutes>59{
            minutes-=60
            hours+=1
        }
        
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


