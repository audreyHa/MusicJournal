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

class RecordMusicViewController: UIViewController{
    
    var recording: Recording?
    
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var composerText: UILabel!
    @IBOutlet weak var songText: UILabel!
    
    @IBOutlet weak var startNew: UIButton!
    @IBAction func newButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var songLabel: UITextField!
    @IBOutlet weak var composerLabel: UITextField!
    @IBOutlet weak var eventLabel: UITextField!
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        if let recording=recording{
            songLabel.text=recording.songTitle
            eventLabel.text=recording.songEvent
            composerLabel.text=recording.songComposer
        } else{
            songLabel.text=""
            composerLabel.text=""
            eventLabel.text=""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier = segue.identifier,
            let destination=segue.destination as? MyRecordingsTableViewController
            else {return}
        
        switch identifier{
        case "save" where recording != nil:
            recording?.songTitle=songLabel.text ?? ""
            recording?.songEvent=eventLabel.text ?? ""
            recording?.songComposer=composerLabel.text ?? ""
            recording?.songDate=Date()
            
            CoreDataHelper.saveRecording()
            
        case "save" where recording == nil:
            let recording = CoreDataHelper.newRecording()
            recording.songTitle=songLabel.text ?? ""
            recording.songEvent=eventLabel.text ?? ""
            recording.songComposer=composerLabel.text ?? ""
            recording.songDate=Date()
            
            CoreDataHelper.saveRecording()
            
        case "cancel":
            MyRecordingsTableViewController.recordingFiles.removeLast()
//            MyRecordingsTableViewController.recordings.removeLast()
        
        default:
            print("unexpected segue!")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
       
        self.songText.layer.cornerRadius=8
        self.composerText.layer.cornerRadius=8
        self.eventText.layer.cornerRadius=8
        self.hideKeyboardWhenTappedAround()
       
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
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
