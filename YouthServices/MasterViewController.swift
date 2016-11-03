//
//  MasterViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 9/15/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit
import CoreLocation
import DropDown

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class MasterViewController: UITableViewController, CLLocationManagerDelegate {

    var facilityStore: FacilityStore!
    var facilities = [Facility]();
    var filteredFacilities = [Facility]()
    var tapGestureRecognizer: UITapGestureRecognizer!
    var isFiltered:Bool = true
    
    let townDropDown = DropDown()
    let serviceDropDown = DropDown()

    let locationManager = CLLocationManager()
    var currLocation: CLLocation?
    
    var selectedService: String = "All Services"
    var selectedTown: String = "All Towns"
    
    let searchController = UISearchController(searchResultsController:nil)

    
    var detailViewController: DetailViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let tdd = UIBarButtonItem(title: "All Towns", style: .plain, target: self, action: #selector(townListTapped))
        let sdd = UIBarButtonItem(title: "All Services", style: .plain, target: self, action: #selector(serviceListTapped))
        
        navigationItem.rightBarButtonItem = sdd
        navigationItem.leftBarButtonItem = tdd
        
        
        townDropDown.anchorView = tdd
        townDropDown.dataSource = ["All Towns", "East Hampton", "Riverhead", "Shelter Island", "Southampton", "Southold"]

        serviceDropDown.anchorView = sdd
        serviceDropDown.dataSource = ["All Services", "Cultural", "Recreation", "Volunteer", "Religious", "Employment",
        "Education/Tutoring", "Domestic Violence", "Child Abuse", "Substance Abuse", "Mental Health", "Adolescent Health",
        "Sports", "Daycare", "Counseling"]


        serviceDropDown.selectionAction = { (index: Int, item: String) in
            sdd.title = item
            self.selectedService = item
            self.filterOnSelectionChanged(selectedTown: self.selectedTown, selectedService: self.selectedService)
        }
        
        townDropDown.selectionAction = { (index: Int, item: String) in
            tdd.title = item
            self.selectedTown = item
            self.filterOnSelectionChanged(selectedTown: self.selectedTown, selectedService: self.selectedService)
        }
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
        getFacilities()

    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowService"  {
            
            
            if let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row  {
                let facilityDetail: Facility
                
                if(selectedTown != "All Towns" || selectedService != "All Services")  {
                    facilityDetail = filteredFacilities[row]
                } else {
                    facilityDetail = facilities[row]
                }
                
                let detailViewController = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                detailViewController.facility = facilityDetail
                detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {


        if(selectedTown != "All Towns" || selectedService != "All Services")  {
             return filteredFacilities.count
        }
        return facilities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        let facility: Facility
        
        cell.updateLabels()
        
        if(selectedTown != "All Towns" || selectedService != "All Services")  {
            facility = filteredFacilities[(indexPath as NSIndexPath).row]
            isFiltered = true
        }
        else  {
            facility = facilities[(indexPath as NSIndexPath).row]
            isFiltered = false
        }
        
        cell.distanceView?.text = String(format: "%.1f", facility.DistFromCenter!) + " mile(s)"
        cell.titleView?.text = facility.F_Name
        cell.addressView?.text = facility.Address

        let browserLaunchImage = cell.launchBrowserIcon
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(MasterViewController.browserLaunchImageTapped(_:)))
        browserLaunchImage?.isUserInteractionEnabled = true
        browserLaunchImage?.addGestureRecognizer(tapGestureRecognizer)
        
        let emailLaunchImage = cell.launchEmailIcon
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(MasterViewController.emailLaunchImageTapped(_:)))
        emailLaunchImage?.isUserInteractionEnabled = true
        emailLaunchImage?.addGestureRecognizer(tapGestureRecognizer)
        
        
        let phoneLaunchImage = cell.launchTelIcon
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(MasterViewController.phoneLaunchImageTapped(_:)))
        phoneLaunchImage?.isUserInteractionEnabled = true
        phoneLaunchImage?.addGestureRecognizer(tapGestureRecognizer)
        
        let directionsLaunchImage = cell.launchDirectionsIcon
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(MasterViewController.directionsLaunchImageTapped(_:)))
        directionsLaunchImage?.isUserInteractionEnabled = true
        directionsLaunchImage?.addGestureRecognizer(tapGestureRecognizer)
        

        return cell
    }
    
    func getFacilities()  {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        facilityStore.fetchFacilities()  {
            (facilitiesResult) -> Void in
            
            switch facilitiesResult {
            case let .success(facilities):
                OperationQueue.main.addOperation {
                    self.facilities = self.getSortedByDistance(facilities)
                }
            case let .failure(error):
                print ("Error fetching facilities: \(error)")
                let alertController = UIAlertController(title: "Error fetching facilities: Please check your wireless settings", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            self.do_table_refresh()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    func filterOnSelectionChanged(selectedTown: String, selectedService: String) {

        filteredFacilities = facilities.filter { facility in
            if (selectedService == "All Services" || facility.Category!.lowercased().contains(selectedService.lowercased())) {
                if (selectedTown == "All Towns" || selectedTown.lowercased() == facility.Hamlet!.lowercased())  {
                    return true
                }
            }
            return false
        }

        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
 
    
    func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    func townListTapped()  {
        townDropDown.show()
    }
    
    func serviceListTapped()  {
        serviceDropDown.show()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        // Get user's current location
        self.currLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        self.locationManager.stopUpdatingLocation()

    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        getFacilities()
    }
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError)  {
        print ("Errors:  " + error.localizedDescription)
    }
    
 
    func getSortedByDistance(_ facilities: [Facility]) -> [Facility] {
        
        
        for object in facilities  {
            let lat = object.Lat!
            let lon = object.Lon!
            
            if let x = Double(lon),
                let y = Double(lat),
                let origin = self.currLocation
            {
                let facLocation = CLLocation(latitude: y, longitude: x)
                let distanceBetween: CLLocationDistance = facLocation.distance(from: origin)
                
                object.DistFromCenter = distanceBetween/1609.344
            }  else  {
                object.DistFromCenter = 0
            }
        }
        
        return facilities.sorted { $0.DistFromCenter < $1.DistFromCenter }
    }
    
   
    func directionsLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var facility: Facility!

        let touch = sender.location(in: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: touch) {
            if(isFiltered)  {
                facility = filteredFacilities[(indexPath as NSIndexPath).row]
            } else  {
                facility = facilities[(indexPath as NSIndexPath).row]
            }

            let coords = (self.currLocation?.coordinate.latitude.description)! + ","  + (self.currLocation?.coordinate.longitude.description)!

            if facility.Lat! != "" && facility.Lon! != ""{

                let url:URL = URL(string: "https://www.google.com/maps/dir/" + coords + "/" + facility.Lat! + "," + facility.Lon!)!
                UIApplication.shared.openURL(url)
                
            } else {
                
                let alertController = UIAlertController(title: "Coordinates Not Supplied", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
  
    func phoneLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var phone: String!
        var facility: Facility!
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            if(isFiltered) {
                facility = filteredFacilities[(indexPath as NSIndexPath).row]
            } else {
                facility = facilities[(indexPath as NSIndexPath).row]
            }
            
            if facility.Telephone! != "" {
                
                phone = facility.Telephone!
                phone = phone.replacingOccurrences(of: " " , with: "")
                phone = phone.replacingOccurrences(of: "(" , with: "")
                phone = phone.replacingOccurrences(of: ")" , with: "")
                phone = phone.replacingOccurrences(of: "-" , with: "")
                
                let url:URL = URL(string: "tel://" + phone)!
                UIApplication.shared.openURL(url)
                
            } else {
                
                let alertController = UIAlertController(title: "Phone Number Not Supplied", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func emailLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var email: String!
        var facility: Facility!
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            if(isFiltered) {
                facility = filteredFacilities[(indexPath as NSIndexPath).row]
            } else {
                facility = facilities[(indexPath as NSIndexPath).row]
            }

            if facility.Email! != "" {
                email = facility.Email!
                
                let url = URL(string: "mailto:\(email!)")
                UIApplication.shared.openURL(url!)
                
            } else {
                
                let alertController = UIAlertController(title: "Email Address Not Supplied", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }

    
    func browserLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var website: String!
        var facility: Facility!
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            if (isFiltered)  {
                facility = filteredFacilities[(indexPath as NSIndexPath).row]
            } else {
                facility = facilities[(indexPath as NSIndexPath).row]
            }
            
            if facility.WebLink! != ""  {
                website = facility.WebLink!
            } else {
                website = "http://www.southamptontownny.gov"
            }
        }
        
        if let url = URL(string: website) {
            UIApplication.shared.openURL(url)
        }
    }
    

    func filteredContentForSearchText(_ searchText: String, scope: String = "All")  {

        filteredFacilities = facilities.filter { facility in
            let typeMatch = (scope == "All") || (facility.Hamlet! == scope)
            print (facility.Address!.lowercased() + "=> " + searchText.lowercased())
            return typeMatch && facility.Address!.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
}

extension MasterViewController: UISearchResultsUpdating  {

    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filteredContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension MasterViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)  {
        
        filteredContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


