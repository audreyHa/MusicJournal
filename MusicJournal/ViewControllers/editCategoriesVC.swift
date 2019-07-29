//
//  editCategoriesVC.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class editCategoriesVC: UIViewController {

    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var arrayOfRecordingsInfo = CoreDataHelper.retrieveRecording()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        var firstCategory=UserDefaults.standard.string(forKey: "1stCategory")
        var secondCategory=UserDefaults.standard.string(forKey: "2ndCategory")
        var thirdCategory=UserDefaults.standard.string(forKey: "3rdCategory")
        
        firstTextField.text=firstCategory!
        secondTextField.text=secondCategory!
        thirdTextField.text=thirdCategory!
        
        saveButton.layer.cornerRadius=8
        // Do any additional setup after loading the view.
    }
    
    func makeShortAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ShortAlertVC") as! ShortAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if (firstTextField.text != "")&&(secondTextField.text != "")&&(thirdTextField.text != ""){
            for recording in arrayOfRecordingsInfo{
                var firstCategory=UserDefaults.standard.string(forKey: "1stCategory")
                var noMessage = "No \(firstCategory!.capitalizingFirstLetter()) Entered"
                if recording.songTitle==noMessage{
                    recording.songTitle="No \(firstTextField.text!.capitalizingFirstLetter()) Entered"
                }
                
                var secondCategory=UserDefaults.standard.string(forKey: "2ndCategory")
                var noMessageTwo = "No \(secondCategory!.capitalizingFirstLetter()) Entered"
                if recording.songComposer==noMessageTwo{
                    recording.songComposer="No \(secondTextField.text!.capitalizingFirstLetter()) Entered"
                }
                
                var thirdCategory=UserDefaults.standard.string(forKey: "3rdCategory")
                var noMessageThree = "No \(thirdCategory!.capitalizingFirstLetter()) Entered"
                if recording.songEvent==noMessageThree{
                    recording.songEvent="No \(thirdTextField.text!.capitalizingFirstLetter()) Entered"
                }
                
                CoreDataHelper.saveRecording()
            }
            UserDefaults.standard.set(firstTextField.text,forKey: "1stCategory")
            
            UserDefaults.standard.set(secondTextField.text,forKey: "2ndCategory")
            
            UserDefaults.standard.set(thirdTextField.text,forKey: "3rdCategory")
            
            NotificationCenter.default.post(name: Notification.Name("updateCategoryButtons"), object: nil)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }else{
            UserDefaults.standard.set("fillAllCategories",forKey: "typeShortAlert")
            makeShortAlert()
        }
    }
    
}
