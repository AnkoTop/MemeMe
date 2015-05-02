//
//  Meme.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Refactor for use of CoreDate on 01/05/15.
//
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Meme)

class Meme : NSManagedObject {
   
    @NSManaged var topText: String
    @NSManaged var bottomText: String
    @NSManaged var originalImageBin: NSData
    @NSManaged var memedImageBin: NSData
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init (topText: String, bottomText: String, originalImageBin: NSData, memedImageBin: NSData , context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Meme", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.topText = topText
        self.bottomText = bottomText
        //self.originalImage = originalImage
        //self.memedImage = memedImage
        //self.originalImageBin = UIImageJPEGRepresentation(originalImage, 1)
        self.originalImageBin = originalImageBin
        self.memedImageBin = memedImageBin
        //self.memedImageBin = UIImageJPEGRepresentation(memedImage, 1)
    }
    
}