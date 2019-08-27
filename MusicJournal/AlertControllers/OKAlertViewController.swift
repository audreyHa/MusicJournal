//
//  OKAlertViewController.swift
//  MusicJournal
//
//  Created by Audrey Ha on 7/19/19.
//  Copyright © 2019 Audrey Ha. All rights reserved.
//

import UIKit
import Firebase

class OKAlertViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var musiCordImage: UIImageView!
    @IBOutlet weak var wholeAlertView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var bigHeader: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: privacyPolicyCell = tableView.dequeueReusableCell(withIdentifier: "privacyPolicyCell", for: indexPath) as! privacyPolicyCell
        
        cell.privacyPolicyTextView.text="MusiCord incorporates Google Analytics for Firebase or Firebase Analytics: an analytics service provided by Google LLC. In order to understand Google's use of Data, see Google's policy on “How Google uses data when you use our partners' sites or apps.”\n\nFirebase Analytics may share Data with other tools provided by Firebase, such as Crash Reporting, Authentication, Remote Config or Notifications.\n\nPersonal Data collected by MusiCord through Firebase:\nGeography/region\nUsage data\nNumber of users\nNumber of sessions\nSession duration\niPhone type\nApplication opens\nApplication updates\nFirst launches\n\nThe only purpose of MusiCord collecting user behavior data for this version is to improve user experience and guide development for the next release. If you do not wish to participate and help the app (and me) better understand your needs, you are always welcome to come back and install a later version.\n\nAll of your recordings are stored locally on your phone. No third party (including me!) has access to the recordings you store in this app.\n\nIf you have any questions, please feel free to contact me at musicordmobileapp@gmail.com!"
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.tableView.estimatedRowHeight=UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsSelection=false

        
        bigHeader.adjustsFontSizeToFitWidth = true
        okButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        if(UserDefaults.standard.string(forKey: "typeOKAlert")=="Privacy Policy"){
            bigHeader.text="PRIVACY POLICY"

            okButton.setTitle("  ACCEPT  ", for: .normal)
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
