//
//  YesNoAlertVC.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class YesNoAlertVC: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var musiCordImage: UIImageView!
    @IBOutlet weak var wholeAlertView: UIView!
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var bigHeader: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigHeader.adjustsFontSizeToFitWidth = true
        label.adjustsFontSizeToFitWidth = true
        
        switch (UserDefaults.standard.string(forKey: "typeYesNoAlert")) {
        case "startOver":
            bigHeader.text="Are you sure you want to start over?"
            label.text="You cannot undo this action."
        case "delete":
            bigHeader.text="Are you sure you want to delete this recording?"
            label.text="You cannot undo this action."
        default:
            print("Error! Could not react to short alert!")
        }
        
        topView.layer.cornerRadius = 10
        topView.clipsToBounds = true
        
        bottomView.layer.cornerRadius = 10
        bottomView.clipsToBounds = true
        
        yesButton.layer.cornerRadius = 10
        yesButton.clipsToBounds = true
        
        noButton.layer.cornerRadius = 10
        noButton.clipsToBounds = true
        
        centerView.superview?.bringSubview(toFront: centerView)
        
        musiCordImage.superview?.bringSubview(toFront: musiCordImage)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        switch (UserDefaults.standard.string(forKey: "typeYesNoAlert")) {
        case "startOver":
            NotificationCenter.default.post(name: Notification.Name("startOver"), object: nil, userInfo: nil)
        case "delete":
            NotificationCenter.default.post(name: Notification.Name("delete"), object: nil, userInfo: nil)
        default:
            print("Error! Could not react to short alert!")
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func noPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
