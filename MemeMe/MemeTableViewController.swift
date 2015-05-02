//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import UIKit
import CoreData

class MemeTableViewController: UITableViewController {

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
        self.tableView.reloadData()
     
    }
  
    
    @IBAction func addMeme(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the # of memes
        return self.memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell", forIndexPath: indexPath) as! UITableViewCell
        let meme = self.memes[indexPath.row]
        cell.textLabel?.text = meme.topText + "..." + meme.bottomText
        //cell.imageView?.image = meme.memedImage
        cell.imageView?.image = UIImage(data: meme.memedImageBin)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // show the details of the selected row
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as! MemeDetailViewController
        detailController.meme = self.memes[indexPath.row]
        // don't show the tabbar in the detailview
        detailController.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(detailController, animated: true)
   }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //delete the selected row from table and meme storage
        if editingStyle == UITableViewCellEditingStyle.Delete {
            memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  
            // update the central meme storage & coredata
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            sharedContext.deleteObject(appDelegate.memes.removeAtIndex(indexPath.row))
            CoreDataStackManager.sharedInstance().saveContext()
            
            // if we have removed all: return to the edit view
            if self.memes.count == 0 { self.dismissViewControllerAnimated(true, completion: nil) }
        }
    }
}
