//
//  DetailViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 9/15/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController, GMSMapViewDelegate {

    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var nameField: UILabel!
    @IBOutlet var addressField: UILabel!
    @IBOutlet var telField: UILabel!
    @IBOutlet var descriptionField: UILabel!
    @IBOutlet var websiteField: UILabel!
    @IBOutlet var feeField: UILabel!
    
    var locationManager = CLLocationManager()
    var currLocation: CLLocation?
    let regionRadius: CLLocationDistance = 1000
    
    var lat: Double?
    var lon: Double?
    
    var facility: Facility! {
        didSet {
            navigationItem.title = facility.F_Name
            self.lat = Double(facility.Lat!)
            self.lon = Double(facility.Lon!)

            self.configureView()
        }
    }

    
    func configureView() {

        if let facility = self.facility  {
            
            let info = facility.Address! + "\n" + "Fee: " + facility.Fee! + "\n" + facility.Telephone! + "\n\n"  + facility.Desc!

            let camera = GMSCameraPosition.camera(withLatitude: self.lat!, longitude: self.lon!, zoom: 15.0)
            
            mapView = GMSMapView.map(withFrame: .zero, camera: camera)
//            mapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 100, height: self.view.bounds.height))
            mapView?.mapType = kGMSTypeNormal
            mapView?.isMyLocationEnabled = true

            self.view = mapView
 
            
            //Add a segmented control for selecting the map type.
            let items = ["Normal", "Terrain", "Satellite", "Hybrid"]
            let segmentedControl = UISegmentedControl(items: items)
            segmentedControl.selectedSegmentIndex = 0
            
            segmentedControl.frame = CGRect(x: 10, y: 65, width: view.bounds.width, height: 50)
            segmentedControl.layer.cornerRadius = 5.0
            segmentedControl.addTarget(self, action: #selector(DetailViewController.mapType(_:)), for: UIControlEvents.valueChanged)
            segmentedControl.addTarget(self, action: #selector(DetailViewController.segColor(_:)), for: UIControlEvents.valueChanged)
//                   self.view.addSubview(segmentedControl)
            let marker = GMSMarker()
            
            marker.position = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lon!)
            marker.title = facility.F_Name!
            marker.snippet = info
            marker.map = mapView

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let marker = GMSMarker()
        mapView.isMyLocationEnabled = true
        mapView.camera = GMSCameraPosition(target: (location?.coordinate)!, zoom: 15, bearing: 0, viewingAngle: 0)
        marker.position = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        marker.title = "Current Location"
        marker.map = mapView
        
        self.locationManager.stopUpdatingLocation()
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


// MARK: - CLLocationManagerDelegate

extension DetailViewController: CLLocationManagerDelegate {
    

      @nonobjc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()

            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }

      @nonobjc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {

            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            locationManager.stopUpdatingLocation()
        }
        
    }
}





