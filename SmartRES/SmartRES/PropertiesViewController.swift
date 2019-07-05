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

protocol controlsRefresh {
    func loadProperties()
}


class PropertiesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, controlsRefresh {

    let refreshControl = UIRefreshControl()
    var properties = [Property]()
    var editButtonEnabled = false
    @IBOutlet weak var propertyCollectionView: UICollectionView!
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var editButtonView: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(loadProperties), for: .valueChanged)
        propertyCollectionView.refreshControl = refreshControl
        propertyCollectionView.dataSource = self
        propertyCollectionView.delegate = self


        // UICollectionView Layout config
        let layout = propertyCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = view.frame.size.width / 2
        layout.itemSize = CGSize(width: width, height: width)
    
        // Async load properties
        loadProperties()

        // If no properties, display default message
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = propertyCollectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        let property = properties[indexPath.item]
        cell.propertyCellView.image = property.image
        cell.propertyLabel.text = property.address
        
        cell.deleteButtonView?.layer.setValue(indexPath.row, forKey: "index")
        cell.deleteButtonView?.addTarget(self, action: #selector(deleteProperty), for: UIControl.Event.touchUpInside)
        
        return cell;
    }

    @IBAction func addProperty(_ sender: Any) {
        self.performSegue(withIdentifier: "addPropertySegue", sender: self)
    }
    
    @objc func loadProperties() {

        // Search all Property objects for this current user
        let query = PFQuery(className: "Property")
        query.whereKey("agent", equalTo: PFUser.current()!)

        // Async find in background
        query.findObjectsInBackground{ (queryDict, error) in
            if let queryProperties = queryDict {
                self.properties.removeAll()
                for propertyDict in queryProperties {

                    // Create UI image for each property first
                    var pic : UIImage! = UIImage()
                    if (propertyDict["thumbnail"] != nil) {
                        let imageFile = propertyDict["thumbnail"] as! PFFileObject
                        let url = URL(string: imageFile.url!)!
                        let data = try? Data(contentsOf: url)
                        pic = UIImage(data: data!)
                    } else {
                        // Default image if no thumbnail was set
                        let url = URL(string: "https://suitabletech.com/images/HelpCenter/errors/Lenovo-Camera-Error.JPG")!
                        let data = try? Data(contentsOf: url)
                        pic = UIImage(data: data!)
                    }

                    // Create a new Property object
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

                    // Add property object to list of property objects
                    self.properties.append(property)
                    
                }
                if self.properties.count == 0 {
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
                // Reload and refresh
                self.propertyCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier != "addPropertySegue") {
            // On select cell, pass data to destination VC
            let cell = sender as! UICollectionViewCell
            let indexPath = self.propertyCollectionView.indexPath(for: cell)!
            let property = properties[indexPath.row]
            let propertyDetails = segue.destination as! MainViewController
            propertyDetails.property = property
            propertyDetails.refresh()
        }
    }
    
    
    @IBAction func editProperties(_ sender: Any) {
        if (properties.count == 0) {
            return
        }
        if (!self.editButtonEnabled ) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(editProperties))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1)
            self.editButtonEnabled  = true
            for cell in propertyCollectionView.visibleCells as! [PropertyCell] {
                
                UIView.animate(withDuration: 0.5, animations: {
                    cell.deleteButtonView.alpha = 1
                }, completion:  nil)
                cell.deleteButtonView.isHidden = false
                
                
                //cell.deleteButtonView.isHidden = false
            }
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editProperties))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1)
            self.editButtonEnabled  = false
            for cell in propertyCollectionView.visibleCells as! [PropertyCell] {
                
                UIView.animate(withDuration: 0.5, animations: {
                    cell.deleteButtonView.alpha = 0
                }, completion:  {
                    (value: Bool) in
                    cell.deleteButtonView.isHidden = true
                })
                //cell.deleteButtonView.isHidden = true
            }
        
        }
        
    }
    
    @objc func deleteProperty(sender:UIButton) {
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        let propertyName = self.properties[i].address
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete the property: \(propertyName)? This action cannot be undone.", preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, I'm sure", style: UIAlertAction.Style.default, handler: {action in
            print("Deleting cell...")
            let i : Int = (sender.layer.value(forKey: "index")) as! Int
            let toDelete = self.properties[i].id
            
            let query = PFQuery(className:"Property")
            query.getObjectInBackground(withId: toDelete) { (property: PFObject?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    property?.deleteInBackground() { (success, error) in
                        if success {
                            let alert = UIAlertController(title: "Success", message: "Property, \(propertyName), has been deleted.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Error", message: "Deleting property failed. No changes made.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    self.loadProperties()
                }
            }
        }))
        
        
        
        self.present(alert, animated: true, completion: nil)
    }
}
