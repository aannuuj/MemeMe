//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by bhuvan on 05/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CustomMemeCell"

class SentMemesCollectionViewController: UICollectionViewController {

    // MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Properties
    fileprivate var memes: [Meme] {
        return MemeStorage.shared.memes
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    // MARK: Actions
    @IBAction func createMemedImage(_ sender: Any) {
        let memeEditorVC =  storyboard?.instantiateViewController(identifier: "MemeEditorViewController") as! MemeEditorViewController
        navigationController?.pushViewController(memeEditorVC, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension SentMemesCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)  as! CustomMemeCell
    
        // Configure the cell
        let meme = memes[indexPath.row]
        cell.memeImageView.image = meme.memedImage
    
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension SentMemesCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meme = memes[indexPath.row]
        let memeDetailVC = storyboard?.instantiateViewController(identifier: "MemeDetailViewController") as! MemeDetailViewController
        memeDetailVC.memedImage = meme.memedImage
        navigationController?.pushViewController(memeDetailVC, animated: true)
    }
}
