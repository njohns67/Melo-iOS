//
//  Song.swift
//  Melo
//
//  Created by Nathan Johnston on 11/11/19.
//  Copyright © 2019 Nathan Johnston. All rights reserved.
//

import Foundation

class Song{
    var title: String
    var artist: String
    var URI: String
    var imageURL: String
    
    init(title: String, artist: String, URI: String, imageURL: String){
        self.title = title
        self.artist = artist
        self.URI = URI
        self.imageURL = imageURL
    }
}
