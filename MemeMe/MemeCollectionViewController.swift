//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import Foundation
import UIKit


class MemeCollectionViewController: UICollectionViewController, UICollectionViewDataSource {

    var memes: [Meme]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // retrieve the memes stored in AppDelegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
    }

    
    
    @IBAction func AddMeme(sender: UIBarButtonItem) {
        // dismiss this viewcontroller and return to the edit
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return # of memes
        return self.memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as MemeCollectionViewCell
        let meme = self.memes[indexPath.item]
        cell.topText.text = meme.topText
        cell.memedImage.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // show the details of the selected meme
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as MemeDetailViewController
        detailController.meme = self.memes[indexPath.item]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
