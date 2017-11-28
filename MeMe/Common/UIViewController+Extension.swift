//
//  UIViewController+Extension.swift
//  MeMe
//
//  Created by Guilherme Ramos on 20/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

extension UIViewController {
    class func instantiateFromStoryboard(name: String, identifier: String) -> Self {
        return genericStoryboardInstance(with: name, identifier: identifier)!
    }

    private class func genericStoryboardInstance<T>(with name: String, identifier: String) -> T? {
        let storyboard = UIStoryboard.init(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(
            withIdentifier: identifier
        )
        return controller as? T
    }
}
