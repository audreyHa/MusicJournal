//
//  myRecordingsViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 MakeSchool. All rights reserved.
//

import Foundation
import UIKit



class OrganizationViewController: UIViewController{
    
    @IBOutlet weak var songTitle: UIButton!
    @IBOutlet weak var event: UIButton!
    @IBOutlet weak var composer: UIButton!
    @IBOutlet weak var date: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.songTitle.layer.cornerRadius=8
        self.event.layer.cornerRadius=8
        self.composer.layer.cornerRadius=8
        self.date.layer.cornerRadius=8
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
}
