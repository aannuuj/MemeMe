//
//MemeEditorViewController.swift
//  Meme
//
//  Created by Hariom Palkar on 29/04/20.
//  Copyright © 2020 Hariom Palkar. All rights reserved.
//


import UIKit

class MemeEditorViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet var imagePickerView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var topBar: UIToolbar!
    @IBOutlet var bottomBar: UIToolbar!
    @IBOutlet var superBar: UIView!
    
    
    //MARK: Constants + Variables

    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -5.0,
    ]
    
    var memedImage : UIImage! ///  FINAL MEME
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //INITIAL SETUP
        shareButton.isEnabled = false
        hideKeyboardWhenTappedAround()
    }
    
    func setupTextFields(){
        for textfield : UITextField in [bottomTextField,topTextField] {
            textfield.defaultTextAttributes = memeTextAttributes
        }
        
        //Align text to middle
        bottomTextField.textAlignment = .center
        topTextField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //INITIAL SETUP
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        setupTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications() /// REMOVE OBSERVERS
    }
    
    // MARK:- ImagePicker Functions
    
    func presentImagePicker(_ source : UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self // making this a delegate
        imagePicker.sourceType = source /// Photo Library or Camera
        imagePicker.allowsEditing = true /// Crop photo
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: UIBarButtonItem) {
        presentImagePicker(.photoLibrary) /// Presents PhotoLibrary
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        presentImagePicker(.camera) /// Presents Camera
    }
    
    
    //MARK:- Generate Meme
    func generateMemedImage() -> UIImage {
        
        //Hide unwanted components
        updateViewsForMeme(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //bring em back
        updateViewsForMeme(false)
        
        return memedImage    /// Final meme
    }
    
    // Hides Top + Bottom Bar in Final Meme
    private func updateViewsForMeme(_ bool : Bool){
        bottomBar.isHidden = bool
        topBar.isHidden = bool
        superBar.isHidden = bool
    }
    
    //MARK:- Share Meme
    @IBAction func shareMeme(_ sender: UIBarButtonItem) {
        
        let memedImage = generateMemedImage()
        
        let shareItems = [memedImage]
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print,
                                                        UIActivity.ActivityType.postToWeibo,
                                                        UIActivity.ActivityType.postToFacebook,
                                                        UIActivity.ActivityType.postToTwitter,
                                                        UIActivity.ActivityType.mail,
                                                        UIActivity.ActivityType.copyToPasteboard,
                                                        UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.postToVimeo]
        
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
    
    
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: memedImage)
    }
    
}


//MARK:- PickerController Delegate Methods
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage? ///  FInal image will be assigned here
        
        if let editedImage =  info[.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        }
            
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imagePickerView.image = selectedImage
        }
        
        self.dismiss(animated: true, completion: nil ) /// Dissmiss picker
        
        shareButton.isEnabled = true  /// Now You Can Share Your Meme
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled Image picker")
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Keyboard show + hide functions
extension MemeEditorViewController {
    
    //MARK: Add Observers
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Remove Observers
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Move view up /down only for bottomTextField
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    // Get the height of keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        let height = keyboardSize.cgRectValue.height // Height of Keyboard
        return height
    }
}

//MARK:- UITextField Delegate Methods
extension MemeEditorViewController : UITextFieldDelegate {
    
    //MARK: Textfield empties first time
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "BOTTOM" || textField.text == "TOP" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

