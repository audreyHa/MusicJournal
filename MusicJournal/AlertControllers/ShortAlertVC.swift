//
//  ShortAlertVC.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/20/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class ShortAlertVC: UIViewController {

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
        okButton.setTitle("  Ok  ", for: .normal)
        okButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        switch (UserDefaults.standard.string(forKey: "typeShortAlert")) {
        case "fillFirst":
            bigHeader.text="ALERT!"
            label.text="Please fill out the 1st category before moving on to the 2nd."
            okButton.setTitle("  Ok  ", for: .normal)
        case "fillSecond":
            bigHeader.text="ALERT!"
            label.text="Please fill out the 2nd category before moving on to the 3rd."
            okButton.setTitle("  Ok  ", for: .normal)
        case "fillThird":
            bigHeader.text="ALERT!"
            label.text="Please fill out the 3rd category before moving on."
        case "didAsFirst":
            bigHeader.text="ALERT!"
            var valueToUse=UserDefaults.standard.string(forKey: "valueToInclude")
            label.text="You already chose \(valueToUse!) as your 1st category. Please choose a different one!"
            okButton.setTitle("  Ok  ", for: .normal)
        case "didAsSecond":
            bigHeader.text="ALERT!"
            var valueToUse=UserDefaults.standard.string(forKey: "valueToInclude")
            label.text="You already chose \(valueToUse!) as your 2nd category. Please choose a different one!"
            okButton.setTitle("  Ok  ", for: .normal)
        case "didAsThird":
            bigHeader.text="ALERT!"
            var valueToUse=UserDefaults.standard.string(forKey: "valueToInclude")
            label.text="You already chose \(valueToUse!) as your 3rd category. Please choose a different one!"
            okButton.setTitle("  Ok  ", for: .normal)
        case "exporting":
            bigHeader.text="Cannot Export Recording"
            label.text="You did not make a recording here!"
            okButton.setTitle("  Ok  ", for: .normal)
        case "failToRecord":
            bigHeader.text="Failed to Record"
            label.text="Could not record."
        case "fillAllCategories":
            bigHeader.text="Please Fill All Categories!"
            label.text="Cannot save your edited categories if you leave one blank."
        default:
            print("Error! Could not react to short alert!")
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
        navigationController?.popViewController(animated: true)
        
        if(UserDefaults.standard.string(forKey: "typeShortAlert")=="fillFirst"){
            NotificationCenter.default.post(name: Notification.Name("fillFirst"), object: nil, userInfo: nil)
        }else if(UserDefaults.standard.string(forKey: "typeShortAlert")=="fillSecond"){
            NotificationCenter.default.post(name: Notification.Name("fillSecond"), object: nil, userInfo: nil)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
