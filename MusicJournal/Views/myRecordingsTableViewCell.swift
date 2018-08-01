//
//  RecordingsTableViewCell.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

//when you play after pausing, it doesn't pick up where it left off so fix that too. Still need recordings to stop when you leave in the middle of playing

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
    @IBOutlet weak var showTime: UILabel!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    
    var rowOfCellForRecording: Int = 0
    var newAudioPlayer: AVAudioPlayer!
    var pressPlayFile: String?
    var originalHours: Int16!
    var originalMinutes: Int16!
    var originalSeconds: Int16!
    var thisHours: Int16!
    var thisMinutes: Int16!
    var thisSeconds: Int16!
    var timer = Timer()
    var isPaused: Bool=false
    
    @IBAction func resetPressed(_ sender: Any) {
        timer.invalidate()
        thisHours=originalHours
        thisMinutes=originalMinutes
        thisSeconds=originalSeconds
        displaying()
        if originalSeconds != 0{
            thisSeconds=thisSeconds-1
        }else{
            thisMinutes = thisMinutes - 1
            thisSeconds = thisSeconds + 4
        }
        
        newAudioPlayer.stop()
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        if isPaused==false{
            isPaused=true
            timer.invalidate()
            displaying()
            if originalSeconds != 0{
                thisSeconds=thisSeconds-1
            }else{
                thisMinutes = thisMinutes - 1
                thisSeconds = thisSeconds + 4
            }
            newAudioPlayer.pause()
        }
        
    }
    
    
    @IBAction func playPressed(_ sender: Any) {
        if isPaused==false{//playing fresh, no pausing
            timer.invalidate()
            thisHours=originalHours
            thisMinutes=originalMinutes
            thisSeconds=originalSeconds
            displaying()
            if originalSeconds != 0{
                thisSeconds=thisSeconds-1
            }else{
                thisMinutes = thisMinutes - 1
                thisSeconds = thisSeconds + 4
            }
            do{
                let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                let newPlaying = fileManager!.appendingPathComponent("\(pressPlayFile!)")
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                
                newAudioPlayer = try AVAudioPlayer(contentsOf: newPlaying)
                
                newAudioPlayer.play()
                print("now playing")
                if (originalHours==0 && originalMinutes==0) && originalSeconds==0{
                    print("No recording available to countdown")
                }else{
                    timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(descendingAction), userInfo: nil, repeats: true)
                }
                
            } catch{
                
                print("Failed to play, keep trying....")
            }
        } else{ //unpausing
            isPaused=false
            if originalSeconds != 0{
                thisSeconds=thisSeconds-1
            }else{
                thisMinutes = thisMinutes - 1
                thisSeconds = thisSeconds + 4
            }
            
            newAudioPlayer.play()
            print("now playing")
            if (originalHours==0 && originalMinutes==0) && originalSeconds==0{
                print("No recording available to countdown")
            }else{
                timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(descendingAction), userInfo: nil, repeats: true)
            }
            
        }
        
    }
    
    @objc func descendingAction(){
        if originalSeconds==0{
            if (thisHours==originalHours && thisMinutes==originalMinutes) && thisSeconds==originalSeconds-1{
                
            }else if (thisHours==0 && thisMinutes==0) && thisSeconds==0{
                displaying()
                timer.invalidate()
            } else if thisMinutes==0 && thisSeconds==0{
                displaying()
                thisHours = thisHours - 1
                thisSeconds = thisSeconds + 4
                thisMinutes = thisMinutes + 4
            } else if thisSeconds==0{
                displaying()
                thisMinutes = thisMinutes - 1
                thisSeconds = thisSeconds + 4
            }else{
                displaying()
                thisSeconds = thisSeconds - 1
                
            }
        } else{
            if (thisHours==originalHours && thisMinutes==originalMinutes) && thisSeconds==originalSeconds{
                //            displaying()
                
            }else if (thisHours==0 && thisMinutes==0) && thisSeconds==0{
                displaying()
                timer.invalidate()
            } else if thisMinutes==0 && thisSeconds==0{
                displaying()
                thisHours = thisHours - 1
                thisSeconds = thisSeconds + 4
                thisMinutes = thisMinutes + 4
            } else if thisSeconds==0{
                displaying()
                thisMinutes = thisMinutes - 1
                thisSeconds = thisSeconds + 4
            }else{
                displaying()
                thisSeconds = thisSeconds - 1
                
            }
        }
    }
    
    func displaying(){
        
        if thisHours==0{
            if thisMinutes<10{
                if thisSeconds<10{
                    showTime.text = String("0\(thisHours!) : 0\(thisMinutes!) : 0\(thisSeconds!)")
                } else{
                    showTime.text = String("0\(thisHours!) : 0\(thisMinutes!) : \(thisSeconds!)")
                }
            } else{
                if thisSeconds<10{
                    showTime.text = String("0\(thisHours!) : \(thisMinutes!) : 0\(thisSeconds!)")
                } else{
                    showTime.text = String("0\(thisHours!) : \(thisMinutes!) : \(thisSeconds!)")
                }
            }
        } else{
            if thisMinutes<10{
                if thisSeconds<10{
                    showTime.text = String("\(thisHours!) : 0\(thisMinutes!) : 0\(thisSeconds!)")
                } else{
                    showTime.text = String("\(thisHours!) : 0\(thisMinutes!) : \(thisSeconds!)")
                }
            } else{
                if thisSeconds<10{
                    showTime.text = String("\(thisHours!) : \(thisMinutes!) : 0\(thisSeconds!)")
                } else{
                    showTime.text = String("\(thisHours!) : \(thisMinutes!) : \(thisSeconds!)")
                }
            }
        }
    }// end of function
}
