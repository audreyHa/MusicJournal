//
//  Tutorial2.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/18/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class Tutorial2: UIViewController {

    @IBOutlet weak var song: UIButton!
    @IBOutlet weak var composer: UIButton!
    @IBOutlet weak var artist: UIButton!
    @IBOutlet weak var album: UIButton!
    @IBOutlet weak var event: UIButton!
    @IBOutlet weak var instrument: UIButton!
    @IBOutlet weak var interviewer: UIButton!
    @IBOutlet weak var interviewee: UIButton!
    @IBOutlet weak var custom: UIButton!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsSubLabel: UILabel!
    
    @IBOutlet weak var fullStack: UIStackView!
    
    var buttons=[UIButton]()
    var stacks=[UIStackView]()
    var redColor=UIColor(red: 0.91, green: 0.35, blue: 0.27, alpha: 1.00)
    var greyColor=UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
    
    var firstCategory=String()
    var secondCategory=String()
    var thirdCategory=String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        buttons=[song, composer, artist, album, event, instrument, interviewer, interviewee, custom]
        for button in buttons{
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.backgroundColor=greyColor
            button.titleLabel!.adjustsFontSizeToFitWidth = true
        }
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
            setButtonRed(value: secondCategory)
        }
        
        if (UserDefaults.standard.string(forKey: "3rdCategory") != nil){
            thirdCategory=UserDefaults.standard.string(forKey: "3rdCategory")!
        }
        
        if (UserDefaults.standard.string(forKey: "1stCategory") == nil){
            UserDefaults.standard.set("fillFirst",forKey: "typeShortAlert")
            
            makeShortAlert()
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
        if firstCategory==title{
            UserDefaults.standard.set("didAsFirst",forKey: "typeShortAlert")
            UserDefaults.standard.set(title,forKey: "valueToInclude")
            makeShortAlert()
        }else if(thirdCategory==title){
            UserDefaults.standard.set("didAsThird",forKey: "typeShortAlert")
            UserDefaults.standard.set(title,forKey: "valueToInclude")
            makeShortAlert()
        }else{
            myButton.backgroundColor=redColor
            for button in buttons{
                if button != myButton{
                    button.backgroundColor=greyColor
                }
            }
            UserDefaults.standard.set(title, forKey: "2ndCategory")
        }
    }
    
    func makeShortAlert(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "ShortAlertVC") as! ShortAlertVC
        var transparentGrey=UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.95)
        vc.view.backgroundColor = transparentGrey
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
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
        
        UserDefaults.standard.set("2ndCategory",forKey: "customType")
        makeCustomAlert()
    }
    
}
