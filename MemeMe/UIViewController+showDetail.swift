//
//  File.swift
//  MemeMe
//
//  Created by Javon Davis on 19/06/2017.
//  Copyright © 2017 Javon Davis. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showDetailFor(memeIndex: Int) {
        
        let memeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        memeDetailViewController.memeIndex = memeIndex
        self.navigationController?.pushViewController(memeDetailViewController, animated: true)
    }
}
