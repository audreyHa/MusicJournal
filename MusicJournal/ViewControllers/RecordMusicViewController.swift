//
//  RecordMusicViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class RecordMusicViewController: UIViewController{
    var recording: Recording?
    
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var composerText: UILabel!
    @IBOutlet weak var songText: UILabel!
    @IBOutlet weak var startNew: UIButton!
    
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
            
            destination.tableView.reloadData()
        
        case "save" where recording == nil:
            let recording = Recording()
            recording.songTitle=songLabel.text ?? ""
            recording.songEvent=eventLabel.text ?? ""
            recording.songComposer=composerLabel.text ?? ""
            recording.songDate=Date()
            destination.recordings.append(recording)
            
        case "cancel":
            print("cancel bar button item tapped")
        
        default:
            print("unexpected segue!")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.startNew.layer.cornerRadius=8
        self.songText.layer.cornerRadius=8
        self.composerText.layer.cornerRadius=8
        self.eventText.layer.cornerRadius=8
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
}
