//
//  Media.swift
//  URLSessionMPFD
//
//  Created by Sukumar Anup Sukumaran on 05/06/18.
//  Copyright © 2018 TechTonic. All rights reserved.
//

import UIKit


struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    
    // failable initilizer
    
    init?(withImage image: UIImage, forKey key: String) {
        
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "photo\(arc4random()).jpeg"
        
        guard let data = UIImageJPEGRepresentation(image, 0.7) else { return nil }
        self.data = data
        
    }
    
    
}
