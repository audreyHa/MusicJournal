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

class myRecordingsTableViewCell: UITableViewCell{
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var songComposer: UILabel!
    @IBOutlet weak var songEvent: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var rowOfCellForRecording: Int = 0
    var newAudioPlayer: AVAudioPlayer!
    var pressPlayFile: String!
    
    
    @IBAction func playPressed(_ sender: Any) {
        
        do{
            var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var newPlaying = paths[0].appendingPathComponent("\(pressPlayFile).m4a")
            newAudioPlayer = try AVAudioPlayer(contentsOf: newPlaying)
            newAudioPlayer.play()
            
            
        } catch{
            print(pressPlayFile)
            print("Failed to play, keep trying....")
        }
    }
    //New comment
}
