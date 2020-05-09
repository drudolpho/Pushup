//
//  Instruction2CollectionViewCell.swift
//  Pushup
//
//  Created by Dennis Rudolph on 5/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class Instruction2CollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
       super.awakeFromNib()
       //custom logic goes here
        self.backgroundColor = .white
        self.layer.cornerRadius = 40
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}
