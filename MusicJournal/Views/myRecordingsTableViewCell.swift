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
    @IBOutlet weak var songDate: UILabel!
    @IBOutlet weak var songComposer: UILabel!
    @IBOutlet weak var songEvent: UILabel!
    
    var rowOfCellForRecording: Int = 0
    var newAudioPlayer: AVAudioPlayer!
    var thisFilename: URL!
    
    @IBAction func playPressed(_ sender: Any) {
        
        
        do{
            newAudioPlayer = try AVAudioPlayer(contentsOf: thisFilename)
            newAudioPlayer.play()
        } catch{
            print("Something went wrong!!!")
        }
    }
    //New comment
}
