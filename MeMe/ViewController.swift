//
//  ViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 03/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var botTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!

    fileprivate var memedImage: UIImage?
    fileprivate var pickerView: UIPickerView?
    fileprivate let fontSelector = FontSelector()

    override var prefersStatusBarHidden: Bool { return true }

    let attributes: [String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -4
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultTextSetup()

        topTextField.textAlignment = .center
        botTextField.textAlignment = .center

        fontSelector.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

        checkShareButtonState()

        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }

    // MARK: Private Methods
    fileprivate func checkShareButtonState() {
        shareButton.isEnabled = imagePickerView.image != nil
    }

    fileprivate func defaultTextSetup() {
        topTextField.text = "TOP"
        botTextField.text = "BOTTOM"

        // if it isn't nil, use the parameter to change the default attributes of the textfield, otherwise,
        // use the default values
        topTextField.defaultTextAttributes = attributes
        botTextField.defaultTextAttributes = attributes
    }

    fileprivate func generateMemedImage() -> UIImage {

        navigationBar.isHidden = true
        toolbar.isHidden = true

        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        navigationBar.isHidden = false
        toolbar.isHidden = false

        return memedImage
    }

    fileprivate func save() {
        _ = Meme(topText: topTextField.text!,
                 bottomText: botTextField.text!,
                 originalImage: imagePickerView.image!,
                 memedImage: memedImage!)

        checkShareButtonState()
    }

    fileprivate func presentImagePickerController(forSource sourceType: UIImagePickerControllerSourceType) {
        PHPhotoLibrary.requestAuthorization { (authorization) in
            switch authorization {
            case .authorized:
                    let pickerController = UIImagePickerController()
                    pickerController.sourceType = sourceType
                    pickerController.delegate = self
                    pickerController.allowsEditing = true
                    pickerController.modalPresentationStyle = .popover
                    self.present(pickerController, animated: true, completion: nil)
            case .notDetermined:
                print("Not determined")
            case .restricted:
                print("Restricted access")
            case .denied:
                print("Access denied")
            }
        }
    }
    // Creates a pickerview and set the fontDelegate to control the actions of the pv
    // Crates an alertviewcontroller and uses it as a placeholder to our pickerview
    fileprivate func presentPickerView() {
        let pickerHeight = view.frame.height / 4
        let pickerWidth = view.frame.width
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: pickerWidth, height: pickerHeight))

        pickerView!.clipsToBounds = true
        pickerView!.delegate = fontSelector
        pickerView!.dataSource = fontSelector

        pickerView!.reloadAllComponents()

        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)

        alertController.addAction(action)
        alertController.view.addSubview(pickerView!)
        NSLayoutConstraint.activate([
            alertController.view.topAnchor.constraint(equalTo: pickerView!.topAnchor, constant: 40),
            alertController.view.bottomAnchor.constraint(equalTo: pickerView!.bottomAnchor, constant: 40)
        ])

        present(alertController, animated: true) {
            self.pickerView!.frame.size.width = alertController.view.frame.width
        }
    }

    // MARK: Actions

    @IBAction func showFontSelector(_ sender: Any?) {
        fontSelector.loadFonts {
            self.presentPickerView()
        }
    }

    @IBAction func pickAnImageFromCameraAction(_ sender: Any?) {
        presentImagePickerController(forSource: .camera)
    }

    @IBAction func pickAnImageFromAlbumAction(_ sender: Any?) {
        presentImagePickerController(forSource: .photoLibrary)
    }

    @IBAction func shareAction(_ sender: Any?) {
        memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.saveToCameraRoll]
        present(activityViewController, animated: true, completion: {
            self.save()
        })
    }

    @IBAction func cancelAction(_ sender: Any?) {
        imagePickerView.image = nil

        defaultTextSetup()

        checkShareButtonState()
    }

    // MARK: Notifications

    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                 selector: #selector(keyboardWillShow(_:)),
                                 name: .UIKeyboardWillShow,
                                 object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(from: notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if view.frame.origin.y < 0 {
            view.frame.origin.y = 0
        }
    }

    func getKeyboardHeight(from notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        if let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            return keyboardSize.cgRectValue.height
        }
        return 0
    }
}

// MARK: UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // Handling the image after selecting from photoLibrary or taking a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
            picker.dismiss(animated: true, completion: {
                self.checkShareButtonState()
            })
        }
    }
}

// MARK: FontSelectorDelegate
extension ViewController: FontSelectorDelegate {
    func pickerViewDidSelect(font: UIFont?) {
        guard let font = font else {
            return
        }
        topTextField.font = font
        botTextField.font = font
    }
}
