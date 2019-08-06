//
//  CustomCategoryAlert.swift
//  MusicJournal
//
//  Created by Audrey Ha on 8/5/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class CustomCategoryAlert: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var musiCordImage: UIImageView!
    @IBOutlet weak var wholeAlertView: UIView!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var bigHeader: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigHeader.adjustsFontSizeToFitWidth = true
        okButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        self.hideKeyboardWhenTappedAround()
        
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
        if textField.text != ""{
            switch (UserDefaults.standard.string(forKey: "customType")) {
            case "1stCategory":
                UserDefaults.standard.set(textField.text,forKey: "1stCategory")
            case "2ndCategory":
                UserDefaults.standard.set(textField.text,forKey: "2ndCategory")
            case "3rdCategory":
                UserDefaults.standard.set(textField.text,forKey: "3rdCategory")
            default:
                print("shouldn't do anything!")
            }
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
}
