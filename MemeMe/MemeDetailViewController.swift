//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Javon Davis on 18/06/2017.
//  Copyright © 2017 Javon Davis. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var memeImageView: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        memeImageView.image = meme.memedImage
    }
}
