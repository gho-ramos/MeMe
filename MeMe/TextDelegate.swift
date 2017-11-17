//
//  TextDelegate.swift
//  MeMe
//
//  Created by Guilherme Ramos on 17/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

class TextDelegate: NSObject, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
