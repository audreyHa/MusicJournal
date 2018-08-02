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

class myRecordingsTableViewCell: UITableViewCell{
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var songComposer: UILabel!
    @IBOutlet weak var songEvent: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var showTime: UILabel!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
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
    var isPaused: Bool=false
    var isStart: Bool = true
    var onButtonTouched: ((UITableViewCell) -> Void)? = nil
    var onDeleteTouched: ((UITableViewCell) -> Void)? = nil
    
    @IBOutlet weak var editButton: UIButton!
    @IBAction func editPressed(_ sender: Any) {
        editButton.isSelected = !editButton.isSelected
        onButtonTouched?(self)
    }
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func deletePressed(_ sender: Any) {
        deleteButton.isSelected = !deleteButton.isSelected
        onDeleteTouched?(self)
    }
    
    
    
    @IBAction func resetPressed(_ sender: Any) {
        if (pressPlayFile != nil){
            timer.invalidate()
            
            thisHours=0
            thisMinutes=0
            thisSeconds=0
            displaying()
            
//            if originalSeconds != 0{
//                thisSeconds=thisSeconds+1
//            }else{
//                thisMinutes = thisMinutes + 1
//                thisSeconds = thisSeconds - 4
//            }
            
            newAudioPlayer.stop()
        }
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        if (pressPlayFile != nil){
            if isPaused==false{
                
                
                if (isStart==false){
                    isPaused=true
                    timer.invalidate()
                    newAudioPlayer.pause()
                }
                
                if ((thisHours != originalHours && thisMinutes != originalMinutes) && thisSeconds != originalSeconds)&&(isStart==false){
                    isPaused=true
                    //Fixing how the invalidate timer makes it go one further
                    if thisSeconds != 4{
                        thisSeconds=thisSeconds - 1
                        displaying()
                    }
                    if thisSeconds==4 && thisMinutes != 4{
                        thisSeconds=thisSeconds+4
                        thisMinutes=thisMinutes-1
                        displaying()
                    }
                    if thisSeconds==4 && thisMinutes==4{
                        thisSeconds=thisSeconds+4
                        thisMinutes=thisMinutes+4
                        thisHours=thisHours-1
                        displaying()
                    }
                }
            //
            }
        }
        
    }
    
    
    @IBAction func playPressed(_ sender: Any) {
        if isPaused==false{//playing fresh, no pausing
            isStart=false
            timer.invalidate()
            thisHours=0
            thisMinutes=0
            thisSeconds=0
            displaying()
            
//            if originalSeconds != 0{
//                thisSeconds=thisSeconds+1
//            }else{
//                thisMinutes = thisMinutes + 1
//                thisSeconds = thisSeconds - 4
//            }
            
            do{
                if (pressPlayFile != nil){
                    let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
                    let newPlaying = fileManager!.appendingPathComponent("\(pressPlayFile!)")
                    
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                    
                    newAudioPlayer = try AVAudioPlayer(contentsOf: newPlaying)
                    
                    newAudioPlayer.play()
                    print("now playing")
                    if (thisHours==originalHours && thisMinutes==originalMinutes) && thisSeconds==originalSeconds{
                        timer.invalidate()
                        thisHours=0
                        thisMinutes=0
                        thisSeconds=0
                        displaying()
                        
//                        if originalSeconds != 0{
//                            thisSeconds=thisSeconds+1
//                        }else{
//                            thisMinutes = thisMinutes + 1
//                            thisSeconds = thisSeconds - 4
//                        }
                    }else{
                        timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ascendingAction), userInfo: nil, repeats: true)
                    }
                }
                
            } catch{
                
                print("Failed to play, keep trying....")
            }
        } else{ //unpausing
            isPaused=false
            
            print("now playing")
            if (thisHours != originalHours || thisMinutes != originalMinutes) || thisSeconds != originalSeconds{
                timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ascendingAction), userInfo: nil, repeats: true)
                newAudioPlayer.play()
            }
        }//
        
    }//end of press play function
    
    @objc func ascendingAction(){
        if (thisHours==originalHours && thisMinutes==originalMinutes) && thisSeconds==originalSeconds{
            timer.invalidate()
            thisHours=0
            thisMinutes=0
            thisSeconds=0
        }else{
            thisSeconds = thisSeconds + 1
            if thisSeconds>4{ //more than 60 seconds
                displaying()
                thisSeconds=thisSeconds - 5
                thisMinutes=thisMinutes+1
            }
            
            if thisMinutes>4{
                displaying()
                thisMinutes=thisMinutes-5
                thisHours=thisHours+1
            }
            if thisSeconds<=4 && thisMinutes<=4{
                displaying()
            }
        }
    }
    
    @objc func descendingAction(){
        
//        if (thisHours==0 && thisMinutes==0) && thisSeconds==0{
//            thisHours=originalHours
//            thisMinutes=originalMinutes
//            thisSeconds=originalSeconds
//        }
        if originalSeconds==0{
            if (thisHours==0 && thisMinutes==0) && thisSeconds==0{
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
            if (thisHours==0 && thisMinutes==0) && thisSeconds==0{
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
    //
    
    
    
    func displaying(){
        
        if thisHours==0{
            if thisMinutes<10{
                if thisSeconds<10{
                    showTime.text = String("0\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : 0\(Int(thisSeconds!))/\(totalTime!)")
                } else{
                    showTime.text = String("0\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : \(Int(thisSeconds!))/\(totalTime!)")
                }
            } else{
                if thisSeconds<10{
                    showTime.text = String("0\(Int(thisHours!)) : \(Int(thisMinutes!)) : 0\(Int(thisSeconds!))/\(totalTime!)")
                } else{
                    showTime.text = String("0\(Int(thisHours!)) : \(Int(thisMinutes!)) : \(Int(thisSeconds!))/\(totalTime!)")
                }
            }
        } else{
            if thisMinutes<10{
                if thisSeconds<10{
                    showTime.text = String("\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : 0\(Int(thisSeconds!))/\(totalTime!)")
                } else{
                    showTime.text = String("\(Int(thisHours!)) : 0\(Int(thisMinutes!)) : \(Int(thisSeconds!))/\(totalTime!)")
                }
            } else{
                if thisSeconds<10{
                    showTime.text = String("\(Int(thisHours!)) : \(Int(thisMinutes!)) : 0\(Int(thisSeconds!))/\(totalTime!)")
                } else{
                    showTime.text = String("\(Int(thisHours!)) : \(Int(thisMinutes!)) : \(Int(thisSeconds!))/\(totalTime!)")
                }
            }
        }
    }// end of function
    
    
}
