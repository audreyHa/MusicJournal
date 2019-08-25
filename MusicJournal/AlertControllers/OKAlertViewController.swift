//
//  OKAlertViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/19/19.
//  Copyright © 2019 Audrey Ha. All rights reserved.
//

import UIKit
import Firebase

class OKAlertViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var musiCordImage: UIImageView!
    @IBOutlet weak var wholeAlertView: UIView!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var bigHeader: UILabel!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigHeader.adjustsFontSizeToFitWidth = true
        label.adjustsFontSizeToFitWidth = true
        okButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        if(UserDefaults.standard.string(forKey: "typeOKAlert")=="Privacy Policy"){
            bigHeader.text="PRIVACY POLICY"
            label.text="By clicking “Continue” or continuing to use this app, you acknowledge that MusiCord incorporates Google Firebase Analytics to track how many times users land on different screens in order to improve user experience and guide development for future features. Any identifiable information (name, contact information, location) will not be collected. Your recordings are stored locally on your phone; no third party (including me) has access to your content in this app. If you have any questions, please contact musicordmobileapp@gmail.com!"
            
            okButton.setTitle("  Continue  ", for: .normal)
        }else if(UserDefaults.standard.string(forKey: "typeOKAlert")=="fillFirst"){
            bigHeader.text="ALERT"
            label.text="Please fill out the first category before moving on to the second."
            
            okButton.setTitle("  Ok  ", for: .normal)
        }
        
        topView.layer.cornerRadius = 10
        topView.clipsToBounds = true
        
        bottomView.layer.cornerRadius = 10
        bottomView.clipsToBounds = true
        
        okButton.layer.cornerRadius = 5
        okButton.clipsToBounds = true
        
        centerView.superview?.bringSubview(toFront: centerView)
        
        musiCordImage.superview?.bringSubview(toFront: musiCordImage)
    }
    
    @IBAction func okPressed(_ sender: Any) {
        if(UserDefaults.standard.string(forKey: "typeOKAlert")=="Privacy Policy"){
            //Post notification
            NotificationCenter.default.post(name: Notification.Name("privacyPressed"), object: nil)
            Analytics.logEvent("privacyPolicyPressed", parameters: nil)
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        

    }
}
