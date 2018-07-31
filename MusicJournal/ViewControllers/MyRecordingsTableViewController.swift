//
//  RecordingsTableViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit

class MyRecordingsTableViewController: UITableViewController{
    
    var arrayOfRecordingsInfo = [Recording](){
        didSet{
            myTableView.reloadData()
        }
    }
    
    @IBOutlet var myTableView: UITableView!
    
    static var chosenNumber: Int!
    static var firstCancel: Bool = false
    
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    
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
        
        cell.songTitle.text=currentRecording.songTitle
        
        if let thisDate = currentRecording.lastModified{
             cell.lastModified.text="Last Modified at \(thisDate.convertToString())"
        } else{
            cell.lastModified.text="No Date"
        }
        
        if let theDate=currentRecording.songDate{
            currentRecording.filename=theDate.convertToString().replacingOccurrences(of: ":", with: "").removingWhitespacesAndNewlines
        }
        if let theFilename = currentRecording.filename{
            cell.pressPlayFile = currentRecording.filename!.replacingOccurrences(of: ":", with: "").removingWhitespacesAndNewlines
        }
        
        
        let redColor = UIColor(red: 232/255, green: 90/255, blue: 69/255, alpha: 1)
        let lightBeigeBackground = UIColor(red: 234/255, green: 231/255, blue: 220/255, alpha: 1)
        let boldFont = UIFont.boldSystemFont(ofSize: 17.0)
        
        if currentRecording.filename==nil{
            cell.emptyLabel.textColor=redColor
        }else{
            cell.emptyLabel.textColor=lightBeigeBackground
        }
        
        if MyRecordingsTableViewController.chosenNumber==1{
            cell.songTitle.text=currentRecording.songTitle
            cell.lastModified.text=("Last Modified at: \(currentRecording.lastModified!.convertToString())")
            cell.songComposer.text=("Composer: \(currentRecording.songComposer!)")
            cell.songEvent.text=("Event: \(currentRecording.songEvent!)")

        } else if MyRecordingsTableViewController.chosenNumber==2{
            cell.songTitle.text=currentRecording.lastModified?.convertToString()
            cell.lastModified.text=("Title: \(currentRecording.songTitle!)")
            cell.songComposer.text=("Composer: \(currentRecording.songComposer!)")
            cell.songEvent.text=("Event: \(currentRecording.songEvent!)")
            
        } else if MyRecordingsTableViewController.chosenNumber==3{
            cell.songTitle.text=currentRecording.songComposer
            cell.lastModified.text=("Title: \(currentRecording.songTitle!)")
            cell.songComposer.text=("Last Modified at: \(currentRecording.lastModified!.convertToString())")
            cell.songEvent.text=("Event: \(currentRecording.songEvent!)")
            
        } else if MyRecordingsTableViewController.chosenNumber==4{
            cell.songTitle.text=currentRecording.songEvent
            cell.lastModified.text=("Title: \(currentRecording.songTitle!)")
            cell.songComposer.text=("Last Modified at: \(currentRecording.lastModified!.convertToString())")
            cell.songEvent.text=("Composer: \(currentRecording.songComposer!)")
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            
            // Got the following code from: swiftdeveloperblog.com/code-examples/delete-file-example-in-swift/
            // Find documents directory on device
            let fileSuffix="\(arrayOfRecordingsInfo[indexPath.row].filename!.replacingOccurrences(of: ":", with: "").removingWhitespacesAndNewlines).m4a"
            var filePath = ""
            
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/" + fileSuffix)
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
                    print("deleting works")
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            // End of code for deleting from the document directory also
            
            let recordingToDelete=arrayOfRecordingsInfo[indexPath.row]
            CoreDataHelper.deleteRecording(recording: recordingToDelete)
            arrayOfRecordingsInfo=CoreDataHelper.retrieveRecording()
            reorderArray()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier=segue.identifier else {return}

        switch identifier{
        case "displayMade":
            guard let indexPath=tableView.indexPathForSelectedRow else{return}
            let recording=arrayOfRecordingsInfo[indexPath.row]
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
                    if $0.songTitle != $1.songTitle{
                        return $0.songTitle! < $1.songTitle!
                    } else{
                        if $0.songComposer != $1.songComposer{
                            return $0.songComposer! < $1.songComposer!
                        } else{
                            if $0.songEvent != $1.songEvent{
                                return $0.songEvent! < $1.songEvent!
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
                    if $0.songComposer != $1.songComposer{
                        return $0.songComposer! < $1.songComposer!
                    } else{
                        if $0.songTitle != $1.songTitle{
                            return $0.songTitle! < $1.songTitle!
                        } else{
                            if $0.songEvent != $1.songEvent{
                                return $0.songEvent! < $1.songEvent!
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
                    if $0.songEvent != $1.songEvent{
                        return $0.songEvent! < $1.songEvent!
                    } else{
                        if $0.songTitle != $1.songTitle{
                            return $0.songTitle! < $1.songTitle!
                        } else{
                            if $0.songComposer != $1.songComposer{
                                return $0.songComposer! < $1.songComposer!
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
                    if $0.songTitle != $1.songTitle{
                        return $0.songTitle! < $1.songTitle!
                    } else{
                        if $0.songComposer != $1.songComposer{
                            return $0.songComposer! < $1.songComposer!
                        } else{
                            if $0.songEvent != $1.songEvent{
                                return $0.songEvent! < $1.songEvent!
                            } else{
                                return $0.lastModified?.compare($1.lastModified!) == .orderedDescending
                            }
                        }
                    }
                }
            }
        }
    } //end of Reorder
    
    
    
}
