//
//  SentMemesTableViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 20/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

class SentMemesTableViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    let cellIdentifier = "MeMeCell"
    var memes: [Meme]! {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let applicationDelegate = UIApplication.shared.delegate as? AppDelegate
        memes = applicationDelegate?.memes
    }
}

extension SentMemesTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        let meme = memes[indexPath.row]

        cell?.imageView?.image = meme.memedImage
        cell?.textLabel?.text = "\(meme.topText!)...\(meme.bottomText!)"

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = MemeDetailViewController.instance(with: indexPath.row)
        navigationController?.pushViewController(detailController, animated: true)
    }
}
