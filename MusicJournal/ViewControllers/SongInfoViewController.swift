//
//  SongInfoViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class SongInfoViewController: UIViewController{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var composerLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!

    @IBOutlet weak var titleValue: UITextField!
    @IBOutlet weak var composerValue: UITextField!
    @IBOutlet weak var eventValue: UITextField!
    
    
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        self.titleLabel.layer.cornerRadius=8
        self.composerLabel.layer.cornerRadius=8
        self.eventLabel.layer.cornerRadius=8
        
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
}
