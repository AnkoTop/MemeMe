//
//  ViewController.swift
//  MemeMe
//
//  Created by Anko Top on 24/03/15.
//  Copyright (c) 2015 Anko Top. All rights reserved.
//

import UIKit

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
    
    
    // set the common text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
        
    ]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .Center
        topText.text = "TOP"
        topText.delegate = self
        
        // easier to see in storyboard
        topText.backgroundColor = UIColor.clearColor()
        bottomText.backgroundColor = UIColor.clearColor()
        
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = .Center
        bottomText.text = "BOTTOM"
        bottomText.delegate = self

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         // check if camera is available on device
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable    (UIImagePickerControllerSourceType.Camera)
        // subcribe to notifications
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // unsubscribe from notifications
        self.unsubscribeFromKeyboardNotifications()
    }

    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        // generate a memed image
        var memedImage = generateMemedImage()
        // define an instance of the ActivityViewController with a memedImage as an activity item
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        //  present the ActivityViewController
        self.presentViewController(activityViewController, animated: true, completion: saveImage)

    }
    
    @IBAction func cancelEditMeme(sender: UIBarButtonItem) {
        var controller: UITabBarController
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("tabViewer") as UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func useCamera(sender: UIBarButtonItem) {
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
        
        // Hide toolbar and navbar
        navigationBar.hidden = true
        toolBar.hidden = true
    
        UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
            let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navigationBar.hidden = false
        toolBar.hidden = false
        
        // take a snapshot of the picturearea only!
//        UIGraphicsBeginImageContext(self.imageToEdit.frame.size)
//        var ypos = self.imageToEdit.frame.origin.y
//        var xpos = self.imageToEdit.frame.origin.x
//        var rectangle = self.view.frame
//        rectangle.origin.y = -ypos
//        rectangle.origin.x = -xpos
//        self.view.drawViewHierarchyInRect(rectangle, afterScreenUpdates: true)
//        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        return memedImage
    }

    
    func saveImage() {
        // first render the memedImag
        var memedImage = generateMemedImage()
        // create the meme object
        let memeImage = Meme(topText: topText.text, bottomText: bottomText.text, originalImage: imageToEdit.image!, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as AppDelegate
        appDelegate.memes.append(memeImage)
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
            self.view.frame.origin.y += getKeyboardHeight(notification)}
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue // of CGRect
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
            // save the new (original) image from the camera so the user can use it
            if (newMedia) { UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)}
            self.dismissViewControllerAnimated(true, completion: nil) }
    }
}

