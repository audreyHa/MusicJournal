//
//  RecordMusicViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/21/18.
//  Copyright © 2018 MakeSchool. All rights reserved.
//

import Foundation
import UIKit

class RecordMusicViewController: UIViewController{
    @IBOutlet weak var startNew: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.startNew.layer.cornerRadius=8
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
}
