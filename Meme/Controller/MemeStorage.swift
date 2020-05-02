//
//  MemeStorage.swift
//  MemeMe
//
//  Created by bhuvan on 05/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class MemeStorage {
    
    /// Singleton instance.
    static let shared = MemeStorage()
    
    /// List of saved memes.
    var memes = [Meme]()
}
