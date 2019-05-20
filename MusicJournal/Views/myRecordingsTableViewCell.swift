//
//  RecordingsTableViewCell.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

// Still need recordings to stop when you leave in the middle of playing

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import Crashlytics

class myRecordingsTableViewCell: UITableViewCell{
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var songComposer: UILabel!
    @IBOutlet weak var songEvent: UILabel!
    @IBOutlet weak var showTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var surrounding: UIView!
    
    var totalTime: String!
    var rowOfCellForRecording: Int = 0
    var newAudioPlayer: AVAudioPlayer!
    var pressPlayFile: String?
    var originalHours: Double!
    var originalMinutes: Double!
    var originalSeconds: Double!
    var thisHours: Double!
    var thisMinutes: Double!
    var thisSeconds: Double!
    var timer = Timer()
    var onButtonTouched: ((UITableViewCell) -> Void)? = nil
    var onDeleteTouched: ((UITableViewCell) -> Void)? = nil
    var onPlayTouched: ((UITableViewCell) -> Void)? = nil
    let red = UIColor(red: 232/255, green: 90/255, blue: 69/255, alpha: 1)
    let white = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
   
    @IBAction func editPressed(_ sender: Any) {
        if newAudioPlayer != nil && newAudioPlayer.isPlaying==true{
            newAudioPlayer.stop()
            timer.invalidate()
            thisHours=0
            thisMinutes=0
            thisSeconds=0
        }
       
        editButton.isSelected = !editButton.isSelected
        onButtonTouched?(self)

    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if newAudioPlayer != nil && newAudioPlayer.isPlaying==true{
            newAudioPlayer.stop()
            timer.invalidate()
            thisHours=0
            thisMinutes=0
            thisSeconds=0
        }
        
        deleteButton.isSelected = !deleteButton.isSelected
        onDeleteTouched?(self)
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        if (pressPlayFile != nil){
            if newAudioPlayer != nil{
                if (newAudioPlayer.isPlaying==true){
                    timer.invalidate()
                    newAudioPlayer.pause()
                    if ((thisHours != originalHours && thisMinutes != originalMinutes) && thisSeconds != originalSeconds){
                        //Fixing how the invalidate timer makes it go one further
                        if thisSeconds != 59{
                            thisSeconds=thisSeconds - 1
                            displaying()
                        }
                        if thisSeconds==59 && thisMinutes != 59{
                            thisSeconds=thisSeconds+59
                            thisMinutes=thisMinutes-1
                            displaying()
                        }
                        if thisSeconds==59 && thisMinutes==59{
                            thisSeconds=thisSeconds+59
                            thisMinutes=thisMinutes+59
                            thisHours=thisHours-1
                            displaying()
                        }
                    }
                }else{
                    print("It should not do anything")
                }
            }
            }
      
        
        }
    
    
    @IBAction func playPressed(_ sender: Any) {
        playButton.isSelected = !playButton.isSelected
        onPlayTouched?(self)
        
        print("This is the press play file: \(pressPlayFile)")
        //playing fresh, no pausing
            displaying()
        
        if newAudioPlayer != nil && newAudioPlayer.isPlaying==true{
            print("DON'T DO ANYTHING")
            
        }else if newAudioPlayer != nil && newAudioPlayer.isPlaying==false{
            print("unpausing")
            do{
               
                timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ascendingAction), userInfo: nil, repeats: true)
                newAudioPlayer.play()
            }catch{
                print("Failed to play, keep trying....")
            }
            
        }else{
            print("went to else")
            do{
                if (pressPlayFile != nil){
                    Answers.logCustomEvent(withName: "Played Recording")
                    if (thisHours != 0 || thisMinutes != 0) || thisSeconds != 0{
                        timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ascendingAction), userInfo: nil, repeats: true)
                        newAudioPlayer.play()
                    }else{
                        let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                        let newPlaying = fileManager!.appendingPathComponent("\(pressPlayFile!)")
                        
                        
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                        
                        newAudioPlayer = try AVAudioPlayer(contentsOf: newPlaying)
                        
                        timer.invalidate()
                        thisHours=0
                        thisMinutes=0
                        thisSeconds=0
                        displaying()
                        timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ascendingAction), userInfo: nil, repeats: true)
                        newAudioPlayer.play()
                        
                    }
                    
                }
            }catch{
                print("Failed to play, keep trying....")
            }
        } 
    }//end of press play function
    
    var onExportTouched: ((UITableViewCell) -> Void)? = nil
    @IBAction func shareDoc(_ sender: Any) {
        if newAudioPlayer != nil && newAudioPlayer.isPlaying==true{
            newAudioPlayer.stop()
            timer.invalidate()
            thisHours=0
            thisMinutes=0
            thisSeconds=0
        }
        
        exportButton.isSelected = !exportButton.isSelected
        onExportTouched?(self)
    }
    
    
    @objc func ascendingAction(){
       
        if (thisHours==originalHours && thisMinutes==originalMinutes) && thisSeconds==originalSeconds{
            timer.invalidate()
            thisSeconds=0
            thisMinutes=0
            thisHours=0
        }else{
            thisSeconds = thisSeconds + 1
            if thisSeconds>59{ //more than 59 seconds
                displaying()
                thisSeconds=thisSeconds - 60
                thisMinutes=thisMinutes+1
            }
            
            if thisMinutes>59{
                displaying()
                thisMinutes=thisMinutes-60
                thisHours=thisHours+1
            }
            if thisSeconds<=59 && thisMinutes<=59{
                displaying()
            }
        }
    }
    
    func displaying(){
        
        if thisHours==0{
            if thisMinutes<10{
                if thisSeconds<10{
                    showTime.text = String("0\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : 0\(Int(thisSeconds!))")
                } else{
                    showTime.text = String("0\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : \(Int(thisSeconds!))")
                }
            } else{
                if thisSeconds<10{
                    showTime.text = String("0\(Int(thisHours!)) : \(Int(thisMinutes!)) : 0\(Int(thisSeconds!))")
                } else{
                    showTime.text = String("0\(Int(thisHours!)) : \(Int(thisMinutes!)) : \(Int(thisSeconds!))")
                }
            }
        } else{
            if thisMinutes<10{
                if thisSeconds<10{
                    showTime.text = String("\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : 0\(Int(thisSeconds!))")
                } else{
                    showTime.text = String("\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : \(Int(thisSeconds!))")
                }
            } else{
                if thisSeconds<10{
                    showTime.text = String("\(Int(thisHours!)) : \(Int(thisMinutes!)) : 0\(Int(thisSeconds!))")
                } else{
                    showTime.text = String("\(Int(thisHours!)) : \(Int(thisMinutes!)) : \(Int(thisSeconds!))")
                }
            }
        }
    }// end of function
    
}
