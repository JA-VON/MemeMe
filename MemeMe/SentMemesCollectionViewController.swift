//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Javon Davis on 18/06/2017.
//  Copyright © 2017 Javon Davis. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SentMemeCollectionViewCell"

class SentMemesCollectionViewController: UICollectionViewController {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup CollectionView
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2*space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // Register cell classes
        self.collectionView?.register(UINib(nibName: "CustomMemeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
//        self.collectionView!.register(CustomMemeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier) // Don't use this if using UIElements from storyboard
    }

    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        
        self.collectionView?.reloadData()
        super.viewWillAppear(animated)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomMemeCollectionViewCell
        
        // first attempt at custom nib
//        let cell = Bundle.main.loadNibNamed("CustomMemeCollectionViewCell", owner: self, options: nil)?.first as! CustomMemeCollectionViewCell // first attribute needed to grab that view inside the xib
        
        let meme = memes[indexPath.row]
        
        cell.topLabel.text = meme.topText
        cell.bottomLabel.text = meme.bottomText
        cell.memeOriginalImageView.image = meme.originalImage
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetailFor(memeIndex: indexPath.row)
    }

}
