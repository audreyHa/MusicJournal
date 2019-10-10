//
//  RecordMusicViewController.swift
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
import IRLDocumentScanner
import PDFKit

class RecordMusicViewController: UIViewController, AVAudioRecorderDelegate, IRLScannerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var sheetCollectionView: UICollectionView!
    
    static var recordingSession: AVAudioSession!
    var isPaused = Bool()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recording: Recording?

    var hasSegued = false
    var seconds = 100
    var hours = 100
    var minutes = 100
    static var timer=Timer()
    var countingTime=3
    var cancelOutArray = [String]()
    var deleteSaving = [String]()
    var titleArray = [String]()
    var eventArray = [String]()
    var compArray = [String]()
    var timeArray = [Int]()
    
    @IBOutlet weak var pauseRecording: UIButton!
    
    @IBOutlet weak var heightMultiplierConstraint: NSLayoutConstraint!
    
    func runTimer(){
        self.hours=0
        self.seconds = 0
        self.minutes=0
        RecordMusicViewController.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RecordMusicViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func getAlphaNumericValue(yourString: String) -> String{
        let unsafeChars = CharacterSet.alphanumerics.inverted  // Remove the .inverted to get the opposite result.
        
        let cleanChars  = yourString.components(separatedBy: unsafeChars).joined(separator: "")
        return cleanChars
    }
    
    func newRecord(){
        
        if self.recording == nil{
            self.recording = CoreDataHelper.newRecording()
        }
        
        if self.recording?.filename != nil && cancelOutArray.count==0{
            deleteSaving.append((self.recording?.filename!)!)
        }
        
        var finalString=""
        if songText.text != nil{
            var songTitle=songLabel.text!.removingWhitespacesAndNewlines
            songTitle=getAlphaNumericValue(yourString: songTitle)
            var datePortion="\((Date().convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: "_")))"
            finalString="\(songTitle)\(datePortion)"
        }else{
            finalString="\((Date().convertToString().removingWhitespacesAndNewlines.replacingOccurrences(of: ":", with: "_")))"
        }
        self.recording?.filename="\(finalString).m4a"
        self.cancelOutArray.append((self.recording?.filename)!)
        var filename: URL?
        
        let fileManager = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        
        
        filename = fileManager!.appendingPathComponent((self.recording?.filename)!)
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        do{
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            //                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            audioRecorder = try AVAudioRecorder(url: filename!, settings: settings)
            audioRecorder.delegate=self
            audioRecorder.record()
            startNewRecording.setTitle("  Stop  ", for: .normal)
        }
        catch{
            UserDefaults.standard.set("failToRecord",forKey: "typeShortAlert")
            makeShortAlert()
        }
    }
    
    func makeShortAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ShortAlertVC") as! ShortAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @objc func updateTimer(){
        
        if countingTime > 0{
            timeLabel.text="Starting in \(countingTime)"
            countingTime-=1
        }else{
            RecordMusicViewController.timer.invalidate()
            RecordMusicViewController.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecordMusicViewController.action), userInfo: nil, repeats: true)
            newRecord()
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
   
    @IBOutlet weak var startNewRecording: UIButton!
    @IBAction func startNewRecording(_ sender: Any) {
         RecordMusicViewController.timer.invalidate()
        if isPaused==true{
            startNewRecording.setTitle("  Stop  ", for: .normal)
            audioRecorder.record()
            isPaused=false
            RecordMusicViewController.timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RecordMusicViewController.action), userInfo: nil, repeats: true)
        }else if audioRecorder == nil{ //Starting a new one (not ending)
            
            if recording?.filename != nil{
                if cancelOutArray.count>0{
                    UserDefaults.standard.set("startOver",forKey: "typeYesNoAlert")
                    makeYesNoAlert()
                }else{
                    runTimer()
                }
            } else{
                runTimer()
            }

        } else{ //Stopping
            //Stop Audio Recording
            
            audioRecorder.stop()
            
            RecordMusicViewController.timer.invalidate()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)

        }
    }
    
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var composerText: UILabel!
    @IBOutlet weak var songText: UILabel!
    
    @IBOutlet weak var songLabel: UITextField!
    @IBOutlet weak var composerLabel: UITextField!
    @IBOutlet weak var eventLabel: UITextField!
    
    @IBAction func pauseRecordingPressed(_ sender: Any) {
        if audioRecorder != nil{
            audioRecorder.pause()
            RecordMusicViewController.timer.invalidate()
            isPaused=true
            startNewRecording.setTitle("  Continue  ", for: .normal)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        songLabel.text=recording?.songTitle
        eventLabel.text=recording?.songEvent
        composerLabel.text=recording?.songComposer
        
        if recording?.songTitle != nil{
            titleArray.append((recording?.songTitle)!)
        }
        
        if recording?.songComposer != nil{
            compArray.append((recording?.songComposer)!)
        }
        
        if recording?.songEvent != nil{
            eventArray.append((recording?.songEvent)!)
        }
        
        if recording?.hours != nil{
            timeArray.append(Int((recording?.hours)!))
            timeArray.append(Int((recording?.minutes)!))
            timeArray.append(Int((recording?.seconds)!))
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let identifier = segue.identifier,
            let destination=segue.destination as? MyRecordingsTableViewController
            else {return}
        
        switch identifier{
        case "save":
            var dateToUse=Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyhhmmss"
            
            var dateString=dateFormatter.string(from: dateToUse)
            
            if hours != 100 && minutes != 100 && seconds != 100{
                recording?.hours=Double(hours)
                recording?.minutes=Double(minutes)
                recording?.seconds=Double(seconds)
            }

            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if recording == nil{
                recording = CoreDataHelper.newRecording()
                Analytics.logEvent("savingNewRecording", parameters: nil)
                
            }else{
                Analytics.logEvent("reSavingRecording", parameters: nil)
                
                //get the PDF that has the same date as the recording. Delete it.
                deleteFromDocumentsDirectory(myFilename: "\(dateFormatter.string(from: recording!.lastModified!)).pdf")
            }
            
            //save current images into new PDF
            var newSheet=CoreDataHelper.newSheetMusic()
            newSheet.dateModified=dateToUse
            saveIntoPDF(filename: "\(dateString).pdf")
            newSheet.filename="\(dateString).pdf"
            
            if deleteSaving.count>0{
                for toBeDeleted in deleteSaving{
                    deleteFromDocumentsDirectory(myFilename: toBeDeleted)
                }
                
            }
            
            if cancelOutArray.count>1{
                everythingButLast()
            }
            
            if audioRecorder != nil{
                audioRecorder.stop()
                audioRecorder = nil
                startNewRecording.setTitle("  Start Over  ", for: .normal)
            }
            
            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if songLabel.text==""{
                var firstCategory=UserDefaults.standard.string(forKey: "1stCategory") ?? "Song Title"
                
                recording?.songTitle="No \(firstCategory.capitalizingFirstLetter()) Entered"
            }else{
                recording?.songTitle=songLabel.text
            }
            
            if eventLabel.text==""{
                var thirdCategory=UserDefaults.standard.string(forKey: "3rdCategory") ?? "Event"
                
                recording?.songEvent="No \(thirdCategory.capitalizingFirstLetter()) Entered"
            }else{
                recording?.songEvent=eventLabel.text
            }
            
            if composerLabel.text==""{
                var secondCategory=UserDefaults.standard.string(forKey: "2ndCategory") ?? "Composer"

                recording?.songComposer="No \(secondCategory.capitalizingFirstLetter()) Entered"
            }else{
                recording?.songComposer=composerLabel.text
            }
            
            recording?.lastModified=dateToUse
            
            CoreDataHelper.saveRecording()
            
            cancelOutArray=[]
            deleteSaving=[]
            titleArray=[]
            eventArray=[]
            compArray=[]
            timeArray=[]
            
        case "cancel":
            
            if audioRecorder != nil{
                audioRecorder.stop()
                RecordMusicViewController.timer.invalidate()
                audioRecorder = nil
                startNewRecording.setTitle("  Start Over  ", for: .normal)
            }
            
            RecordMusicViewController.timer.invalidate()
            countingTime=3
            
            if recording?.lastModified==nil{ //If it's the first round and hasn't been saved yet
                if recording==nil{
                    recording=CoreDataHelper.newRecording()
                }
                
                if cancelOutArray.count>0{
                    deleteEverything()
                }
                CoreDataHelper.saveRecording()
                Analytics.logEvent("cancelUnsavedRecording", parameters: nil)
            } else{
                if deleteSaving.count>0{
                    recording?.filename=deleteSaving[0]
                }
                
                recording?.songTitle=titleArray[0]
                recording?.songComposer=compArray[0]
                recording?.songEvent=eventArray[0]
                recording?.hours=Double(timeArray[0])
                recording?.minutes=Double(timeArray[1])
                recording?.seconds=Double(timeArray[2])
                
                if cancelOutArray.count>0{
                    deleteEverything()
                }
                
                cancelOutArray=[]
                deleteSaving=[]
                titleArray=[]
                eventArray=[]
                compArray=[]
                timeArray=[]
                CoreDataHelper.saveRecording()
                Analytics.logEvent("cancelSavedRecording", parameters: nil)
            }
         
        default:
            print("unexpected segue!")
        }
    }
    
    func saveImageToDocuments(myFilename: String, imageToSave: UIImage){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "\(myFilename).jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = UIImageJPEGRepresentation(imageToSave, 0.75),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    //scanning sheet music!
    var sheetImages: [UIImage]!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("sheet images count: \(sheetImages?.count)")
        
        if sheetImages==nil{
            return 0
        }else{
            return sheetImages!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)->UICollectionViewCell{
        let cell=sheetCollectionView.dequeueReusableCell(withReuseIdentifier: "SheetMusicCell", for: indexPath) as! SheetMusicCell
        
        if sheetImages != nil{
            var imageToResize=sheetImages![indexPath.row]
            imageToResize=self.resizeImage(image: imageToResize, targetSize: CGSize(width: (sheetCollectionView.frame.size.width-15)/2, height: (sheetCollectionView.frame.size.width-15)/2))
            cell.sheetMusicImageView.image=imageToResize
        }
        
        print("cell height: \(cell.frame.height)")
        print("image height: \(cell.sheetMusicImageView.frame.height)")
        
        cell.deleteButton.superview?.bringSubview(toFront: cell.deleteButton)
        cell.deleteButton.layer.cornerRadius=5
        
        return cell
    }
    
    
    @IBAction func scanPressed(_ sender: Any) {
        let scanner = IRLScannerViewController.standardCameraView(with: self)
        scanner.showControls = true
        scanner.showAutoFocusWhiteRectangle = true
        present(scanner, animated: true, completion: nil)
    }
    
    func pageSnapped(_ page_image: UIImage!, from controller: IRLScannerViewController!) {
        controller.dismiss(animated: true) { () -> Void in
            
            if self.sheetImages==nil{
                self.sheetImages=[page_image]
            }else{
                self.sheetImages.append(page_image)
            }
                
            print("array count: \(self.sheetImages.count)")
            
            DispatchQueue.main.async {
                self.sheetCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func viewAsPDF(_ sender: Any) {
        if self.sheetImages != nil && self.sheetImages.count>0{
            let pdfDocument = PDFDocument()
            var reversedArray=self.sheetImages.reversed()
            for sheetImage in reversedArray{
            // Load or create your UIImage
                var multiplyingFactor=self.view.frame.width/sheetImage.size.width
                let image = self.resizeImage(image: sheetImage, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.height))
                
                // Create a PDF page instance from your image
                let pdfPage = PDFPage(image: image)
                
                // Insert the PDF page into your document
                pdfDocument.insert(pdfPage!, at: 0)
            }

            // Get the raw data of your PDF document
            let data = pdfDocument.dataRepresentation()
            
            addPDFView(data: data!)
        }
    }
    
    
    func saveIntoPDF(filename: String){
        // Create an empty PDF document
        let pdfDocument = PDFDocument()
        
        if self.sheetImages != nil && self.sheetImages.count>0{
            var reversedSheets=self.sheetImages.reversed()
            
            for sheetImage in reversedSheets{
            // Load or create your UIImage
                var multiplyingFactor=self.view.frame.width/sheetImage.size.width
                let image = self.resizeImage(image: sheetImage, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.height))
                
                // Create a PDF page instance from your image
                let pdfPage = PDFPage(image: image)
                
                // Insert the PDF page into your document
                pdfDocument.insert(pdfPage!, at: 0)
            }

            // Get the raw data of your PDF document
            let data = pdfDocument.dataRepresentation()
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // choose a name for your PDF
            let fileName = "\(filename)"
            
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            // Save the data to the url
            try! data!.write(to: fileURL)
        }
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
        pdfView.frame=CGRect(x: 0, y: self.view.frame.height*0.13+30, width: self.view.frame.width, height: self.view.frame.height*0.75)
        pdfView.tag=1234
        self.view.addSubview(pdfView)

        //add close button to PDF so that user can close it
        let closeButton: UIButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.height*0.13, width: 25, height: 25))
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
    
    func didCancel(_ cameraView: IRLScannerViewController) {
        cameraView.dismiss(animated: true) {}
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        scanButton.layer.cornerRadius=8
        pdfButton.layer.cornerRadius=8
        pauseRecording.layer.cornerRadius=8
        startNewRecording.layer.cornerRadius=8
        startNewRecording.setTitle("  Start NEW  ", for: .normal)
        
        sheetCollectionView.delegate=self
        sheetCollectionView.dataSource=self
        sheetCollectionView.layer.cornerRadius=8
        
        var layout=sheetCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset=UIEdgeInsets(top: 8,left: 8,bottom: 8,right: 8)
        layout.minimumInteritemSpacing=8
        layout.itemSize=CGSize(width: (sheetCollectionView.frame.size.width-15)/2, height: (sheetCollectionView.frame.size.width-15)/2)
        
        if recording?.lastModified == nil{
            startNewRecording.setTitle("  Start NEW  ", for: .normal)
        } else{
            startNewRecording.setTitle("  Start Over  ", for: .normal)
        }
        //Setting up session
        RecordMusicViewController.recordingSession = AVAudioSession.sharedInstance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecordMusicViewController.handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: RecordMusicViewController.recordingSession)
            
        AVAudioSession.sharedInstance().requestRecordPermission {(hasPermission) in
            if hasPermission{
                print("Accepted!")
            }
        }
       
        songText.adjustsFontSizeToFitWidth=true
        composerText.adjustsFontSizeToFitWidth=true
        eventText.adjustsFontSizeToFitWidth=true
        updateCategoryButtons()
        
        self.hideKeyboardWhenTappedAround()
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("startOver"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.possiblyDeletePDFImage(notification:)), name: Notification.Name("possiblyDeletePDFImage"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.permanentlyDeletePDFImage), name: Notification.Name("permanentlyDeletePDFImage"), object: nil)
    }
    
    @objc func permanentlyDeletePDFImage(notification: Notification){
        sheetImages.remove(at: UserDefaults.standard.integer(forKey: "possiblyDeletePDFImage"))
        sheetCollectionView.reloadData()
    }
    
    @objc func possiblyDeletePDFImage(notification: Notification){
        UserDefaults.standard.set("possiblyDeletePDFImage",forKey: "typeYesNoAlert")
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "YesNoAlertVC") as! YesNoAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func updateCategoryButtons(){
        print("updating buttons from song info")
        var firstCategory="  \(UserDefaults.standard.string(forKey: "1stCategory")):  " ?? "Song"
        if (UserDefaults.standard.string(forKey: "1stCategory")) != nil{
            firstCategory="  \(UserDefaults.standard.string(forKey: "1stCategory")!):  "
        }else{
            firstCategory = "  Song Title:  "
        }
        
        var secondCategory="  \(UserDefaults.standard.string(forKey: "2ndCategory")):  " ?? "Composer"
        if (UserDefaults.standard.string(forKey: "2ndCategory")) != nil{
            secondCategory="  \(UserDefaults.standard.string(forKey: "2ndCategory")!):  "
        }else{
            secondCategory = "  Composer:  "
        }

        var thirdCategory="  \(UserDefaults.standard.string(forKey: "3rdCategory")):  " ?? "Event"
        if (UserDefaults.standard.string(forKey: "3rdCategory")) != nil{
            thirdCategory="  \(UserDefaults.standard.string(forKey: "3rdCategory")!):  "
        }else{
            thirdCategory = "  Event:  "
        }
        
        songText.text="  \(firstCategory.capitalizingFirstLetter())  "
        composerText.text="  \(secondCategory.capitalizingFirstLetter())  "
        eventText.text="  \(thirdCategory.capitalizingFirstLetter())  "
    }
    
    //Function for handling receiving notification
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.countingTime=3
        self.runTimer()
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
            if audioRecorder != nil{
                audioRecorder.stop()
            }
            
            RecordMusicViewController.timer.invalidate()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)
           
            
        default :
            if audioRecorder != nil{
                audioRecorder.stop()
            }
            
            RecordMusicViewController.timer.invalidate()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)
        }
    }
    
    @objc func appMovedToBackground() {
        if hours != 100 && minutes != 100 && seconds != 100{
            recording?.hours=Double(hours)
            recording?.minutes=Double(minutes)
            recording?.seconds=Double(seconds)
        }
        
        RecordMusicViewController.timer.invalidate()
        countingTime=3
        
        if recording == nil{
            recording = CoreDataHelper.newRecording()
        }
        
        if audioRecorder != nil{
            audioRecorder.stop()
            audioRecorder = nil
            startNewRecording.setTitle("  Start Over  ", for: .normal)
        }
        
        if songLabel.text==""{
            var firstCategory=UserDefaults.standard.string(forKey: "1stCategory") ?? "Song Title"
            recording?.songTitle="No \(firstCategory.capitalizingFirstLetter()) Entered"
        }else{
            recording?.songTitle=songLabel.text
        }
        
        if eventLabel.text==""{
            var thirdCategory=UserDefaults.standard.string(forKey: "3rdCategory") ?? "Event"
            recording?.songEvent="No \(thirdCategory.capitalizingFirstLetter()) Entered"
        }else{
            recording?.songEvent=eventLabel.text
        }
        
        if composerLabel.text==""{
            var secondCategory=UserDefaults.standard.string(forKey: "2ndCategory") ?? "Composer"
            recording?.songComposer="No \(secondCategory.capitalizingFirstLetter()) Entered"
        }else{
            recording?.songComposer=composerLabel.text
        }
        
        CoreDataHelper.saveRecording()
        
    } //end of function
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    //Gets path to directory
    func getDirectory() -> URL{
        
        var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }

    @objc func action(){
        seconds+=1
        if seconds>59{ //more than 60 seconds
            displaying()
            seconds-=60
            minutes+=1
        }
        
        if minutes>59{
            displaying()
            minutes-=60
            hours+=1
        }
        if minutes<=59 && seconds<=59{
            displaying()
        }
        
        
    }
    //func displaying
    func displaying(){
        if hours==0{
            if minutes<10{
                if seconds<10{
                    timeLabel.text = String("0\(hours) : 0\(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("0\(hours) : 0\(minutes) : \(seconds)")
                }
            } else{
                if seconds<10{
                    timeLabel.text = String("0\(hours) : \(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("0\(hours) : \(minutes) : \(seconds)")
                }
            }
        } else{
            if minutes<10{
                if seconds<10{
                    timeLabel.text = String("\(hours) : 0\(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("\(hours) : 0\(minutes) : \(seconds)")
                }
            } else{
                if seconds<10{
                    timeLabel.text = String("\(hours) : \(minutes) : 0\(seconds)")
                } else{
                    timeLabel.text = String("\(hours) : \(minutes) : \(seconds)")
                }
            }
        }
    }
    //functions for deleting old recordings
    
    func everythingButLast(){
        for index in 0...cancelOutArray.count-2{
            var differentEachDate: String?
            differentEachDate = cancelOutArray[index]
            let new = differentEachDate!
            var filePath = ""
            
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/\(new)")
                
                
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
                    print("it works")
                } else {
                    print("For everything but last file does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
    
    func deleteEverything(){
        
        for eachDate in cancelOutArray{
            
            var filePath = ""
            let differentDeleting: String?
            var differentEachDate: String?
            differentEachDate = eachDate
            let new = differentEachDate!
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            
            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/\(new)")
                print("This is the filePath: \(filePath)")
                
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
                    print("it works")
                } else {
                    print("File does not exist for delete everything")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
    
    func makeYesNoAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "YesNoAlertVC") as! YesNoAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
} //end of class

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func deleteFromDocumentsDirectory(myFilename: String){
        var filePath = ""
        
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/" + myFilename)
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
                print("got original to be deleted")
            } else {
                print("File does not exist for deleting")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
}

extension String {
    var removingWhitespacesAndNewlines: String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    func capitalizingFirstLetter() -> String{
        var stringArray=self.characters.split(separator: " ")
        for n in 0...stringArray.count-1{
            stringArray[n]=stringArray[n].prefix(1).uppercased() + stringArray[n].lowercased().dropFirst()
        }
        
        var combinedString=stringArray.joined(separator: " ")
        return combinedString
    }
}
