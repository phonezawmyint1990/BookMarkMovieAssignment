//
//  BookmarksMovieListCollectionViewCell.swift
//  movie-core-data
//
//  Created by Aung Ko Ko on 9/25/19.
//  Copyright © 2019 padc. All rights reserved.
//

import UIKit
import SDWebImage

class BookmarksMovieListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewMoviePoster : UIImageView!
    
    var data : MovieVO? {
        didSet {
            if let data = data {
                imageViewMoviePoster.sd_setImage(with: URL(string: "\(API.BASE_IMG_URL)\(data.poster_path ?? "")"), completed: nil)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var identifier : String {
        return String(describing: self)
    }
}
