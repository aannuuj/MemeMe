//
//MemeEditorViewController.swift
//  Meme
//
//  Created by Hariom Palkar on 29/04/20.
//  Copyright © 2020 Hariom Palkar. All rights reserved.
//


import UIKit

class MemeEditorViewController: UIViewController {
   
    //MARK: Initial setup
    
    @IBOutlet var imagePickerView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var topBar: UIToolbar!
    @IBOutlet var bottomBar: UIToolbar!
    @IBOutlet var superBar: UIView!
    
    let  memeTextAttributes : [NSAttributedString.Key : Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "Impact", size: 40)!,
        .strokeWidth: -5.0
    ]
    var memedImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //INITIAL SETUP
       
        subscribeToKeyboardNotifications()
        setupTextFields()
    }
    
    func setupTextFields(){
        for textfield : UITextField in [bottomTextField,topTextField] {
            textfield.defaultTextAttributes = memeTextAttributes
        }
        
        //Align text to middle
        bottomTextField.textAlignment = .center
        topTextField.textAlignment = .center
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications() // REMOVE OBSERVERS
    }
    
//MARK: Meme Related Functions
    
    //ImagePicker Functions
    
    @IBAction func pickAnImageFromAlbum(_ sender: UIBarButtonItem) {
        presentImagePicker(.photoLibrary) /// Presents PhotoLibrary
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        presentImagePicker(.camera) /// Presents Camera
    }
    
    func presentImagePicker(_ source : UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self // making this a delegate
        imagePicker.sourceType = source //Photo Library or Camera
        imagePicker.allowsEditing = true // Crop photo
        present(imagePicker, animated: true, completion: nil)
    }
    
   
    
    //Share Meme action
    
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        shareMeme()
    }

    func shareMeme(){
        let memedImage = generateMemedImage()
        
        let shareItems = [memedImage]
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            
            guard error == nil else { return }
            
            if success {
                self.save()
                print("Meme successfully shared by"  + (activity?.rawValue ?? "unknown"))
                activityViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    

       func generateMemedImage() -> UIImage {
           
  
           updateViewsForMeme(true)
           
           // Render view to an image
           UIGraphicsBeginImageContext(self.view.frame.size)
           view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
           memedImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()
           
           //bring em back
           updateViewsForMeme(false)
           return memedImage    //Final meme
       }
       
       // Hides Top + Bottom Bar in Final Meme
       private func updateViewsForMeme(_ bool : Bool){
           bottomBar.isHidden = bool
           topBar.isHidden = bool
           superBar.isHidden = bool
       }
    // save meme
     func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: memedImage)
    }
    
}

