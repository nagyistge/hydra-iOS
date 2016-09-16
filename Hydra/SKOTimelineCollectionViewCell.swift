//
//  SKOTimelineCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 16/09/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import FontAwesome_swift

class SKOTimelineCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var bodyText: UITextView?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var socialNetwork: UIView?

    var timelinePost: TimelinePost? {
        didSet {
            if let post = timelinePost {
                titleLabel?.text = post.title
                dateLabel?.text = SORelativeDateTransformer().transformedValue(post.date) as? String
                bodyText?.text = post.body
                if let media = post.media, let url = NSURL(string: media) where post.postType == .Photo {
                    imageView?.sd_setImageWithURL(url)
                    imageView?.hidden = false
                } else {
                    imageView?.hidden = true
                }

                if let poster = post.poster, let url = NSURL(string: poster) {
                    imageView?.sd_setImageWithURL(url)
                    imageView?.hidden = false
                } else {
                    imageView?.hidden = true
                }
            }
        }
    }
}