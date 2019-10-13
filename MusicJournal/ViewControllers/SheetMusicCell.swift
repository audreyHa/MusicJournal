//
//  SheetMusicCell.swift
//  MusicJournal
//
//  Created by Audrey Ha on 10/7/19.
//  Copyright © 2019 MakeSchool. All rights reserved.
//

import UIKit

class SheetMusicCell: UICollectionViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var sheetMusicImageView: UIImageView!
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard let superView = self.superview as? UICollectionView else {return}

        var myIndexPath = superView.indexPath(for: self)
        UserDefaults.standard.set(myIndexPath!.row, forKey: "possiblyDeletePDFImageRow")
        print("possibly delete row: \(myIndexPath!.row)")
        
        NotificationCenter.default.post(name: Notification.Name("possiblyDeletePDFImage"), object: nil)
    }
    
}
