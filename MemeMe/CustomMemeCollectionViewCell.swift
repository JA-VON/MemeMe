//
//  CustomMemeCollectionViewCell.swift
//  MemeMe
//
//  Created by Javon Davis on 19/06/2017.
//  Copyright © 2017 Javon Davis. All rights reserved.
//

import UIKit

class CustomMemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memeOriginalImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
