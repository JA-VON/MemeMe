//
//  MemeEditorViewController.swift
//  MemeEditor
//
//  Created by Javon Davis on 16/06/2017.
//  Copyright © 2017 Javon Davis. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate  {
    
    @IBOutlet weak var topTextfield: UITextField!
    @IBOutlet weak var bottomTextfield: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var memedImage: UIImage!
    
    // These variables keep track of the textfield at edit time, helps to avoid the textfield texts overlapping while the user is editting
    var topTextfieldValue = ""
    var bottomTextfieldValue = ""
    
    // This value is changed whenever the user chooses a font from the picker
    var fontName = "impact"
    
    // MARK: - Setup Functions
    
    func currentFont() -> UIFont {
        return UIFont(name: fontName, size: 40)!
    }
    
    func configure(textField: UITextField) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: currentFont(),
            NSStrokeWidthAttributeName: -3.0]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
        
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the camera button
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Set up textfields
        configure(textField: topTextfield)
        configure(textField: bottomTextfield)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: - Main Functions
    
    func setToolbarVisibility(hidden: Bool) {
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Note to self: UnsafeRawPointer type provides no automated memory management, no type safety, and no alignment guarantees.
    // i.e. garbage clean that myself to avoid memory leaks
    func meme(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // There was an error
            print(error.localizedDescription)
            showAlert(title: "Error Saving Meme!", message: "Oh no! We had some trouble saving your meme to photos")
        }
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextfield.text!, bottomText: bottomTextfield.text!, originalImage: memeImageView.image!, memedImage: memedImage)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        
        UIImageWriteToSavedPhotosAlbum(meme.memedImage, self, #selector(meme(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func renderViewToImage() -> UIImage {
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }

    func generateMemedImage() -> UIImage {
        
        setToolbarVisibility(hidden: true)
        let memedImage = renderViewToImage()
        setToolbarVisibility(hidden: false)
        
        return memedImage
    }
    
    func askNicelyForAccess(type: String) {
        let alertController = UIAlertController(title: "Give app access to \(type)", message: "\(type) access is needed to select a picture to make your meme", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let allowAction = UIAlertAction(title: "Allow access to the \(type)", style: .cancel, handler: { alert in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil) // Take the user to settings and hope they grant access
        })
        
        alertController.addAction(allowAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func askUserForFont(textField: UITextField) {
        
        // Create a view controller to ask the user for the font they would like to use
        let fontViewController = UIViewController()
        fontViewController.preferredContentSize = CGSize(width: self.view.frame.width, height: 200)
        
        
        // Set up picker for fonts
        let pickerFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200) // Note: left, right, width, height
        let picker: UIPickerView = UIPickerView(frame: pickerFrame);
        
        picker.delegate = self;
        picker.dataSource = self;
    
        fontViewController.view.addSubview(picker)
        
        let alertController = UIAlertController(title: "Choose your font!", message: "Choose a font you like :)", preferredStyle: .actionSheet);
        alertController.isModalInPopover = true
        
        alertController.setValue(fontViewController, forKey: "contentViewController")
        
        let cancelAction = UIAlertAction(title: "Use Current Font", style: .default, handler: nil)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { alert in
            self.fontName = UIFont.familyNames[picker.selectedRow(inComponent: 0)] // There's only one component :)
            textField.font = self.currentFont()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        
        let source:  UIImagePickerControllerSourceType = sender.tag == 0 ? .camera:.photoLibrary
        
        if source == .camera {
            let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            guard cameraStatus == .authorized || cameraStatus == .notDetermined else {
                askNicelyForAccess(type: "Camera")
                return
            }
        } else {
            let photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
            guard photoLibraryStatus == .authorized || photoLibraryStatus == .notDetermined else {
                askNicelyForAccess(type: "Photo Library")
                return
            }
        }
        
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true // Allow the user to crop
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme() {
        memedImage = generateMemedImage()
        
        guard memeImageView.image != nil else {
            showAlert(title: "No Meme detected", message: "Sorry there was a problem making your meme.")
            return
        }
        
        let activityContoller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.present(activityContoller, animated: true, completion: nil)
        
        activityContoller.completionWithItemsHandler = {(activityType, completed, items, error) in
            
            if let error = error {
                print(error.localizedDescription)
                self.showAlert(title: "Error sharing", message: "Could not present options for you to share your meme :(")
            } else {
                if completed {
                    self.save()
                }
            }
            
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImagePickerControllerDelegate

extension MemeEditorViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("ImagePicker finished")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { // Get image if it exists
            self.memeImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TextFieldDelegate

extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.fontName = (textField.font?.familyName)!
        askUserForFont(textField: textField)
        
        topTextfieldValue = topTextfield.text!
        bottomTextfieldValue = bottomTextfield.text!
        
        topTextfield.text = ""
        bottomTextfield.text = ""
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if topTextfield.text == "" {
            topTextfield.text = topTextfieldValue
        }
        
        if bottomTextfield.text == "" {
            bottomTextfield.text = bottomTextfieldValue
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetView()
        return true
    }
}

// MARK: - PickerView Delegate + DataSource

extension MemeEditorViewController: UIPickerViewDelegate, UIPickerViewDataSource { // For the font picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UIFont.familyNames.count // Thanks Apple
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return UIFont.familyNames[row]
    }
}
