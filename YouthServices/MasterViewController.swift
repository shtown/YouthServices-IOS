//
//  MasterViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 9/15/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit
import CoreLocation
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
    
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController:nil)
    
    
    var currLocation: CLLocation?
    
    var detailViewController: DetailViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // GPS
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 65
        
        // Start network activity indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        facilityStore.fetchFacilities()  {
            (facilitiesResult) -> Void in
            
            switch facilitiesResult {
            case let .success(facilities):
                OperationQueue.main.addOperation {
                    self.facilities = self.getSortedByDistance(facilities)
                    print ("Successfully found \(facilities.count) Youth Service facilities")
                }
            case let .failure(error):
                print ("Error fetching facilities: \(error)")
            }
            
            self.do_table_refresh()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.scopeButtonTitles = ["All", "East Hampton", "Riverhead", "Shelter Island", "Southampton", "Southold"]
        searchController.searchBar.delegate = self
        
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
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
                
                if searchController.isActive && searchController.searchBar.text != "" {
                    facilityDetail = filteredFacilities[row]
                } else {
                    facilityDetail = facilities[row]
                }
                
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.facility = facilityDetail
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        let facility: Facility
        
        cell.updateLabels()
        var tapGestureRecognizer: UITapGestureRecognizer!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            facility = filteredFacilities[(indexPath as NSIndexPath).row]
        } else {
            facility = facilities[(indexPath as NSIndexPath).row]
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
        let touch = sender.location(in: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: touch) {
            let facility = facilities[(indexPath as NSIndexPath).row]
            if facility.Lat! != "" && facility.Lon! != ""{
                
                
                let url:URL = URL(string: "https://www.google.com/maps/dir/Current+Location/" + facility.Lat! + "," + facility.Lon!)!
                UIApplication.shared.openURL(url)
                
            } else {
                
                let alertController = UIAlertController(title: "Coordinates Not Supplied", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }    }
    
    func phoneLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var phone: String!
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            let facility = facilities[(indexPath as NSIndexPath).row]
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
                    NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func emailLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var email: String!
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            let facility = facilities[(indexPath as NSIndexPath).row]
            if facility.Email! != "" {
                email = facility.WebLink!
                
                let url = URL(string: "mailto:\(email)")
                UIApplication.shared.openURL(url!)
                
            } else {
                
                let alertController = UIAlertController(title: "Email Address Not Supplied", message: "Click OK to continue", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func browserLaunchImageTapped(_ sender: UITapGestureRecognizer)  {
        
        var website: String!
        
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            let facility = facilities[(indexPath as NSIndexPath).row]
            if facility.WebLink! != "" {
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
            print (typeMatch, scope, facility.Hamlet!, searchText.lowercased())
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


