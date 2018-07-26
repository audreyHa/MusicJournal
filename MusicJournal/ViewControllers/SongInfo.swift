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
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recording: Recording?
    
    @IBOutlet weak var startNewRecording: UIButton!
    @IBAction func startNewRecording(_ sender: Any) {
        if audioRecorder == nil{
            if recording == nil{
                recording = CoreDataHelper.newRecording()
            }
            
                var filename: URL!
                
                recording?.songDate=Date()
                var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                filename = paths[0].appendingPathComponent("\(recording?.songDate!.convertToString().removingWhitespacesAndNewlines).m4a")
                
                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                do{
                    audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                    audioRecorder.delegate=self
                    audioRecorder.record()
                    startNewRecording.setTitle("  Stop Recording  ", for: .normal)
                }
                catch{
                    displayAlert(title: "Failed to record", message: "Recording failed")
                }
        } else{
            //Stop Audio Recording
            audioRecorder.stop()
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
            if recording == nil{
                recording = CoreDataHelper.newRecording()
            }
            
            recording?.songTitle=songLabel.text ?? ""
            recording?.songEvent=eventLabel.text ?? ""
            recording?.songComposer=composerLabel.text ?? ""
            recording?.songDate=recording?.songDate
            recording?.filename=recording?.songDate!.convertToString().removingWhitespacesAndNewlines
            recording?.lastModified=Date()
            CoreDataHelper.saveRecording()
            
        case "cancel":
            if ((recording?.filename) != nil){
                recording?.filename=recording?.filename
            } else{
                 print("cancel tapped")
            }
           

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
        recordingSession = AVAudioSession.sharedInstance()
        
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
        var documentDirectory = paths[0]
        return documentDirectory
    }
    
    //function that displays an alert
    func displayAlert(title: String, message: String){
        let alert=UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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


