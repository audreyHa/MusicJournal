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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore{
            
            print("Not first launch.")
            
           
        }else{
            let alert = UIAlertController(title: "PRIVACY POLICY", message:"By clicking “Continue” or continuing to use this app, you acknowledge that MusiCord does not share your data or keep records of your data. You are the owner and the individual in control of all your data and recordings. If you have any questions, please contact musicordmobileapp@gmail.com.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            print("First time")
            
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

