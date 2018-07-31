//
//  RecordingsTableViewCell.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class myRecordingsTableViewCell: UITableViewCell{
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var songComposer: UILabel!
    @IBOutlet weak var songEvent: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var rowOfCellForRecording: Int = 0
    var newAudioPlayer: AVAudioPlayer!
    var pressPlayFile: String?
    
//    let audioSession = AVAudioSession.sharedInstance()
    
    @IBAction func playPressed(_ sender: Any) {
        
        do{
            let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
            let newPlaying = fileManager!.appendingPathComponent("\(pressPlayFile!)")
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            
            newAudioPlayer = try AVAudioPlayer(contentsOf: newPlaying)
            
            newAudioPlayer.play()
            print("now playing")
            
        } catch{

            print("Failed to play, keep trying....")
        }
        
    }
    //New comment
}
