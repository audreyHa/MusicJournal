//
//  RecordingsTableViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class MyRecordingsTableViewController: UITableViewController{
    
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
   
    var eventArray = [String]()
    var recordings = [Recording](){
        didSet{
            tableView.reloadData()
        }
    }
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        self.songButton.layer.cornerRadius=8
        self.dateButton.layer.cornerRadius=8
        self.composerButton.layer.cornerRadius=8
        self.eventButton.layer.cornerRadius=8
//        let headerView=UIView()
//       headerView.backgroundColor = UIColor(red: 234/255, green: 231/255, blue: 220/255, alpha: 1)
//        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 210)
//
//        tableView.tableHeaderView = headerView
        
    }
    @IBAction func unwindToMyRecordings(_ segue: UIStoryboardSegue){
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return recordings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "myRecordingsTableViewCell", for: indexPath) as! myRecordingsTableViewCell
        let recording=recordings[indexPath.row]
       
        cell.songTitle.text=recording.songTitle
        cell.songDate.text=recording.songDate.convertToString()
        cell.songComposer.text=recording.songComposer
        cell.songEvent.text=recording.songEvent
        if cell.songTitle.text==""{
            cell.songTitle.text="No Title Entered"
        }
        if cell.songEvent.text==""{
            cell.songEvent.text="No Event Entered"
        }
        if cell.songComposer.text==""{
            cell.songComposer.text="No Composer Entered"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            recordings.remove(at: indexPath.row)
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier=segue.identifier else {return}
        
        switch identifier{
        case "displayMade":
            guard let indexPath=tableView.indexPathForSelectedRow else{return}
            
            let recording=recordings[indexPath.row]
            let destination=segue.destination as! RecordMusicViewController
            destination.recording=recording
        
        case "new":
            print("create note bar button item tapped")
        
        default:
            print("unexpected segue identifier")
            
        }
    }
}
