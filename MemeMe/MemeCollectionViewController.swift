//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class MemeCollectionViewController: UICollectionViewController, UICollectionViewDataSource {

    var memes: [Meme]!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        // make sure the edit view will be refreshed
        AppVariables.mustRefreshEdit = true
        
        // retrieve the memes stored in AppDelegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        self.collectionView?.reloadData()
    }
 
    
   func removeFromCollection(gestureRecognizer: UISwipeGestureRecognizer) {
        // get the path off the longpressed cell
        let location = gestureRecognizer.locationInView(self.collectionView)
        var indexPath: NSIndexPath? = self.collectionView?.indexPathForItemAtPoint(location)
    
        // warn the user of immenent delete
        var removeAlert = UIAlertController(title: "Remove Meme", message: "The selected meme will be permanently removed.", preferredStyle: UIAlertControllerStyle.Alert)
        removeAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            var indexpath = self.collectionView?.indexPathsForSelectedItems()
            // first remove it from the datasource (to prevent runtime error on difference in section count)
            self.memes.removeAtIndex(indexPath!.item)
            // now remove the item
            self.collectionView!.deleteItemsAtIndexPaths([indexPath!])
   
            // remove it also from the stored & core data
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            self.sharedContext.deleteObject(appDelegate.memes.removeAtIndex(indexPath!.item))
            CoreDataStackManager.sharedInstance().saveContext()
            
            // if we removed all the memes: return to the edit view
            if self.memes.count == 0 {self.dismissViewControllerAnimated(true, completion: nil)}
        }))
        removeAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            //no action needed
        }))
        presentViewController(removeAlert, animated: true, completion: nil)
    }
    
    @IBAction func AddMeme(sender: UIBarButtonItem) {
        // dismiss this viewcontroller and return to the edit view
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return # of memes
        return self.memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // fill the cells with available memes
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[indexPath.item]
        //cell.memedImage.image = meme.memedImage
        cell.memedImage.image = UIImage(data: meme.memedImageBin)
        
        // add longpressure recognizer to detect intention to delete the meme
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("removeFromCollection:"))
        cell.addGestureRecognizer(longPress)
      
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // show the details of the selected meme
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as! MemeDetailViewController
        detailController.meme = self.memes[indexPath.item]
        // don't show the tabbar in the detailview
        detailController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
