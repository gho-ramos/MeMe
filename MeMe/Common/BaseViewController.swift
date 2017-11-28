//
//  BaseViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 20/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(BaseViewController.createNewMemeAction(_: ))
        )
    }

    @objc func createNewMemeAction(_ sender: Any?) {
        let createNewMemeVC = CreateNewMemeViewController.instance()
        present(createNewMemeVC, animated: true, completion: nil)
    }
}
