//
//  ViewController.swift
//  MemeMe
//
//  Created by bhuvan on 04/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {
    
    
    struct PlaceholderText {
        static let Top = "TOP"
        static let Bottom = "BOTTOM"
    }

    // MARK: Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // MARK: Properties
    internal var shareMemeButton: UIBarButtonItem!
    internal var cancelButton: UIBarButtonItem!
    fileprivate let memeTextAttributes: [NSAttributedString.Key: Any] = [.strokeColor: UIColor.black,
                                                             .foregroundColor: UIColor.white,
                                                             .font: UIFont(name: "Impact", size: 40)!,
                                                             .strokeWidth: -4]
    internal var memedImage: UIImage!
    fileprivate let maximumAllowedFonts = 8
    fileprivate var fonts = [UIFont]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        configureFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Subscribe to keyboard notification, to allow the view to raise when neccesary
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe keyboard notifications
        unsubscribeFromKeyboardNotification()
    }

    // MARK: - Actions
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        showImagePicker(for: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        showImagePicker(for: .camera)
    }
    
    @IBAction func pickFontForMeme(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Fonts", message: "Choose a font", preferredStyle: .actionSheet)
        for font in fonts {
            let fontAction = UIAlertAction(title: font.fontName, style: .default) { (action) in
                self.topTextField.font = font
                self.bottomTextField.font = font
            }
            actionSheet.addAction(fontAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    // MARK - Helpers
    func toolbarAndNavigationBar(isHidden: Bool) {
        bottomToolbar.isHidden = isHidden
        navigationController?.setNavigationBarHidden(isHidden, animated: false)
    }
    
    func showImagePicker(for sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
}


// MARK: - Meme Helpers
extension MemeEditorViewController {
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImageView.image!, memedImage: memedImage)
        
        // Add it to the memes array
        MemeStorage.shared.memes.append(meme)
    }
        
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        toolbarAndNavigationBar(isHidden: true)
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolbarAndNavigationBar(isHidden: false)
        
        return memedImage
    }
}

// MARK: - Configure UI
extension MemeEditorViewController {
    
    func configureUI() {
    
        // Configure bar buttons in the navigation bar
        configureBarButtons()
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        topTextField.text = PlaceholderText.Top
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        bottomTextField.text = PlaceholderText.Bottom
        shareMemeButton.isEnabled = false
    }
    
    func configureBarButtons() {
        
        // Share button
        shareMemeButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareMeme))
        
        // Cancel button
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(goBack))
        cancelButton.tintColor = .red
        
        // Fixed space button
        let fixedButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        navigationItem.rightBarButtonItems = [cancelButton, fixedButton, shareMemeButton]
    }
    
    @objc func shareMeme() {
        
        memedImage = generateMemedImage()
        
        // Create activity to share memed image
        let activityController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = { [weak self] _, success, _ , _ in
            if success {
                self?.save()
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func goBack() {
        // Reset the view
        navigationController?.popViewController(animated: true)
    }
    
    
    func configureFonts() {
        for fontFamily in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
                if let newFont = UIFont(name: fontName, size: 40) {
                    fonts.append(newFont)
                    // Maximum allowd fonts
                    if fonts.count == maximumAllowedFonts {
                        return
                    }
                }
            }
        }
    }
}


// MARK: - Keyboard Notifications
extension MemeEditorViewController {
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

// MARK: - UITextFieldDelegate
extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Reset the text
        textField.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Fetch the image
        var outputImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if outputImage == nil {
            outputImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        memeImageView.image = outputImage

        // Enable share meme button
        shareMemeButton.isEnabled = true
        
        // Dismiss image picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss image picker
        picker.dismiss(animated: true, completion: nil)
    }
        
}
