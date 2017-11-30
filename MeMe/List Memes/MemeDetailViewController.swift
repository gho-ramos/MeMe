//
//  MemeDetailViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 27/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

protocol MemeDetailViewControllerDelegate: NSObjectProtocol {
    func didFinishEditing(meme: Meme?)
}

class MemeDetailViewController: BaseViewController {
    var index: Int?

    fileprivate var meme: Meme?

    @IBOutlet weak var imageView: UIImageView!

    weak var applicationDelegate: AppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        applicationDelegate = UIApplication.shared.delegate as? AppDelegate
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editAction(_: ))
        )
    }

    override func viewWillAppear(_ animated: Bool) {

        if let index = index {
            meme = applicationDelegate?.memes[index]
            imageView.image = meme?.memedImage
        }
    }

    class func instance() -> Self {
        return instantiateFromStoryboard(
            name: "List",
            identifier: String(describing: self.self)
        )
    }

    class func instance(with index: Int?) -> Self {
        let controller = instance()
        controller.index = index
        return controller
    }

    @IBAction func editAction(_ sender: AnyObject?) {
        guard let meme = meme else {
            return
        }
        let controller = CreateNewMemeViewController.instance()
        controller.meme = meme
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

}

extension MemeDetailViewController: MemeDetailViewControllerDelegate {
    // Using AnyObject because couldn't find another way to use a struct as a parameter for this delegate
    func didFinishEditing(meme: Meme?) {
        self.meme = meme

        guard let applicationDelegate = applicationDelegate else {
            return
        }

        applicationDelegate.memes.remove(at: index!)
    }
}
