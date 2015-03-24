//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {

    var memes: [Meme]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        memes = appDelegate.memes
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }

    
    
    @IBAction func addMeme(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell", forIndexPath: indexPath) as UITableViewCell
        let meme = self.memes[indexPath.row]
        
        cell.textLabel?.text = meme.topText + " " + meme.bottomText
        cell.imageView?.image = meme.memedImage
 
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // show the details of the selected row
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")! as MemeDetailViewController
        detailController.meme = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailController, animated: true)
   }
}
