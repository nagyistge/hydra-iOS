//
//  HomeSpecialEventBasicCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 06/04/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

class HomeSpecialEventBasicCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var text: UILabel!

    override func awakeFromNib() {
        self.contentView.setShadow()
    }

    var specialEvent: SpecialEvent? {
        didSet {
            if let specialEvent = specialEvent {
                name.text = specialEvent.name
                text.text = specialEvent.simpleText
                image.sd_setImage(with: URL(string: specialEvent.image))
            }
        }
    }
}
