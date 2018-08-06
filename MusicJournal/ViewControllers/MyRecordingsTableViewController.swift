//
//  RecordingsTableViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class MyRecordingsTableViewController: UITableViewController, UIDocumentInteractionControllerDelegate{
    
    var arrayOfRecordingsInfo = [Recording](){
        didSet{
            myTableView.reloadData()
        }
    }
    
    static var firstCancel: Bool = false
    
    @IBOutlet var myTableView: UITableView!
    
    static var chosenNumber: Int!
    var controller = UIDocumentInteractionController()
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    var newIndexPath: Int!
    var deleteIndexPath: Int!
    
    @IBAction func songButtonPressed(_ sender: Any) {
        MyRecordingsTableViewController.chosenNumber=1
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    @IBAction func dateButtonPressed(_ sender: Any) {
        MyRecordingsTableViewController.chosenNumber=2
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    @IBAction func composerButtonPressed(_ sender: Any) {
        MyRecordingsTableViewController.chosenNumber=3
       
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    @IBAction func eventButtonPressed(_ sender: Any) {
        MyRecordingsTableViewController.chosenNumber=4
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
   
    override func viewDidLoad(){
        super.viewDidLoad()
        
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        
        reorderArray()
        
        tableView.delegate=self
        tableView.dataSource=self
        self.songButton.layer.cornerRadius=8
        self.dateButton.layer.cornerRadius=8
        self.composerButton.layer.cornerRadius=8
        self.eventButton.layer.cornerRadius=8
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyRecordingsTableViewController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: RecordMusicViewController.recordingSession)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSessionInterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey])
                return }
        
        switch interruptionType {
        case .began:
            print("began")
            var cells = myTableView.visibleCells as? [myRecordingsTableViewCell]
            for cell in cells!{
                if cell.newAudioPlayer != nil{
                    if cell.newAudioPlayer.isPlaying==true{
                        cell.newAudioPlayer.pause()
                        cell.timer.invalidate()
                        myRecordingsTableViewCell.isPaused=true
                    }
                }
                
            }
        default :
            print("ended")
            var cells = myTableView.visibleCells as? [myRecordingsTableViewCell]
            for cell in cells!{
                if cell.newAudioPlayer != nil{
                    if cell.newAudioPlayer.isPlaying==true{
                        cell.newAudioPlayer.pause()
                        cell.timer.invalidate()
                        myRecordingsTableViewCell.isPaused=true
                    }
                }
            }
        }
    }
    
    @objc func appMovedToBackground() {
        var cells = myTableView.visibleCells as? [myRecordingsTableViewCell]
        for cell in cells!{
            
            cell.timer.invalidate()
            
            if cell.newAudioPlayer != nil{
                cell.newAudioPlayer.stop()
            }
        }
    }
    
    @IBAction func unwindToMyRecordingsSave(_ segue: UIStoryboardSegue){
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            MyRecordingsTableViewController.chosenNumber=number
        }
        reorderArray()
    }
    
    @IBAction func unwindToMyRecordingsCancel(_ segue: UIStoryboardSegue){
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        
        if MyRecordingsTableViewController.firstCancel==true{
            
            //find the most RECENT recording
            
            arrayOfRecordingsInfo = arrayOfRecordingsInfo.sorted(by: { $0.lastModified?.compare($1.lastModified!) == .orderedAscending})
            
            //Delete from the array
            if let recordingToCancelOut=arrayOfRecordingsInfo.last{
                CoreDataHelper.deleteRecording(recording: recordingToCancelOut)
                arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
            }
        }
    
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            MyRecordingsTableViewController.chosenNumber=number
        }
        reorderArray()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrayOfRecordingsInfo.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell=tableView.dequeueReusableCell(withIdentifier: "myRecordingsTableViewCell", for: indexPath) as! myRecordingsTableViewCell
        let currentRecording=arrayOfRecordingsInfo[indexPath.row]
        
            cell.timer.invalidate()
            cell.thisHours=0
            cell.thisMinutes=0
            cell.thisSeconds=0
        
        if cell.newAudioPlayer != nil{
            cell.newAudioPlayer.stop()
        }
        
        cell.surrounding.layer.cornerRadius=8
        cell.playButton.layer.cornerRadius=8
        cell.editButton.layer.cornerRadius=8
        cell.deleteButton.layer.cornerRadius=8
        cell.exportButton.layer.cornerRadius=8
        cell.songTitle.text=currentRecording.songTitle
        cell.pauseButton.layer.cornerRadius=8
        
        if let thisDate = currentRecording.lastModified{
            cell.lastModified.text="\(thisDate.convertToString())"
        } else{
            cell.lastModified.text="No Date"
        }
        
        
        if MyRecordingsTableViewController.chosenNumber==1{
            if currentRecording.songTitle != nil{
                cell.songTitle.text=currentRecording.songTitle
            }else{
                cell.songTitle.text="No title entered"
            }
            
            if currentRecording.lastModified != nil{
                cell.lastModified.text=("\(currentRecording.lastModified!.convertToString())")
            }else{
                cell.lastModified.text=Date().convertToString()
            }
            
            if currentRecording.songComposer != nil{
                cell.songComposer.text=("\(currentRecording.songComposer!)")
            }else{
                cell.songComposer.text="No composer entered"
            }
            
            if currentRecording.songEvent != nil{
                cell.songEvent.text=("\(currentRecording.songEvent!)")
            }else{
                cell.songEvent.text="No event entered"
            }
            
        } else if MyRecordingsTableViewController.chosenNumber==2{
            
            if currentRecording.songTitle != nil{
                cell.lastModified.text=("\(currentRecording.songTitle!)")
            }else{
                cell.lastModified.text="No title entered"
            }
            
            if currentRecording.lastModified != nil{
                cell.songTitle.text=currentRecording.lastModified?.convertToString()
            }else{
                cell.songTitle.text=Date().convertToString()
            }
            
            if currentRecording.songComposer != nil{
                cell.songComposer.text=("\(currentRecording.songComposer!)")
            }else{
                cell.songComposer.text="No composer entered"
            }
            
            if currentRecording.songEvent != nil{
                cell.songEvent.text=("\(currentRecording.songEvent!)")
            }else{
                cell.songEvent.text="No event entered"
            }
            
        } else if MyRecordingsTableViewController.chosenNumber==3{
            
            if currentRecording.songTitle != nil{
                cell.lastModified.text=("\(currentRecording.songTitle!)")
            }else{
                cell.lastModified.text="No title entered"
            }
            
            if currentRecording.lastModified != nil{
                cell.songComposer.text=("\(currentRecording.lastModified!.convertToString())")
            }else{
                cell.songComposer.text=Date().convertToString()
            }
            
            if currentRecording.songComposer != nil{
                cell.songTitle.text=currentRecording.songComposer
            }else{
                cell.songTitle.text="No composer entered"
            }
            
            if currentRecording.songEvent != nil{
                cell.songEvent.text=("\(currentRecording.songEvent!)")
            }else{
                cell.songEvent.text="No event entered"
            }
        } else if MyRecordingsTableViewController.chosenNumber==4{
            
            if currentRecording.songTitle != nil{
                cell.lastModified.text=("\(currentRecording.songTitle!)")
            }else{
                cell.lastModified.text="No title entered"
            }
            
            if currentRecording.lastModified != nil{
                 cell.songComposer.text=("\(currentRecording.lastModified!.convertToString())")
            }else{
                 cell.songComposer.text=Date().convertToString()
            }
            
            if currentRecording.songComposer != nil{
                cell.songEvent.text=("\(currentRecording.songComposer!)")
            }else{
                cell.songEvent.text="No composer entered"
            }
            
            if currentRecording.songEvent != nil{
                cell.songTitle.text=currentRecording.songEvent
            }else{
                cell.songTitle.text="No event entered"
            }
        }else{
            if currentRecording.songTitle != nil{
                cell.songTitle.text=currentRecording.songTitle
            }else{
                cell.songTitle.text="No title entered"
            }
            
            if currentRecording.lastModified != nil{
                cell.lastModified.text=("\(currentRecording.lastModified!.convertToString())")
            }else{
                cell.lastModified.text=Date().convertToString()
            }
            
            if currentRecording.songComposer != nil{
                cell.songComposer.text=("\(currentRecording.songComposer!)")
            }else{
                cell.songComposer.text="No composer entered"
            }
            
            if currentRecording.songEvent != nil{
                cell.songEvent.text=("\(currentRecording.songEvent!)")
            }else{
                cell.songEvent.text="No event entered"
            }
        }
        
        if let thing = currentRecording.filename{
            cell.pressPlayFile = currentRecording.filename!
        } else{
            cell.pressPlayFile = currentRecording.filename
        }
        
        var totalTime = ""
        if currentRecording.hours==0{
            if currentRecording.minutes<10{
                if currentRecording.seconds<10{
                    totalTime = String("0\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))")
                } else{
                    totalTime = String("0\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))")
                }
            } else{
                if currentRecording.seconds<10{
                    totalTime = String("0\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))")
                } else{
                   totalTime = String("0\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))")
                }
            }
        } else{
            if currentRecording.minutes<10{
                if currentRecording.seconds<10{
                    totalTime = String("\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))")
                } else{
                    totalTime = String("\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))")
                }
            } else{
                if currentRecording.seconds<10{
                    totalTime = String("\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))")
                } else{
                    totalTime = String("\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))")
                }
            }
        }
        
        cell.totalTime=totalTime
        
        if currentRecording.hours==0{
            if currentRecording.minutes<10{
                if currentRecording.seconds<10{
                    cell.showTime.text = String("0\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))/\(totalTime)")
                } else{
                    cell.showTime.text = String("0\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))/\(totalTime)")
                }
            } else{
                if currentRecording.seconds<10{
                    cell.showTime.text = String("0\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))/\(totalTime)")
                } else{
                    cell.showTime.text = String("0\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))/\(totalTime)")
                }
            }
        } else{
            if currentRecording.minutes<10{
                if currentRecording.seconds<10{
                    cell.showTime.text = String("\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))/\(totalTime)")
                } else{
                    cell.showTime.text = String("\(Int(currentRecording.hours)) : 0\(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))/\(totalTime)")
                }
            } else{
                if currentRecording.seconds<10{
                    cell.showTime.text = String("\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : 0\(Int(currentRecording.seconds))/\(totalTime)")
                } else{
                    cell.showTime.text = String("\(Int(currentRecording.hours)) : \(Int(currentRecording.minutes)) : \(Int(currentRecording.seconds))/\(totalTime)")
                }
            }
        }
        
        cell.originalHours=Double(currentRecording.hours)
        cell.originalMinutes=Double(currentRecording.minutes)
        cell.originalSeconds=Double(currentRecording.seconds)
//        cell.thisHours=currentRecording.hours
//        cell.thisMinutes=currentRecording.minutes
//        cell.thisSeconds=currentRecording.seconds
        
        cell.onButtonTouched = {(theCell) in
            guard let indexPath = tableView.indexPath(for: theCell) else{
                return
            }
      
            self.newIndexPath=indexPath.row
            
        }
        
        cell.onDeleteTouched = {(theCell) in
            guard let indexPath = tableView.indexPath(for: theCell) else{
                return
            }
            
            self.deleteIndexPath=indexPath.row
            self.createAlert(title: "Are you sure you want to delete this recording?", message: "You cannot undo this action")
        }
        
        

        cell.onExportTouched = { (theCell) in
            guard let indexPath = tableView.indexPath(for: theCell) else { return }
            if self.arrayOfRecordingsInfo[indexPath.row].filename != nil{
                
//            let activityItem = URL.init(fileURLWithPath: Bundle.main.path(forResource: "\(self.arrayOfRecordingsInfo[indexPath.row].songDate!.convertToString().removingWhitespacesAndNewlines)", ofType: "m4a")!)
//
//                let activityVC = UIActivityViewController(activityItems: [activityItem],applicationActivities: nil)
//                activityVC.popoverPresentationController?.sourceView = self.view
//
//                self.present(activityVC, animated: true, completion: nil)
                
                self.controller.delegate = self
                self.controller.presentPreview(animated: true)
                let dirPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let recordingName = self.arrayOfRecordingsInfo[indexPath.row].filename!
                let pathArray: [String] = [dirPath, recordingName]
                let filePathString: String = pathArray.joined(separator: "/")
                print("this is file Path String: \(filePathString)")
                self.controller = UIDocumentInteractionController(url: NSURL(fileURLWithPath: filePathString) as URL)
                self.controller.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
            
            }else{
                self.exportAlert(title: "Cannot Export Recording", message: "You did not make a recording here")
            }
        
        }
        
        
        
        return cell
        
    }//end of override func

    override func viewWillDisappear(_ animated: Bool) {
        var cells = myTableView.visibleCells as? [myRecordingsTableViewCell]
        for cell in cells!{
            cell.timer.invalidate()
            cell.thisHours=0
            cell.thisMinutes=0
            cell.thisSeconds=0
            
            if cell.newAudioPlayer != nil{
                cell.newAudioPlayer.stop()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier=segue.identifier else {return}

        switch identifier{
        case "displayMade":
            let recording=self.arrayOfRecordingsInfo[newIndexPath]
            let destination=segue.destination as! RecordMusicViewController
            destination.recording=recording
        case "new":
            print("create note bar button item tapped")

        default:
            print("unexpected segue identifier")

        }
    }
    
    func reorderArray(){
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            MyRecordingsTableViewController.chosenNumber=number
        }
        
        let redColor = UIColor(red: 232/255, green: 90/255, blue: 69/255, alpha: 1)
        let white = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        if MyRecordingsTableViewController.chosenNumber==1{
            songButton.backgroundColor=white
            songButton.setTitleColor(redColor, for: .normal)
            
            //reset other buttons
            eventButton.backgroundColor=redColor
            eventButton.setTitleColor(white, for: .normal)
            composerButton.backgroundColor=redColor
            composerButton.setTitleColor(white, for: .normal)
            dateButton.backgroundColor=redColor
            dateButton.setTitleColor(white, for: .normal)
            
            if arrayOfRecordingsInfo.count>0{
                arrayOfRecordingsInfo=arrayOfRecordingsInfo.sorted{
                    if $0.songTitle?.uppercased() != $1.songTitle?.uppercased(){
                        return $0.songTitle!.uppercased() < $1.songTitle!.uppercased()
                    } else{
                        if $0.songComposer?.uppercased() != $1.songComposer?.uppercased(){
                            return $0.songComposer!.uppercased() < $1.songComposer!.uppercased()
                        } else{
                            if $0.songEvent?.uppercased() != $1.songEvent?.uppercased(){
                                return $0.songEvent!.uppercased() < $1.songEvent!.uppercased()
                            } else{
                                return $0.lastModified?.compare($1.lastModified!) == .orderedDescending
                            }
                        }
                    }
                }
            }
            
        } else if MyRecordingsTableViewController.chosenNumber==2{
            dateButton.backgroundColor=white
            dateButton.setTitleColor(redColor, for: .normal)
            
            //reset other buttons
            eventButton.backgroundColor=redColor
            eventButton.setTitleColor(white, for: .normal)
            composerButton.backgroundColor=redColor
            composerButton.setTitleColor(white, for: .normal)
            songButton.backgroundColor=redColor
            songButton.setTitleColor(white, for: .normal)
            
            if arrayOfRecordingsInfo.count>0{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM, yyyy" // yyyy-MM-dd"
                
                arrayOfRecordingsInfo = arrayOfRecordingsInfo.sorted(by: { $0.lastModified?.compare($1.lastModified!) == .orderedDescending})
            }
        } else if MyRecordingsTableViewController.chosenNumber==3{
            composerButton.backgroundColor=white
            composerButton.setTitleColor(redColor, for: .normal)
            
            //reset other buttons
            eventButton.backgroundColor=redColor
            eventButton.setTitleColor(white, for: .normal)
            songButton.backgroundColor=redColor
            songButton.setTitleColor(white, for: .normal)
            dateButton.backgroundColor=redColor
            dateButton.setTitleColor(white, for: .normal)
            
            if arrayOfRecordingsInfo.count>0{
               
                arrayOfRecordingsInfo=arrayOfRecordingsInfo.sorted{
                    if $0.songComposer?.uppercased() != $1.songComposer?.uppercased(){
                        return $0.songComposer!.uppercased() < $1.songComposer!.uppercased()
                    } else{
                        if $0.songTitle?.uppercased() != $1.songTitle?.uppercased(){
                            return $0.songTitle!.uppercased() < $1.songTitle!.uppercased()
                        } else{
                            if $0.songEvent?.uppercased() != $1.songEvent?.uppercased(){
                                return $0.songEvent!.uppercased() < $1.songEvent!.uppercased()
                            } else{
                                return $0.lastModified?.compare($1.lastModified!) == .orderedDescending
                            }
                        }
                    }
                }
            }
            
        } else if MyRecordingsTableViewController.chosenNumber==4{
            eventButton.backgroundColor=white
            eventButton.setTitleColor(redColor, for: .normal)
            
            //reset other buttons
            songButton.backgroundColor=redColor
            songButton.setTitleColor(white, for: .normal)
            dateButton.backgroundColor=redColor
            dateButton.setTitleColor(white, for: .normal)
            composerButton.backgroundColor=redColor
            composerButton.setTitleColor(white, for: .normal)
            
            if arrayOfRecordingsInfo.count>0{
                arrayOfRecordingsInfo=arrayOfRecordingsInfo.sorted{
                    if $0.songEvent?.uppercased() != $1.songEvent?.uppercased(){
                        return $0.songEvent!.uppercased() < $1.songEvent!.uppercased()
                    } else{
                        if $0.songTitle?.uppercased() != $1.songTitle?.uppercased(){
                            return $0.songTitle!.uppercased() < $1.songTitle!.uppercased()
                        } else{
                            if $0.songComposer?.uppercased() != $1.songComposer?.uppercased(){
                                return $0.songComposer!.uppercased() < $1.songComposer!.uppercased()
                            } else{
                                return $0.lastModified?.compare($1.lastModified!) == .orderedDescending
                            }
                        }
                    }
                }
            }
        } else{
            songButton.backgroundColor=white
            songButton.setTitleColor(redColor, for: .normal)
            
            //reset other buttons
            eventButton.backgroundColor=redColor
            eventButton.setTitleColor(white, for: .normal)
            composerButton.backgroundColor=redColor
            composerButton.setTitleColor(white, for: .normal)
            dateButton.backgroundColor=redColor
            dateButton.setTitleColor(white, for: .normal)
            
            if arrayOfRecordingsInfo.count>0{
                arrayOfRecordingsInfo=arrayOfRecordingsInfo.sorted{
                    if $0.songTitle?.uppercased() != $1.songTitle?.uppercased(){
                        return $0.songTitle!.uppercased() < $1.songTitle!.uppercased()
                    } else{
                        if $0.songComposer?.uppercased() != $1.songComposer?.uppercased(){
                            return $0.songComposer!.uppercased() < $1.songComposer!.uppercased()
                        } else{
                            if $0.songEvent?.uppercased() != $1.songEvent?.uppercased(){
                                return $0.songEvent!.uppercased() < $1.songEvent!.uppercased()
                            } else{
                                return $0.lastModified?.compare($1.lastModified!) == .orderedDescending
                            }
                        }
                    }
                }
            }
        }
    } //end of Reorder
    
    func createAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            
            if self.arrayOfRecordingsInfo[self.deleteIndexPath].filename != nil{
                // Got the following code from: swiftdeveloperblog.com/code-examples/delete-file-example-in-swift/
                // Find documents directory on device
                
                let fileNameToDelete = ("\(self.arrayOfRecordingsInfo[self.deleteIndexPath].filename!)")
                var filePath = ""
                
                let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                
                if dirs.count > 0 {
                    let dir = dirs[0] //documents directory
                    filePath = dir.appendingFormat("/" + fileNameToDelete)
                    print("Local path = \(filePath)")
                    
                } else {
                    print("Could not find local directory to store file")
                    return
                }
                
                
                do {
                    let fileManager = FileManager.default
                    
                    // Check if file exists
                    if fileManager.fileExists(atPath: filePath) {
                        // Delete file
                        try fileManager.removeItem(atPath: filePath)
                    } else {
                        print("for deleting, File does not exist")
                    }
                    
                }
                catch let error as NSError {
                    print("An error took place: \(error)")
                }
                // End of code for deleting from the document directory also
            }
            
            let recordingToDelete=self.arrayOfRecordingsInfo[self.deleteIndexPath]
            CoreDataHelper.deleteRecording(recording: recordingToDelete)
            self.arrayOfRecordingsInfo=CoreDataHelper.retrieveRecording()
            self.reorderArray()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
            print("They did not want to delete")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func exportAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
