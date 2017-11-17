//
//  MeMeViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 16/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit
import Photos

class MeMeViewController: UIViewController {

    // MARK: Properties
    override var prefersStatusBarHidden: Bool { return true }

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var botTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!

    fileprivate var pickerView: UIPickerView?
    fileprivate let fontSelector = FontSelector()
    fileprivate let textFieldDelegate = TextDelegate()
    fileprivate struct FieldText {
        static let Top = "TOP"
        static let Bottom = "BOTTOM"
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultUIConfig()

        fontSelector.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscribeToKeyboardNotifications()

        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unsubscribeToKeyboardNotifications()
    }

    // MARK: Methods

    fileprivate func config(_ textField: UITextField, with text: String?) {
        let attributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -4
        ]

        textField.text = text
        textField.delegate = textFieldDelegate
        textField.defaultTextAttributes = attributes
        textField.textAlignment = .center
    }

    fileprivate func defaultUIConfig() {
        imagePickerView.image = nil
        shareButton.isEnabled = false
        config(topTextField, with: FieldText.Top)
        config(botTextField, with: FieldText.Bottom)
    }

    fileprivate func generateMemedImage() -> UIImage? {
        navigationBar.isHidden = true
        toolbar.isHidden = true

        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        navigationBar.isHidden = false
        toolbar.isHidden = false

        return memedImage
    }

    fileprivate func save(_ memedImage: UIImage?) {
        _ = Meme(
            topText: topTextField.text!,
            bottomText: botTextField.text!,
            originalImage: imagePickerView.image!,
            memedImage: memedImage!
        )
    }

    fileprivate func presentImagePickerController(forSource type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = type
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.modalPresentationStyle = .popover

        present(pickerController, animated: true, completion: nil)
    }

    fileprivate func presentFontsPickerView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/4)
        pickerView = UIPickerView(frame: frame)

        pickerView?.clipsToBounds = true
        pickerView?.delegate = fontSelector
        pickerView?.dataSource = fontSelector
        pickerView?.reloadAllComponents()

        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alertController = UIAlertController(
            title: "",
            message: "",
            preferredStyle: .actionSheet
        )
        alertController.addAction(action)
        alertController.view.addSubview(pickerView!)
        NSLayoutConstraint.activate([
            alertController.view.topAnchor.constraint(equalTo: pickerView!.topAnchor),
            alertController.view.bottomAnchor.constraint(
                equalTo: pickerView!.bottomAnchor,
                constant: 40
            )
        ])
        present(alertController, animated: true) {
            self.pickerView!.frame.size.width = alertController.view.frame.width
        }
    }

    // MARK: Actions

    @IBAction func showFontSelector(_ sender: Any?) {
        fontSelector.loadFonts {
            self.presentFontsPickerView()
        }
    }

    @IBAction func pickAnImageAction(_ sender: Any?) {
        guard let barButton = sender as? UIBarButtonItem else {
            return
        }
        if let type = UIImagePickerControllerSourceType(rawValue: barButton.tag) {
            presentImagePickerController(forSource: type)
        }
    }

    @IBAction func shareAction(_ sender: Any?) {
        if let memedImage = generateMemedImage() {
            let activityController = UIActivityViewController(
                activityItems: [memedImage],
                applicationActivities: nil
            )
            activityController.completionWithItemsHandler = { (type, completed, items, error) in
                if completed {
                    self.save(memedImage)
                }
            }
            present(activityController, animated: true, completion: nil)
        }
    }

    @IBAction func cancelAction(_ sender: Any?) {
        defaultUIConfig()
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
        if !topTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(from: notification)
        }
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

// MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension MeMeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // Handling the image after selecting from photoLibrary or taking a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
            picker.dismiss(animated: true, completion: {
                self.shareButton.isEnabled = true
            })
        }
    }
}

extension MeMeViewController: FontSelectorDelegate {
    func pickerViewDidSelect(font: UIFont?) {
        if let font = font {
            topTextField.font = font
            botTextField.font = font
        }
    }
}
