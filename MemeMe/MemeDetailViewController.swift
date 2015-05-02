//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

        
    @IBOutlet weak var memedImage: UIImageView!
    
    var meme: Meme!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.memedImage.image = meme.memedImage
        self.memedImage.image = UIImage(data: meme.memedImageBin)
    }
    
    /* No delete/edit actions here: would be overkill for such a small app */
}
