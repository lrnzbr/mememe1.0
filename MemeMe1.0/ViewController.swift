//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Lorenzo Brown on 6/5/17.
//  Copyright © 2017 Lorenzo Brown. All rights reserved.
//

import UIKit
import CoreData

    class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate
    {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 48)!,
            NSStrokeWidthAttributeName : -3.0
        ] as [String : Any]
        
        
        @IBOutlet weak var toolBar: UIToolbar!
        @IBOutlet weak var cancelButton: UIBarButtonItem!
        @IBOutlet weak var shareButton: UIBarButtonItem!
        @IBOutlet weak var imagePickerView: UIImageView!
        @IBOutlet weak var cameraButton: UIBarButtonItem!
        
  
        @IBOutlet weak var topText: UITextField!
        @IBOutlet weak var bottomText: UITextField!
        
        var DEFAULT_TOP_TEXT:String="TOP";
        var DEFAULT_BOTTOM_TEXT:String="BOTTOM";
        
        var meme:Meme!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            initText()
            
        }
        //formats text to meme style
        func initText(){
            
            topText.defaultTextAttributes=memeTextAttributes
            topText.textAlignment=NSTextAlignment.center
            topText.autocapitalizationType=UITextAutocapitalizationType.allCharacters
            topText.borderStyle=UITextBorderStyle.none
            topText.backgroundColor=UIColor.clear
            topText.sizeToFit()
            topText.delegate=self
            
            
            bottomText.defaultTextAttributes=memeTextAttributes
            bottomText.textAlignment=NSTextAlignment.center
            bottomText.autocapitalizationType=UITextAutocapitalizationType.allCharacters
            bottomText.borderStyle=UITextBorderStyle.none
            bottomText.backgroundColor=UIColor.clear
            bottomText.sizeToFit()
            bottomText.delegate=self
            
            reset()
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            subscribeToKeyboardNotifications()
            
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            unsubscribeFromKeyboardNotifications()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
        }
        
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            
            if(textField.text == DEFAULT_TOP_TEXT || textField.text == DEFAULT_BOTTOM_TEXT){
                textField.text = "";
            }

            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        
        
        @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
            
            let imagePickController = UIImagePickerController()
            
            imagePickController.delegate=self
            imagePickController.sourceType=UIImagePickerControllerSourceType.photoLibrary
            
            present(imagePickController, animated:true, completion: nil)
            
        }
        
        @IBAction func showActivityView(sender: AnyObject) {
            
            let image=self.saveImage()
            
            let nextController=UIActivityViewController(activityItems: [image] , applicationActivities:nil)
            
            nextController.completionWithItemsHandler = {
                (s, ok, items, err) -> Void in
                if ok {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            self.present(nextController,animated: true, completion:nil)
            
        }
        
        
        
        @IBAction func pickAnImageFromCamera(sender: AnyObject) {
            
            let imagePickController = UIImagePickerController()
            
            imagePickController.delegate=self
            imagePickController.sourceType=UIImagePickerControllerSourceType.camera
            
            self.present(imagePickController, animated:true, completion: nil)
            
        }
        
        @IBAction func cancelAction(sender: AnyObject) {
            reset()
            
        }
        
        func reset(){
            
            bottomText.text=DEFAULT_BOTTOM_TEXT
            topText.text=DEFAULT_TOP_TEXT
            
            shareButton.isEnabled=false
            imagePickerView.image=nil
        }
        
        //Get the keyboard out of the way when editing bottom text
        
        func keyboardWillShow(_ notification:Notification){
             if(bottomText.isFirstResponder){
                view.frame.origin.y = 0 - getKeyboardHeight(notification: notification as NSNotification)}
        }
        
        func keyboardWillHide(_ notification:Notification){
             if(bottomText.isFirstResponder){
                view.frame.origin.y = 0
            }
        }
        
        func subscribeToKeyboardNotifications(){
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
        func unsubscribeFromKeyboardNotifications(){
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            
              NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        }
        
        func getKeyboardHeight(notification: NSNotification) -> CGFloat {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.cgRectValue.height
        }//end keyboard shifting methods
        
        //Create Memed image
        
        func generateMemedImage() -> UIImage
        {
            
            toolBar.isHidden=true
            
            UIGraphicsBeginImageContext(self.view.frame.size)
            
            self.view.drawHierarchy(in: self.view.frame,
                                              afterScreenUpdates: true)
            
            let memedImage : UIImage =
                
                UIGraphicsGetImageFromCurrentImageContext()!
            
            UIGraphicsEndImageContext()
            
            toolBar.isHidden=false
            
            
            return memedImage
        }
        
        func saveImage() -> UIImage{
            
            let memeImage=generateMemedImage()
            self.meme = Meme (topText: topText.text, bottomText:bottomText.text , image: imagePickerView.image , memedImage:memeImage)
            
            return memeImage
        }
        
        //function to set image in UIImageView when chosen from camera or album
        
         func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imagePickerView.contentMode = UIViewContentMode.scaleAspectFit;
                self.imagePickerView.image = image
                self.shareButton.isEnabled=true
                self.cancelButton.isEnabled=true
            } else{
                print("Something went wrong")
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        
        
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
      struct Meme{
            var topText : String!
            var bottomText : String!
            var image : UIImage!
            var memedImage : UIImage!
            
            
        }
  //      func save() {
            // Create the meme
  //          let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image! //memedImage: memedImage
 //           )
  //      }
        
        
        
        
    }


