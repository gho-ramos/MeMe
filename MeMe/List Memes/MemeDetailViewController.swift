//
//  MemeDetailViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 27/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

class MemeDetailViewController: BaseViewController {

    var memedImage: UIImage?
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        imageView.image = memedImage
    }

    class func instance() -> Self {
        return instantiateFromStoryboard(
            name: "List",
            identifier: String(describing: self.self)
        )
    }

    class func instance(with image: UIImage?) -> Self {
        let controller = instance()
        controller.memedImage = image
        return controller
    }

}
