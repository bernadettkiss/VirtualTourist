//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var loading = true {
        didSet {
            if loading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        update(with: nil)
    }
    
    func update(with image: UIImage?) {
        if let image = image {
            loading = false
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        } else {
            loading = true
            imageView.image = nil
        }
    }
}
