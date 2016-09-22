//
//  DetailViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 9/15/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController, GMSMapViewDelegate{
    


    var london: GMSMarker?
    var londonView: UIImageView?
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var nameField: UILabel!
    @IBOutlet var addressField: UILabel!
    @IBOutlet var telField: UILabel!
    @IBOutlet var descriptionField: UILabel!
    @IBOutlet var websiteField: UILabel!
    @IBOutlet var feeField: UILabel!
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    let regionRadius: CLLocationDistance = 1000
    var lat: Double?
    var lon: Double?
    
    var facility: Facility! {
        didSet {
            navigationItem.title = facility.F_Name
            self.lat = Double(facility.Lat!)
            self.lon = Double(facility.Lon!)
            
        }
    }
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let info = facility.Address! + "\n" + "Fee: " + facility.Fee! + "\n" + facility.Telephone! + "\n\n"  + facility.Desc!
        
        mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        mapView.camera = GMSCameraPosition.camera(withLatitude: self.lat!, longitude: self.lon!, zoom: 15.0)
        
        mapView.mapType = kGMSTypeNormal
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        view.addSubview(mapView)
        
        //Add a segmented control for selecting the map type.
        let items = ["Normal", "Terrain", "Satellite", "Hybrid"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.frame = CGRect(x: 0, y: 65, width: view.bounds.width, height: 50)
        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.addTarget(self, action: #selector(DetailViewController.mapType(_:)), for: UIControlEvents.valueChanged)
        segmentedControl.addTarget(self, action: #selector(DetailViewController.segColor(_:)), for: UIControlEvents.valueChanged)
        view.addSubview(segmentedControl)
        
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lon!)
        marker.title = facility.F_Name!
        marker.snippet = info
        marker.map = mapView
        
    }
    
    
    func mapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = kGMSTypeNormal
        case 1:
            mapView.mapType = kGMSTypeTerrain
        case 2:
            mapView.mapType = kGMSTypeSatellite
        default:
            mapView.mapType = kGMSTypeHybrid
        }
    }
    
    func segColor(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sender.tintColor = UIColor.blue
            sender.backgroundColor   = UIColor.clear
        case 1:
            sender.tintColor = UIColor.blue
            sender.backgroundColor   = UIColor.clear
        case 2:
            sender.tintColor = UIColor.yellow
            sender.backgroundColor = UIColor.orange
        default:
            sender.tintColor = UIColor.yellow
            sender.backgroundColor = UIColor.orange        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeMapType(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            // self.mapView.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            //self.mapView.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            //self.mapView.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}





