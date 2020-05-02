//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by bhuvan on 05/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    
    // MARK: Properties
    internal var memedImage: UIImage!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        memeImageView.image = memedImage
    }
}
