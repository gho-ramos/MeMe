//
//  SentMemesCollectionViewController.swift
//  MeMe
//
//  Created by Guilherme Ramos on 21/11/2017.
//  Copyright © 2017 Guilherme Ramos. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: BaseViewController {
    let cellIdentifier = "MeMeCell"

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    var memes: [Meme]! {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let spacing: CGFloat = 5
        let dimension = (self.view.frame.width - (2 * spacing)) / 3

        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let applicationDelegate = UIApplication.shared.delegate as? AppDelegate
        memes = applicationDelegate?.memes
    }

}

extension SentMemesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_  collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? GridCollectionViewCell else {
                return UICollectionViewCell()
        }

        cell.imageView?.image = memes[indexPath.row].memedImage
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = MemeDetailViewController.instance(with: indexPath.row)
        navigationController?.pushViewController(detailController, animated: true)
    }
}
