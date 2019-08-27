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
        
        cell.privacyPolicyTextView.text="By clicking continue or continuing to use this app, you acknowledge that:\n\nMusiCord incorporates Google Analytics for Firebase or Firebase Analytics: an analytics service provided by Google LLC. In order to understand Google's use of Data, see Google's policy on “How Google uses data when you use our partners' sites or apps.”\n\nFirebase Analytics may share Data with other tools provided by Firebase, such as Crash Reporting, Authentication, Remote Config or Notifications.\n\nPersonal Data collected by MusiCord through Firebase:\n\u{2022}Geography/region\n\u{2022}Usage data\n\u{2022}Number of users\n\u{2022}Number of sessions\n\u{2022}Session duration\n\u{2022}iPhone type\n\u{2022}Application opens\n\u{2022}Application updates\n\u{2022}First launches\n\nThe only purpose of MusiCord collecting user behavior data for this version is to improve user experience and guide development for the next release. If you do not wish to participate and help the app (and me) better understand your needs, you are always welcome to come back and install a later version.\n\nAll of your recordings are stored locally on your phone. No third party (including me!) has access to the recordings you store in this app.\n\nIf you have any questions, please feel free to contact me at musicordmobileapp@gmail.com!"
        
        let linkedText = NSMutableAttributedString(attributedString: cell.privacyPolicyTextView.attributedText)
        let hyperlinked = linkedText.setAsLink(textToFind: "“How Google uses data when you use our partners' sites or apps.”", linkURL: "https://policies.google.com/technologies/partner-sites")
        
        if hyperlinked {
            cell.privacyPolicyTextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight=UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsSelection=false

        
        bigHeader.adjustsFontSizeToFitWidth = true
        okButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        if(UserDefaults.standard.string(forKey: "typeOKAlert")=="Privacy Policy"){
            bigHeader.text="PRIVACY POLICY"

            okButton.setTitle("  Continue  ", for: .normal)
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

extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {

            self.addAttribute(.link, value: linkURL, range: foundRange)
            
            let multipleAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.backgroundColor: UIColor.yellow,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleSingle.rawValue ]
            
            self.addAttributes(multipleAttributes, range: foundRange)
            
            return true
        }
        return false
    }
}
