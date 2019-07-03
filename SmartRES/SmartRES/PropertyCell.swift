//
//  PropertyCell.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit

class PropertyCell: UICollectionViewCell {
    
    @IBOutlet weak var propertyCellView: UIImageView!
    
    override func awakeFromNib() {
        propertyCellView.contentMode = .scaleAspectFit
        self.contentView.sendSubviewToBack(propertyCellView)
    }
    
}
