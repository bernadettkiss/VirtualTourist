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
                imageView.image = nil
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func update(with image: UIImage?) {
        if let image = image {
            loading = false
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
    }
}
