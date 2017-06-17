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
    
    struct Meme {
        var topText: String!
        var bottomText: String!
        var originalImage: UIImage!
        var memedImage: UIImage!
        
        init(topText: String! = "", bottomText: String! = "", originalImage: UIImage, memedImage: UIImage) {
            self.topText = topText
            self.bottomText = bottomText
            self.originalImage = originalImage
            self.memedImage = memedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the camera button
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Set up textfields
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0]
        
        topTextfield.defaultTextAttributes = memeTextAttributes
        bottomTextfield.defaultTextAttributes = memeTextAttributes
        
        topTextfield.textAlignment = .center
        bottomTextfield.textAlignment = .center
        
        topTextfield.delegate = self
        bottomTextfield.delegate = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
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
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextfield.text!, bottomText: bottomTextfield.text!, originalImage: memeImageView.image!, memedImage: memedImage)
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
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })
        
        alertController.addAction(allowAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
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
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme() {
        memedImage = generateMemedImage()
        
        guard memeImageView.image != nil else {
            showAlert(title: "No Meme detected", message: "Sorry there was a problem making your meme.")
            return
        }
        
        let activityContoller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.present(activityContoller, animated: true, completion: save)
    }
    
    @IBAction func cancel() {
        topTextfield.text = "TOP"
        bottomTextfield.text = "TOP"
        memeImageView.image = nil
    }
}

extension MemeEditorViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("ImagePicker finished")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { // Get image if it exists
            self.memeImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetView()
        return true
    }
}
