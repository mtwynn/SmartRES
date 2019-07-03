//
//  PropertiesViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse
import ImageSlideshow

class PropertiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var properties = [Property]()
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var propertyCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        propertyCollectionView.dataSource = self
        propertyCollectionView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(loadProperties), for: .valueChanged)
        propertyCollectionView.refreshControl = refreshControl
        loadProperties()
        
        let layout = propertyCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = view.frame.size.width / 2
        
        layout.itemSize = CGSize(width: width, height: width)
        
        if self.properties.count == 0 {
            print("Here")
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.text = "You don't have any properties yet.\nPlease click the + sign to add one."
            messageLabel.textColor = UIColor(red: 0.0/255.0, green: 151.0/255.0, blue: 69.0/255.0, alpha: 0.5)
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "Lato", size: 15)
            messageLabel.sizeToFit()
            self.propertyCollectionView.backgroundView = messageLabel;
        } else {
            self.propertyCollectionView.backgroundView = nil
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = propertyCollectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        
        let property = properties[indexPath.item]
        cell.propertyCellView.image = property.image
        
        return cell;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        self.performSegue(withIdentifier: "propertySegue", sender: self)
    }

    @IBAction func addProperty(_ sender: Any) {
        self.performSegue(withIdentifier: "addPropertySegue", sender: self)
    }
    
    @objc func loadProperties() {
        print("Called")
        let query = PFQuery(className: "Property")
        query.whereKey("agent", equalTo: PFUser.current())
        query.findObjectsInBackground{ (queryDict, error) in
            if let queryProperties = queryDict {
                self.properties.removeAll()
                for propertyDict in queryProperties {
                    var pic : UIImage! = UIImage()
                    if (propertyDict["thumbnail"] != nil) {
                        let imageFile = propertyDict["thumbnail"] as! PFFileObject
                        let url = URL(string: imageFile.url!)!
                        let data = try? Data(contentsOf: url)
                        pic = UIImage(data: data!)
                    } else {
                        let url = URL(string: "https://suitabletech.com/images/HelpCenter/errors/Lenovo-Camera-Error.JPG")!
                        let data = try? Data(contentsOf: url)
                        pic = UIImage(data: data!)
                    }
                    
                    print("Bed is: ", propertyDict["bath"] as! NSNumber)
                    let property = Property(id: propertyDict.objectId as! String,
                                            address: propertyDict["address"] as! String,
                                            city:  propertyDict["city"] as! String,
                                            state: propertyDict["state"] as! String,
                                            zip: propertyDict["zip"] as! String,
                                            type: propertyDict["type"] as! String,
                                            bed: propertyDict["bed"] as! NSNumber,
                                            bath: propertyDict["bath"] as! NSNumber,
                                            price: propertyDict["price"] as! NSNumber,
                                            image: pic!,
                                            agent: propertyDict["agent"] as! PFUser
                                            )
                    print(property)
                    self.properties.append(property)
                    self.propertyCollectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
}
