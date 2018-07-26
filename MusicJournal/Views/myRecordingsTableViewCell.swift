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
    @IBOutlet weak var emptyLabel: UILabel!
    
    var rowOfCellForRecording: Int = 0
    var newAudioPlayer: AVAudioPlayer!
    var pressPlayFile: String!
    var isEmpty: Bool!
    
    
    @IBAction func playPressed(_ sender: Any) {
        if isEmpty == true{
            let redColor = UIColor(red: 232/255, green: 90/255, blue: 69/255, alpha: 1)
            emptyLabel.textColor=redColor
        } else{
            let lightBeigeBackground = UIColor(red: 234/255, green: 231/255, blue: 220/255, alpha: 1)
            emptyLabel.textColor=lightBeigeBackground
        }
        
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
