//
//  UIImagePickerController+Orientation.swift
//  MeMe
//
//  Created by Guilherme Ramos on 06/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

//Created this extension to handle imagepicker controller being portrait-only
extension UIImagePickerController {

    open override var shouldAutorotate: Bool {
        return true
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}
