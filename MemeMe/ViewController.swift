//
//  ViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Added CoreDate on 01/05/2015
//
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var imageToEdit: UIImageView!
    
    var newMedia = false
    var textEditable = false
    var moveKeyboard = false
    var straightToTab = false

    var memedImage: UIImage!
    
    var memes: [Meme]!
    
    // set the common text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        // default fontsize 40; with shrink to fit to minimum 26
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch the saved Memes
        memes = fetchAllMemes()
        // retrieve the memes stored in AppDelegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes = memes
        // if there are any go straight to the sent memes
        if self.memes.count > 0 {
            straightToTab = true
        }
        
        // prepare view for use
        initializeView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
         // check if camera is available on device
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable    (UIImagePickerControllerSourceType.Camera)
        
        // subcribe to notifications
        self.subscribeToKeyboardNotifications()
        
        if AppVariables.mustRefreshEdit {
            AppVariables.mustRefreshEdit = false
            initializeView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if straightToTab {
            straightToTab = false
            self.showMemesTabView()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe from notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func fetchAllMemes() -> [Meme] {
        let error: NSErrorPointer = nil
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        if error != nil {
            println("Error in fetchAllActors(): \(error)")
        }
        return results as! [Meme]
    }

    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        // generate a memed image
        memedImage = generateMemedImage()
        // define an instance of the ActivityViewController with a memedImage as an activity item
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = saveImage
        //  present the ActivityViewController
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func saveImage(activityType:String!, completed: Bool, returnedItems: [AnyObject]!, error: NSError!) {
        // create the meme object if the user didn't cancel
        if completed { let memeImage = Meme(topText: topText.text, bottomText: bottomText.text, originalImageBin: UIImageJPEGRepresentation(imageToEdit.image!,1), memedImageBin: UIImageJPEGRepresentation(memedImage,1), context:sharedContext)
            // Add it to the memes array in the Application Delegate
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(memeImage)
        
            //Save it to core data
            CoreDataStackManager.sharedInstance().saveContext()
            
            // show the Sent Memes
            showMemesTabView()
        }
    }
 
    
    @IBAction func cancelEditMeme(sender: UIBarButtonItem) {
        // show the sent memes in tabview
        showMemesTabView()
    }

    @IBAction func composeNewMeme(sender: AnyObject) {
        // Start new Meme; warn user changes to current Meme will be lost if one is being edited already
        if imageToEdit.image != nil {
            var composeAlert = UIAlertController(title: "Start a new Meme!", message: "All changes since last Share will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
            composeAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                // Start a new meme; initialize view
                self.initializeView()
            }))
            composeAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                //no action needed
            }))
            presentViewController(composeAlert, animated: true, completion: nil)
        }
    }
    
    func initializeView(){
        // set all to intitial state
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .Center
        topText.text = "TOP"
        topText.delegate = self
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = .Center
        bottomText.text = "BOTTOM"
        bottomText.delegate = self
        imageToEdit.image = nil
   }
    
    func showMemesTabView(){
        //present tabview
        var controller: UITabBarController
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("tabViewer") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func useCamera(sender: UIBarButtonItem) {
        // use the camera as source for the image
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        imagePickerController.allowsEditing = false
        newMedia = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func usePhotoAlbum(sender: UIBarButtonItem) {
        // start imagepicker
        let imagePickerController = UIImagePickerController()
        // self needs both UIImagePickerControllerDelegate and UINavigationControllerDelegate
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar so we have a clear view of the image
        navigationBar.hidden = true
        toolBar.hidden = true
        
        // this code take a snapshot of the picturearea only!
        UIGraphicsBeginImageContext(self.imageToEdit.frame.size)
            var ypos = self.imageToEdit.frame.origin.y
            var xpos = self.imageToEdit.frame.origin.x
            var rectangle = self.view.frame
            rectangle.origin.y = -ypos
            rectangle.origin.x = -xpos
            self.view.drawViewHierarchyInRect(rectangle, afterScreenUpdates: true)
            let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
       
        // Show toolbar and navbar
        navigationBar.hidden = false
        toolBar.hidden = false
    
        return memedImage
    }
   
    
    // Keyboard handling
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // move view if we want to (only for bottomtext)
        if moveKeyboard {self.view.frame.origin.y -= getKeyboardHeight(notification)}
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // return view to original position if it has moved
        if moveKeyboard {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        // get the height of the keyboard so we can shift the view up when it appears
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
    // delegate methods for UITextfield
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return textEditable
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        // make sure the view is only moved up when bottom text is edited
        moveKeyboard = (textField.tag == 1)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    // delegate methods for UIImageController
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            textEditable = true
            shareButton.enabled = true
            imageToEdit.image = image
            // save the new (original) image from the camera so the user can use it at a later stage by selecting it from the alnbum
            if (newMedia) { UIImageWriteToSavedPhotosAlbum(image, self, nil, nil) }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

