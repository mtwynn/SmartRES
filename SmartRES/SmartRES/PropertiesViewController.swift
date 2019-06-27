//
//  PropertiesViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse

class PropertiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var properties = [[String:Any]]()
    
    @IBOutlet weak var propertyCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        propertyCollectionView.dataSource = self
        propertyCollectionView.delegate = self
        
        let layout = propertyCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = view.frame.size.width / 2
        
        layout.itemSize = CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = propertyCollectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        
        cell.propertyCellView.af_setImage(withURL: URL(string: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/60851350_2569104719791117_9094202935537041408_o.jpg?_nc_cat=107&_nc_oc=AQkpbQIrKhVH7-S3PVqsclxZmhAHKeCJiPeERxeLTE20haxqH2X0WwqgzA4u63u2Owo&_nc_ht=scontent-sjc3-1.xx&oh=3e4b3c92f3df8f215833a88e00782cc7&oe=5DC6B722")!)
        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        self.performSegue(withIdentifier: "propertySegue", sender: self)
    }

    @IBAction func addProperty(_ sender: Any) {
        
    }
    
}
