//
//  DetailViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 9/15/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController, GMSMapViewDelegate, UIPopoverPresentationControllerDelegate {

    
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
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var lat: Double? = 0
    var lon: Double? = 0
    
    var facility: Facility! {
        didSet {
            navigationItem.title = facility.F_Name
            
            if facility.Lat != "" && facility.Lon != "" {

                self.lat = Double(facility.Lat!)
                self.lon = Double(facility.Lon!)


            } else {
                let alertController = UIAlertController(title: "There is bad or non-existent coordinate information for this facility", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.presentViewController(alert: alertController, animated: true, completion: nil)

            }
        }
    }
   
    private func presentViewController(alert: UIAlertController, animated flag: Bool, completion: (() -> Void)?) -> Void {
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: flag, completion: completion)
    }
    

    func configureView() {

        if let facility = self.facility  {
            
            let info = facility.Address! + "\n" + "Fee: " + facility.Fee! + "\n" + facility.Telephone! + "\n\n"  + facility.Desc!

            let camera = GMSCameraPosition.camera(withLatitude: self.lat!, longitude: self.lon!, zoom: 15.0)
            mapView = GMSMapView.map(withFrame: .zero, camera: camera)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lon!)
            marker.title = facility.F_Name!
            marker.snippet = info
            marker.map = mapView

        }  else  {
            let camera = GMSCameraPosition.camera(withLatitude: 40.8875, longitude: -72.3853, zoom: 15.0)
            mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        }

          mapView.delegate = self
          self.view = mapView
        
        
        //Add a segmented control for selecting the map type.
        let items = ["Normal", "Hybrid"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        
        let frame = UIScreen.main.bounds
        segmentedControl.frame = CGRect(x: frame.minX + 10, y: frame.minY + 65, width: 350, height: frame.height*0.05)
        segmentedControl.layer.cornerRadius = 10.0
        segmentedControl.addTarget(self, action: #selector(DetailViewController.mapType(_:)), for: UIControlEvents.valueChanged)
        segmentedControl.addTarget(self, action: #selector(DetailViewController.segColor(_:)), for: UIControlEvents.valueChanged)

        self.view.addSubview(segmentedControl)
    }
    

    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        //making a button
        let lbutton: UIButton = UIButton()
        lbutton.setImage(UIImage(named: "Contact.png"), for: .normal)
        lbutton.frame = CGRect(x: 0,y: 0, width: 35, height: 35)
        lbutton.target(forAction: #selector(DetailViewController.showContactEmail), withSender: self)
        lbutton.addTarget(self, action: #selector(DetailViewController.showContactEmail), for: UIControlEvents.touchUpInside)
        
        
        let rbutton: UIButton = UIButton()
        rbutton.setImage(UIImage(named: "Hotline.png"), for: .normal)
        rbutton.frame = CGRect(x: -80,y: 0, width: 40, height: 40)
        rbutton.target(forAction: #selector(DetailViewController.hotlineButtonTapped), withSender: self)
        rbutton.addTarget(self, action: #selector(DetailViewController.hotlineButtonTapped), for: UIControlEvents.touchUpInside)
        
        //making a UIBarbuttonItem on UINavigationBar
        let leftItem:UIBarButtonItem = UIBarButtonItem()
        leftItem.customView = lbutton
        
        let rightItem:UIBarButtonItem = UIBarButtonItem()
        rightItem.customView = rbutton

        self.navigationItem.setRightBarButtonItems([leftItem,rightItem], animated:true)
        self.navigationItem.setHidesBackButton(false, animated:true)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.configureView()

    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
        
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
        //print("prepare for presentation")
        
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        //print("did dismiss")
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        //print("should dismiss")
        
        return true
        
    }
 
    
    @IBAction func hotlineButtonTapped(_ sender: AnyObject) {
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "hotlineViewController")
        
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.preferredContentSize = CGSize(width: 400, height: 350)
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = (sender as! UIView)
        popController.popoverPresentationController?.sourceRect = sender.bounds
        
        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true

        self.locationManager.stopUpdatingLocation()

//        let last = locations.first
//        mapView.camera = GMSCameraPosition(target: (last?.coordinate)!, zoom: 15, bearing: 0, viewingAngle: 0)

    }

    
    func mapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = kGMSTypeNormal
        case 1:
            mapView.mapType = kGMSTypeHybrid
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
            sender.tintColor = UIColor.yellow
            sender.backgroundColor   = UIColor.orange
        default:
            sender.tintColor = UIColor.yellow
            sender.backgroundColor = UIColor.orange        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    
    func orientationChanged()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){

        }
        
    }

    func showContactEmail(sender:AnyObject)  {
        
        let url = URL(string: "mailto:southamptonyouthbureau@gmail.com")
        UIApplication.shared.openURL(url!)
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        // 1
//        let index:Int! = Int(marker.accessibilityLabel!)
        // 2
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        customInfoWindow.facilityName.text = facility.F_Name!
        customInfoWindow.facilityAddress.text = facility.Address!
        customInfoWindow.facilityCategory.text = facility.Category!
        customInfoWindow.facilityFee.text = facility.Fee!
        customInfoWindow.facilityDescription.text = facility.Desc!

        //        customInfoWindow.completedYearLbl.text = completedYear[index]
        return customInfoWindow
    }    
}


// MARK: - CLLocationManagerDelegate

extension DetailViewController: CLLocationManagerDelegate {
    
 
      @nonobjc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {

            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            self.locationManager.stopUpdatingLocation()
        }
        
    }
}





