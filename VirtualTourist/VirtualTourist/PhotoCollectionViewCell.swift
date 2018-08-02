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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
    }
    
    func configureCell(forPhoto photo: Photo) {
        if let image = UIImage(data: photo.image!) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
    }
}
