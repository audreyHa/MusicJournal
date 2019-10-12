//
//  ViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit


class HomeViewController: UIViewController {

    @IBOutlet weak var roundedButton: UIButton!
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.roundedButton.layer.cornerRadius=8
        
        //Receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("privacyPressed"), object: nil)
        
        var allRecordings=CoreDataHelper.retrieveRecording()
        for recording in allRecordings{
            if recording.songTitle==nil{
                recording.songTitle="Temporary title"
            }
            
            if recording.songEvent==nil{
                recording.songEvent="Temporary event"
            }
            
            if recording.songComposer==nil{
                recording.songComposer="Temporary composer"
            }
            
            CoreDataHelper.saveRecording()
        }
    }
    
    //Function for handling receiving notification
    @objc func methodOfReceivedNotification(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Change `2.0` to the desired number of seconds.
            self.performSegue(withIdentifier: "showSecondViewController", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore{
            print("Not first launch.")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Change `2.0` to the desired number of seconds.
                self.performSegue(withIdentifier: "showSecondViewController", sender: self)
            }
           
        }else{
            UserDefaults.standard.set("Privacy Policy",forKey: "typeOKAlert")
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "OKAlertViewController") as! OKAlertViewController
            var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
            vc.view.backgroundColor = transparentGrey
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
