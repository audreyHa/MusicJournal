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
import Crashlytics // If using Answers with Crashlytics

class MyRecordingsTableViewController: UITableViewController, UIDocumentInteractionControllerDelegate{
    
    var arrayOfRecordingsInfo = [Recording](){
        didSet{
            myTableView.reloadData()
        }
    }
    
    @IBOutlet var myTableView: UITableView!
    
    static var chosenNumber: Int!
    var controller = UIDocumentInteractionController()
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    var newIndexPath: Int!
    var deleteIndexPath: Int!
    var myCells = [myRecordingsTableViewCell]()
    
    @IBAction func songButtonPressed(_ sender: Any) {
        getAllCells()
        print("used get all cells for song button")
        MyRecordingsTableViewController.chosenNumber=1
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    @IBAction func dateButtonPressed(_ sender: Any) {
        getAllCells()
        print("used get all cells for date button")
        MyRecordingsTableViewController.chosenNumber=2
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    @IBAction func composerButtonPressed(_ sender: Any) {
        getAllCells()
        print("used get all cells for composer button")
        MyRecordingsTableViewController.chosenNumber=3
       
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    @IBAction func eventButtonPressed(_ sender: Any) {
        getAllCells()
        print("used get all cells for event button")
        MyRecordingsTableViewController.chosenNumber=4
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let hasChosenCategories=UserDefaults.standard.string(forKey: "3rdCategory")
        if hasChosenCategories == nil{
            let vc = storyboard!.instantiateViewController(withIdentifier: "pageViewController") as! PageTutorialViewController
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: true, completion: nil)
        }

        myCells=[]
        
        arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
        
        reorderArray()
        
        tableView.delegate=self
        tableView.dataSource=self
        
        updateCategoryButtons()
        
        dateButton.layer.cornerRadius=8

        self.tableView.rowHeight=UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight=1000
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyRecordingsTableViewController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: RecordMusicViewController.recordingSession)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("delete"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCategoryButtons(notification:)), name: Notification.Name("updateCategoryButtons"), object: nil)
    }
    
    func updateCategoryButtons(){
        arrayOfRecordingsInfo=CoreDataHelper.retrieveRecording()
        
        var firstCategory: String
        var secondCategory: String
        var thirdCategory: String
        
        if (UserDefaults.standard.string(forKey: "1stCategory")) != nil{
            firstCategory="  \(UserDefaults.standard.string(forKey: "1stCategory")!)  "
        }else{
            firstCategory = "  Song Title  "
        }
        
        if (UserDefaults.standard.string(forKey: "2ndCategory")) != nil{
            secondCategory="  \(UserDefaults.standard.string(forKey: "2ndCategory")!)  "
        }else{
            secondCategory = "  Composer  "
        }
        
        if (UserDefaults.standard.string(forKey: "3rdCategory")) != nil{
            thirdCategory="  \(UserDefaults.standard.string(forKey: "3rdCategory")!)  "
        }else{
            thirdCategory = "  Event  "
        }

        var categoryNames=[firstCategory, secondCategory, thirdCategory]
        var arrayOfButtons=[songButton, composerButton, eventButton]
        
        for n in 0...arrayOfButtons.count-1{
            print(categoryNames[n])
            var button=arrayOfButtons[n]
            button!.layer.cornerRadius=8
            button!.setTitle(categoryNames[n], for: .normal)
            button!.titleLabel!.adjustsFontSizeToFitWidth=true
        }
    }
    
    //Function for handling receiving notification
    @objc func methodOfReceivedNotification(notification: Notification) {
        deleteRecording()
    }
    
    @objc func updateCategoryButtons(notification: Notification) {
        updateCategoryButtons()
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSessionInterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey] as Any)
                return }
        
        switch interruptionType {
        case .began:
            print("began")
            getAllCells()
            print("used get all cells for interruption start")
           
        default :
            print("ended")
            getAllCells()
            print("used get all cells for interruption end")
        }
    }
    
    @objc func appMovedToBackground() {
        getAllCells()
        print("used get all cells for app moved to background")

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
        
        arrayOfRecordingsInfo = arrayOfRecordingsInfo.sorted(by: { $0.lastModified?.compare($1.lastModified!) == .orderedAscending})
        
        if arrayOfRecordingsInfo.last?.lastModified==nil{ //it's new or it was canceled
            if let recordingToCancelOut=arrayOfRecordingsInfo.last{
                CoreDataHelper.deleteRecording(recording: recordingToCancelOut)
                print("Deleting confirmed")
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
        
        cell.surrounding.layer.cornerRadius=8
        cell.playButton.layer.cornerRadius=8
        cell.editButton.layer.cornerRadius=8
        cell.deleteButton.layer.cornerRadius=8
        cell.exportButton.layer.cornerRadius=8
        cell.songTitle.text=currentRecording.songTitle
        cell.pauseButton.layer.cornerRadius=8
        
        if currentRecording.lastModified==nil{
            currentRecording.lastModified=Date()
        }
        
        if MyRecordingsTableViewController.chosenNumber==1{
            cell.songTitle.text=currentRecording.songTitle
            cell.lastModified.text=("\(currentRecording.lastModified!.convertToString())")
            cell.songComposer.text=("\(currentRecording.songComposer!)")
            cell.songEvent.text=("\(currentRecording.songEvent!)")
        } else if MyRecordingsTableViewController.chosenNumber==2{
            cell.lastModified.text=("\(currentRecording.songTitle!)")
            cell.songTitle.text=currentRecording.lastModified?.convertToString()
            cell.songComposer.text=("\(currentRecording.songComposer!)")
            cell.songEvent.text=("\(currentRecording.songEvent!)")
        } else if MyRecordingsTableViewController.chosenNumber==3{
            cell.lastModified.text=("\(currentRecording.songTitle!)")
            cell.songComposer.text=("\(currentRecording.lastModified!.convertToString())")
            cell.songTitle.text=currentRecording.songComposer
            cell.songEvent.text=("\(currentRecording.songEvent!)")
        } else if MyRecordingsTableViewController.chosenNumber==4{
            cell.lastModified.text=("\(currentRecording.songTitle!)")
            cell.songComposer.text=("\(currentRecording.lastModified!.convertToString())")
            cell.songEvent.text=("\(currentRecording.songComposer!)")
            cell.songTitle.text=currentRecording.songEvent
        }else{
            cell.songTitle.text=currentRecording.songTitle
            cell.lastModified.text=("\(currentRecording.lastModified!.convertToString())")
            cell.songComposer.text=("\(currentRecording.songComposer!)")
            cell.songEvent.text=("\(currentRecording.songEvent!)")
        }
    
        if currentRecording.filename != nil{
            cell.pressPlayFile = currentRecording.filename!
        }else{
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
        
        
        
        cell.slider.minimumTrackTintColor = .red
        cell.slider.setThumbImage(UIImage(named:"redPlayBar"), for: [])
        var totalSeconds=(Float(currentRecording.hours)*3600)+(Float(currentRecording.minutes)*60)+(Float(currentRecording.seconds))
        cell.slider.maximumValue=totalSeconds
        
        cell.originalHours=Double(currentRecording.hours)
        
        cell.originalMinutes=Double(currentRecording.minutes)
        
        cell.originalSeconds=Double(currentRecording.seconds)
        
        if cell.newAudioPlayer != nil && cell.newAudioPlayer.isPlaying==true{
            print("not changing any time values!!")
        }else if cell.newAudioPlayer != nil && cell.newAudioPlayer.isPlaying==false{
            print("not changing any time values!!")
        }else{
            cell.thisHours=cell.originalHours
            cell.thisMinutes=cell.originalMinutes
            cell.thisSeconds=cell.originalSeconds
            cell.showTime.text=totalTime
            cell.slider.value=0
        }
        
        cell.dateCreated=currentRecording.lastModified
        
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
            
            UserDefaults.standard.set("delete",forKey: "typeYesNoAlert")
            self.makeYesNoAlert()
        }

        cell.onExportTouched = { (theCell) in
            guard let indexPath = tableView.indexPath(for: theCell) else { return }
            if self.arrayOfRecordingsInfo[indexPath.row].filename != nil{
                
                self.controller.delegate = self
                self.controller.presentPreview(animated: true)
                let dirPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let recordingName = self.arrayOfRecordingsInfo[indexPath.row].filename!
                let pathArray: [String] = [dirPath, recordingName]
                let filePathString: String = pathArray.joined(separator: "/")
                print("this is file Path String: \(filePathString)")
                self.controller = UIDocumentInteractionController(url: NSURL(fileURLWithPath: filePathString) as URL)
                self.controller.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                Answers.logCustomEvent(withName: "Pressed Export")
            }else{
                UserDefaults.standard.set("exporting",forKey: "typeShortAlert")
                self.makeShortAlert()
            }
        
        }
        
        cell.onPlayTouched = {(theCell) in
            guard let indexPath = tableView.indexPath(for: theCell) else { return }
            self.stopPlayingAllCells(cellValue: cell)
            print("used stop playing for playing song")
            print("Index Path Row that we're playing: \(indexPath.row)")
        }
        

        if myCells.contains(cell){
            print("myCells contains this cell")
        }else{
            myCells.append(cell)
            
            
        }
        
        return cell
        
    }//end of override func

    func makeShortAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ShortAlertVC") as! ShortAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func makeYesNoAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "YesNoAlertVC") as! YesNoAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        getAllCells()
        print("used get all cells for view disappeared")
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
    
    func deleteRecording(){
        Answers.logCustomEvent(withName: "Deleted Recording")
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
    }
    
    func getAllCells(){
       

            for eachCell in myCells{
                eachCell.timer.invalidate()
                eachCell.thisHours=eachCell.originalHours
                eachCell.thisMinutes=eachCell.originalMinutes
                eachCell.thisSeconds=eachCell.originalSeconds
                eachCell.displaying()
                eachCell.slider.value=0
                
                if eachCell.newAudioPlayer != nil{
                    eachCell.newAudioPlayer=nil
                }
            }
    }
    
    func stopPlayingAllCells(cellValue: myRecordingsTableViewCell){

        for i in 0...myCells.count-1{

            if(myCells[i] != cellValue){
                if myCells[i].newAudioPlayer != nil{
                    myCells[i].newAudioPlayer.stop()
                    myCells[i].newAudioPlayer=nil
                }

                myCells[i].timer.invalidate()
                myCells[i].thisHours=myCells[i].originalHours
                myCells[i].thisMinutes=myCells[i].originalMinutes
                myCells[i].thisSeconds=myCells[i].originalSeconds
                myCells[i].displaying()
                myCells[i].slider.value=0
            }
        }
    }
    
}
