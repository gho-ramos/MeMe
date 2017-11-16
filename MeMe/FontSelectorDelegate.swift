//
//  FontSelectorDelegate.swift
//  MeMe
//
//  Created by Guilherme Ramos on 15/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

protocol FontSelectorDelegate: NSObjectProtocol {
    /// Tells the delegate it already selected a font
    ///
    /// - Parameter font: font selected on the UIPickerView
    func pickerViewDidSelect(font: UIFont?)
}

class FontSelector: NSObject {

    var fonts: [String]?
    weak var delegate: FontSelectorDelegate!

    public func loadFonts(_ completion: (() -> Void)?) {
        fonts = []
        for fontFamilyName in UIFont.familyNames.sorted() {
            for fontName in UIFont.fontNames(forFamilyName: fontFamilyName).sorted() {
                fonts?.append(fontName)
            }
        }

        if let completion = completion {
            completion()
        }
    }

}

// MARK: UIPickerViewDataSource

extension FontSelector: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let fonts = fonts else {
            return 0
        }
        return fonts.count
    }
}

extension FontSelector: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let font = fonts?[row] {
            delegate?.pickerViewDidSelect(font: UIFont(name: font, size: 40))
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fonts?[row] ?? ""
    }
}
