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
import Firebase
import PDFKit

class MyRecordingsTableViewController: UITableViewController, UIDocumentInteractionControllerDelegate{
    
    var arrayOfRecordingsInfo = [Recording](){
        didSet{
            myTableView.reloadData()
        }
    }
    
    @IBOutlet var myTableView: UITableView!
    
    static var chosenNumber: Int!
    var controller = UIDocumentInteractionController()
    var redColor=UIColor(red: 0.91, green: 0.35, blue: 0.27, alpha: 1.00)
    
    @IBOutlet weak var songButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var composerButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    var newIndexPath: Int!
    var deleteIndexPath: Int!
    var myCells = [myRecordingsTableViewCell]()
    
    @IBAction func songButtonPressed(_ sender: Any) {
        customReorderToButton(myInteger: 1)
    }
    
    @IBAction func dateButtonPressed(_ sender: Any) {
        customReorderToButton(myInteger: 2)
    }
    
    @IBAction func composerButtonPressed(_ sender: Any) {
        customReorderToButton(myInteger: 3)
    }
    
    @IBAction func eventButtonPressed(_ sender: Any) {
        customReorderToButton(myInteger: 4)
    }
    
    func customReorderToButton(myInteger: Int){
        getAllCells()
        print("used get all cells for event button")
        
        if MyRecordingsTableViewController.chosenNumber != myInteger{
            Analytics.logEvent("reorderArray", parameters: nil)
            print("going to log analytics!")
        }
        
        MyRecordingsTableViewController.chosenNumber=myInteger
        
        UserDefaults.standard.set(MyRecordingsTableViewController.chosenNumber,forKey: "myNumber")
        reorderArray()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        myTableView.allowsSelection=false
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteRecording(notification:)), name: Notification.Name("delete"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCategoryButtons(notification:)), name: Notification.Name("updateCategoryButtons"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSheetMusic(notification:)), name: Notification.Name("showSheetMusic"), object: nil)
        
    }
    
    @objc func showSheetMusic(notification: Notification) {
        var allSheets=CoreDataHelper.retrieveSheetMusic()
        var myPDF=PDFDocument()
        
        for sheet in allSheets{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyhhmmss"
            var dateStringOriginal=dateFormatter.string(from: sheet.dateModified!)
            
            if dateStringOriginal==UserDefaults.standard.string(forKey: "sheetMusicDateString"){
                var sheetFilename=sheet.filename!
                myPDF=getPDFFile(correctFilename: "\(sheetFilename)")
                var correctData=myPDF.dataRepresentation()
                addPDFView(data: correctData!)
            }
        }
    }
    
    func getPDFFile(correctFilename: String)->PDFDocument{
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        var myPDF: PDFDocument?
        
        if let dirPath = paths.first{
            print("got to dirPath")
            let PDFURL = URL(fileURLWithPath: dirPath).appendingPathComponent("/\(correctFilename)")
            let correctPDF=PDFDocument(url: PDFURL)
            let correctData=correctPDF!.dataRepresentation()
            myPDF = PDFDocument(data: correctData!)
        }
        
        print("correct filename: \(correctFilename)")
        return myPDF!
    }
    
    func addPDFView(data: Data){
        let whiteBackground=UIView()
        whiteBackground.backgroundColor=UIColor.white
        whiteBackground.frame=CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        whiteBackground.tag=4321
        self.view.addSubview(whiteBackground)
        
        let pdfView = PDFView()

        // add pdfView to the view hierarchy and possibly add auto-layout constraints

        pdfView.document = PDFDocument(data: data)
        pdfView.frame=CGRect(x: 0, y: 35, width: self.view.frame.width, height: self.view.frame.height*0.8)
        pdfView.tag=1234
        self.view.addSubview(pdfView)
        
        //add close button to PDF so that user can close it
        let closeButton: UIButton = UIButton(frame: CGRect(x: 10, y: 10, width: 25, height: 25))
        closeButton.tag=1111
        closeButton.setImage(UIImage(imageLiteralResourceName: "closeIcon"), for: .normal)
        closeButton.addTarget(self, action: #selector(removePDFView), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }
    
    @objc func removePDFView(){
        if let viewWithTag = self.view.viewWithTag(1234) {
            viewWithTag.removeFromSuperview()
        }else{
            print("Don't remove this subview from superview")
        }
        
        if let viewWithTag = self.view.viewWithTag(4321) {
            viewWithTag.removeFromSuperview()
        }else{
            print("Don't remove this subview from superview")
        }
        
        if let viewWithTag = self.view.viewWithTag(1111) {
            viewWithTag.removeFromSuperview()
        }else{
            print("Don't remove this subview from superview")
        }
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
            button!.setTitle("  \(categoryNames[n].capitalizingFirstLetter())  ", for: .normal)
            button!.titleLabel!.adjustsFontSizeToFitWidth=true
        }
    }
    
    //Function for handling receiving notification
    @objc func deleteRecording(notification: Notification) {
        Analytics.logEvent("deleteRecording", parameters: nil)
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
        
        func orderToChosenNumber(firstString: String, secondString: String, thirdString: String, fourthString: String){
            cell.songTitle.text=firstString
            cell.lastModified.text=secondString
            cell.songComposer.text=thirdString
            cell.songEvent.text=fourthString
        }
        
        if MyRecordingsTableViewController.chosenNumber==1{
            orderToChosenNumber(firstString: currentRecording.songTitle!,
                                secondString: ("\(currentRecording.lastModified!.convertToString())"),
                                thirdString: ("\(currentRecording.songComposer!)"),
                                fourthString: ("\(currentRecording.songEvent!)"))
        } else if MyRecordingsTableViewController.chosenNumber==2{
            orderToChosenNumber(firstString: (currentRecording.lastModified?.convertToString())!,
                                secondString: ("\(currentRecording.songTitle!)"),
                                thirdString: ("\(currentRecording.songComposer!)"),
                                fourthString: ("\(currentRecording.songEvent!)"))
        } else if MyRecordingsTableViewController.chosenNumber==3{
            orderToChosenNumber(firstString: currentRecording.songComposer!,
                                secondString: ("\(currentRecording.songTitle!)"),
                                thirdString: ("\(currentRecording.lastModified!.convertToString())"),
                                fourthString: ("\(currentRecording.songEvent!)"))
        } else if MyRecordingsTableViewController.chosenNumber==4{
            orderToChosenNumber(firstString: currentRecording.songEvent!,
                                secondString: ("\(currentRecording.songTitle!)"),
                                thirdString: ("\(currentRecording.lastModified!.convertToString())"),
                                fourthString: ("\(currentRecording.songComposer!)"))
        }else{
            orderToChosenNumber(firstString: currentRecording.songTitle!,
            secondString: ("\(currentRecording.lastModified!.convertToString())"),
            thirdString: ("\(currentRecording.songComposer!)"),
            fourthString: ("\(currentRecording.songEvent!)"))
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

        var indicator = UIActivityIndicatorView()
        
        func activityIndicator() {
            indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            indicator.center = self.view.center
            self.view.addSubview(indicator)
        }
        
        cell.onExportTouched = { (theCell) in
            guard let indexPath = tableView.indexPath(for: theCell) else { return }
            if self.arrayOfRecordingsInfo[indexPath.row].filename != nil{
                
                self.controller.delegate = self
                self.controller.presentPreview(animated: true)
                
                //get the file name
                let dirPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let recordingName = self.arrayOfRecordingsInfo[indexPath.row].filename!
                let pathArray: [String] = [dirPath, recordingName]
                let filePathString: String = pathArray.joined(separator: "/")
                print("this is file Path String: \(filePathString)")
                
                self.controller = UIDocumentInteractionController(url: NSURL(fileURLWithPath: filePathString) as URL)
                
                activityIndicator()
                indicator.startAnimating()
                indicator.color=self.redColor
                indicator.backgroundColor = UIColor.white
                
                self.controller.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    indicator.stopAnimating()
                    indicator.hidesWhenStopped = true
                })
                
                Analytics.logEvent("exportingRecording", parameters: nil)
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
            
            //set the destination's sheet images to all the image files in documents directory using filenames in core data
            var allSheets=CoreDataHelper.retrieveSheetMusic()
            for sheet in allSheets{
                if sheet.dateModified==recording.lastModified{
                    var correctPDF=getPDFFile(correctFilename: sheet.filename!)
                    var arrayOfImages=[UIImage]()
                    
                    for int in 1...correctPDF.pageCount{
                        arrayOfImages.append(convertPDFPageToImage(page: int, filename: sheet.filename!))
                    }
                    
                    destination.sheetImages=arrayOfImages
                }
            }
            
            destination.titleToUse=recording.songTitle ?? ""
            destination.eventToUse=recording.songEvent ?? ""
            destination.composerToUse=recording.songComposer ?? ""
            destination.timeArray=[Int(recording.hours) ?? 0,Int(recording.minutes) ?? 0,Int(recording.seconds) ?? 0]
        case "new":
            print("create note bar button item tapped")

        default:
            print("unexpected segue identifier")

        }
    }
    
    func convertPDFPageToImage(page:Int, filename: String)->UIImage{
        var correctPDF=getPDFFile(correctFilename: filename)

        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent("\(filename)").path
            
            let pdfdata = try NSData(contentsOfFile: filePath, options: NSData.ReadingOptions.init(rawValue: 0))

            let pdfData = pdfdata as CFData
            let provider:CGDataProvider = CGDataProvider(data: pdfData)!
            let pdfDoc:CGPDFDocument = CGPDFDocument(provider)!
            print("page int: \(page)")
            print("pdf doc total pages: \(pdfDoc.numberOfPages)")
            let pdfPage:CGPDFPage = pdfDoc.page(at: page)!
            var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
            pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)

            print("\(pageRect.width) by \(pageRect.height)")

            UIGraphicsBeginImageContext(pageRect.size)
            let context:CGContext = UIGraphicsGetCurrentContext()!
            context.saveGState()
            context.translateBy(x: 0.0, y: pageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            context.drawPDFPage(pdfPage)
            context.restoreGState()
            let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return pdfImage
        }
        catch {
            print("error in trying to get the data from PDF url!")

            var placeHolderImage=UIImage(imageLiteralResourceName: "cameraIcon")
            return placeHolderImage
        }
    }
    
    func setButtonColors(correctButton: UIButton){
        let redColor = UIColor(red: 232/255, green: 90/255, blue: 69/255, alpha: 1)
        let white = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        correctButton.backgroundColor=white
        correctButton.setTitleColor(redColor, for: .normal)
        
        //reset other buttons
        var allButtons=[songButton, eventButton, composerButton, dateButton]
        for button in allButtons{
            if button != correctButton{
                button?.backgroundColor=redColor
                button!.setTitleColor(white, for: .normal)
            }
        }
    }
    
    func reorderArray(){
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
            MyRecordingsTableViewController.chosenNumber=number
        }
        
        setButtonColors(correctButton: songButton)
        
        if MyRecordingsTableViewController.chosenNumber==1{
            
            
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
            setButtonColors(correctButton: dateButton)
            
            if arrayOfRecordingsInfo.count>0{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM, yyyy" // yyyy-MM-dd"
                
                arrayOfRecordingsInfo = arrayOfRecordingsInfo.sorted(by: { $0.lastModified?.compare($1.lastModified!) == .orderedDescending})
            }
        } else if MyRecordingsTableViewController.chosenNumber==3{
            setButtonColors(correctButton: composerButton)
            
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
            setButtonColors(correctButton: eventButton)
            
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
            setButtonColors(correctButton: songButton)
            
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
        if self.arrayOfRecordingsInfo[self.deleteIndexPath].filename != nil{
            // Got the following code from: swiftdeveloperblog.com/code-examples/delete-file-example-in-swift/
            // Find documents directory on device
            
            let fileNameToDelete = ("\(self.arrayOfRecordingsInfo[self.deleteIndexPath].filename!)")
            deleteFromDocumentsDirectory(myFilename: fileNameToDelete)
        }
        
        //get correct recording object from core data
        let recordingToDelete=self.arrayOfRecordingsInfo[self.deleteIndexPath]
        
        //delete any sheets that have same date as recording object
        var allSheets=CoreDataHelper.retrieveSheetMusic()
        for sheet in allSheets{
            if sheet.dateModified==recordingToDelete.lastModified{
                deleteFromDocumentsDirectory(myFilename: sheet.filename!)
            }
        }
        
        //delete recording from core data and reorder array of recordings
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
