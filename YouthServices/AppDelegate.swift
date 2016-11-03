//
//  AppDelegate.swift
//  YouthServices
//
//  Created by Southampton Dev on 9/15/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit
import GoogleMaps
import DropDown

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.brown]
        
        GMSServices.provideAPIKey("AIzaSyDsKjAOaAUFgLH6d_qFaKYKf1nNkV66exw")
        
        let facilityStore = FacilityStore()
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        let listNavController = splitViewController.viewControllers[0] as! UINavigationController
        let serviceListController = listNavController.topViewController as! MasterViewController
        
        serviceListController.facilityStore = facilityStore

        
        splitViewController.delegate = self
        DropDown.startListeningToKeyboard()
 
        return true
    }

 
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.facility == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

