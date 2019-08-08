//
//  Tutorial3.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/18/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class Tutorial3: UIViewController {

    @IBOutlet weak var song: UIButton!
    @IBOutlet weak var composer: UIButton!
    @IBOutlet weak var artist: UIButton!
    
    @IBOutlet weak var album: UIButton!
    @IBOutlet weak var event: UIButton!
    @IBOutlet weak var instrument: UIButton!
    
    @IBOutlet weak var interviewer: UIButton!
    @IBOutlet weak var interviewee: UIButton!
    @IBOutlet weak var custom: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsSubLabel: UILabel!
    
    @IBOutlet weak var fullStack: UIStackView!
    @IBOutlet weak var horizontalOne: UIStackView!
    @IBOutlet weak var horizontalTwo: UIStackView!
    @IBOutlet weak var horizontalThree: UIStackView!
    
    @IBOutlet weak var doneWidth: NSLayoutConstraint!
    @IBOutlet weak var doneHeight: NSLayoutConstraint!
    
    var buttons=[UIButton]()
    var stacks=[UIStackView]()
    var redColor=UIColor(red: 0.91, green: 0.35, blue: 0.27, alpha: 1.00)
    var greyColor=UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
    
    var firstCategory=String()
    var secondCategory=String()
    var thirdCategory=String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stacks=[fullStack, horizontalOne, horizontalTwo, horizontalThree]
        buttons=[song, composer, artist, album, event, instrument, interviewer, interviewee, custom]
        for button in buttons{
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.backgroundColor=greyColor
            button.titleLabel!.adjustsFontSizeToFitWidth = true
        }
        
        doneButton.layer.cornerRadius=10
        doneButton.clipsToBounds=true
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            for button in buttons{
                button.titleLabel!.font=UIFont.systemFont(ofSize: 20)
            }
            
            instructionsLabel.setSizeFont(sizeFont: 17)
            instructionsSubLabel.setSizeFont(sizeFont: 20)
            
            for stack in stacks{
                stack.spacing = 15
            }

        case .pad:
            for button in buttons{
                button.titleLabel!.font=UIFont.systemFont(ofSize: 30)
            }
            
            instructionsLabel.setSizeFont(sizeFont: 30)
            instructionsSubLabel.setSizeFont(sizeFont: 25)
            
            for stack in stacks{
                stack.spacing = 50
            }
            
            doneWidth.constant=120
            doneHeight.constant=80
            doneButton.titleLabel!.font=UIFont.systemFont(ofSize: 30)
        case .unspecified:
            print("Unspecified device shouldn't be the case")
        case .tv:
            print("TV shouldn't be the case")
        case .carPlay:
            print("Car Play shouldn't be the case")
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if(UserDefaults.standard.string(forKey: "3rdCategory") != nil){
            NotificationCenter.default.post(name: Notification.Name("updateCategoryButtons"), object: nil)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }else{
            UserDefaults.standard.set("fillThird",forKey: "typeShortAlert")
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
    
    override func viewDidAppear(_ animated: Bool) {
        for button in buttons{
            button.backgroundColor=greyColor
        }
        
        if (UserDefaults.standard.string(forKey: "1stCategory") != nil){
            firstCategory=UserDefaults.standard.string(forKey: "1stCategory")!
        }
        
        if (UserDefaults.standard.string(forKey: "2ndCategory") != nil){
            secondCategory=UserDefaults.standard.string(forKey: "2ndCategory")!
        }
        
        if (UserDefaults.standard.string(forKey: "3rdCategory") != nil){
            thirdCategory=UserDefaults.standard.string(forKey: "3rdCategory")!
            setButtonRed(value: thirdCategory)
        }
        
        if (UserDefaults.standard.string(forKey: "2ndCategory") == nil){
            UserDefaults.standard.set("fillSecond",forKey: "typeShortAlert")
            
            let vc = storyboard!.instantiateViewController(withIdentifier: "ShortAlertVC") as! ShortAlertVC
            var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
            vc.view.backgroundColor = transparentGrey
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: true, completion: nil)
        }
    }

    func setButtonRed(value: String){
        switch (value) {
        case ("Song Title"):
            song.backgroundColor=redColor
        case ("Composer"):
            composer.backgroundColor=redColor
        case ("Artist"):
            artist.backgroundColor=redColor
        case ("Album"):
            album.backgroundColor=redColor
        case ("Event"):
            event.backgroundColor=redColor
        case ("Instrument"):
            instrument.backgroundColor=redColor
        case ("Interviewer"):
            interviewer.backgroundColor=redColor
        case ("Interviewee"):
            interviewee.backgroundColor=redColor
        default:
            custom.backgroundColor=redColor
        }
    }
    
    func reactToButtonPressed(myButton: UIButton, title: String){
        if (firstCategory != title)&&(secondCategory != title){
            myButton.backgroundColor=redColor
            for button in buttons{
                if button != myButton{
                    button.backgroundColor=greyColor
                }
            }
            UserDefaults.standard.set(title, forKey: "3rdCategory")
        }else if(firstCategory==title){
            UserDefaults.standard.set("didAsFirst",forKey: "typeShortAlert")
            UserDefaults.standard.set(title,forKey: "valueToInclude")
            makeShortAlert()
        }else if(secondCategory==title){
            UserDefaults.standard.set("didAsSecond",forKey: "typeShortAlert")
            UserDefaults.standard.set(title,forKey: "valueToInclude")
            makeShortAlert()
        }
    }
   
    @IBAction func songPressed(_ sender: Any) {
        reactToButtonPressed(myButton: song, title: "Song Title")
    }
    
    @IBAction func composerPressed(_ sender: Any) {
        reactToButtonPressed(myButton: composer, title: "Composer")
    }
    
    @IBAction func artistPressed(_ sender: Any) {
        reactToButtonPressed(myButton: artist, title: "Artist")
    }
    
    @IBAction func albumPressed(_ sender: Any) {
        reactToButtonPressed(myButton: album, title: "Album")
    }
    
    @IBAction func eventPressed(_ sender: Any) {
        reactToButtonPressed(myButton: event, title: "Event")
    }
    
    @IBAction func instrumentPressed(_ sender: Any) {
        reactToButtonPressed(myButton: instrument, title: "Instrument")
    }
    
    @IBAction func interviewerPressed(_ sender: Any) {
        reactToButtonPressed(myButton: interviewer, title: "Interviewer")
    }
    
    @IBAction func intervieweePressed(_ sender: Any) {
        reactToButtonPressed(myButton: interviewee, title: "Interviewee")
    }
    
    func makeCustomAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "CustomCategoryAlert") as! CustomCategoryAlert
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }

    @IBAction func customPressed(_ sender: Any) {
        custom.backgroundColor=redColor
        for button in buttons{
            if button != custom{
                button.backgroundColor=greyColor
            }
        }
        
        UserDefaults.standard.set("3rdCategory",forKey: "customType")
        makeCustomAlert()
    }
    
}
