//
//  SelectionViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 11/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

protocol SelectionViewControllerDelegate: class {
    func didSelect(font: UIFont?)
}

class SelectionViewController: UIViewController {

    // MARK: Properties
    weak var delegate: SelectionViewControllerDelegate?

    let animationDuration: TimeInterval = 0.25

    var fonts: [String]!
    var selectedFont: UIFont?

    @IBOutlet weak var selectFontButton: UIButton!
    override var prefersStatusBarHidden: Bool { return true }

    @IBOutlet weak var fontSelectionView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFonts()
    }

    func loadFonts() {
        for fontFamilyName in UIFont.familyNames.sorted() {
            for fontName in UIFont.fontNames(forFamilyName: fontFamilyName) {
                if fonts != nil {
                    fonts?.append(fontName)
                } else {
                    fonts = [fontName]
                }
            }
        }
    }

    @IBAction func hidePickerView(_ sender: Any) {
        if view.subviews.contains(fontSelectionView) {
            UIView.animate(withDuration: animationDuration, animations: {
                self.fontSelectionView.frame.origin.y = self.view.frame.maxY
            }, completion: { (complete) in
                if complete {
                    self.fontSelectionView.removeFromSuperview()
                }
            })
        }
    }

    //Show a picker view with a set of fonts for you to select
    @IBAction func showPickerView(_ sender: Any) {
        if !view.subviews.contains(fontSelectionView) {
            fontSelectionView.frame.origin.y = view.frame.maxY
            fontSelectionView.frame.size.width = view.frame.width
            view.addSubview(fontSelectionView)

            UIView.animate(withDuration: animationDuration, animations: {
                self.fontSelectionView.frame.origin.y = self.view.frame.maxY - self.fontSelectionView.frame.height
            })
        }
    }

    // Dismiss the viewController without an action
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // Pass the selected font back to the meme viewcontorller
    @IBAction func doneButtonPressed(_ sender: Any) {
        guard delegate != nil else {
            return
        }
        delegate?.didSelect(font: selectedFont)
        dismiss(animated: true, completion: nil)
    }
}

extension SelectionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let fontNumber = fonts?.count {
            return fontNumber
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fonts?[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let fontName = fonts?[row] {
            selectedFont = UIFont(name: fontName, size: 40)
            selectFontButton.setTitle(fontName, for: .normal)
        }
    }
}
