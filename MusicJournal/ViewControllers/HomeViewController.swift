//
//  ViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 Audrey Ha. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics


class HomeViewController: UIViewController {

    @IBOutlet weak var roundedButton: UIButton!
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.roundedButton.layer.cornerRadius=8
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore{
            
            print("Not first launch.")
            
           
        }else{
            let alert = UIAlertController(title: "PRIVACY POLICY", message:"By clicking “Continue” or continuing to use this app, you acknowledge that MusiCord incorporates an analytical tool (Answers) tracking how many times users land on different screens to improve user experience and guide development for future features. Any identifiable information (name, contact information, location) will not be collected. Your recordings are stored locally on your phone; no third party (including me) has access to your content in this app. If you have any questions, please contact musicordmobileapp@gmail.com!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            print("First time")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            Answers.logCustomEvent(withName: "Privacy Policy: Clicked Continue")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

