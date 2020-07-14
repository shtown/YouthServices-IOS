//
//  CalendarViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 2/28/17.
//  Copyright © 2017 TOS. All rights reserved.
//

import UIKit


class CalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func showSagOnline(_ sender: UIButton) {

       if let url:URL = URL(string: "http://sagharboronline.com/hamptons-events") {
                UIApplication.shared.open(url)
        }
       
    }
    
    @IBAction func show27East(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://www.27east.com/hamptons-events-calendar/") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showMacaroniKid(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://hamptons.macaronikid.com/calendar/") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showHamptonsCom(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://www.hamptons.com/calendar") {
            UIApplication.shared.open(url)
        }
        
    }

    @IBAction func showMommyPoppins(_ sender: UIButton) {
        
        if let url:URL = URL(string: "https://mommypoppins.com/events?area%5B%5D=116") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showSagHarborKids(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://www.sagharborkids.org") {
            UIApplication.shared.open(url)
        }
        
    }


    @IBAction func showEastEndLocal(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://eastendlocal.com/events/") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showDansPapers(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://events.danspapers.com/events/") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showLongIslandBrowser(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://www.longislandbrowser.com/community/events/") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showPatch(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://patch.com/new-york/westhampton-hamptonbays/calendar") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func showNewsday(_ sender: UIButton) {
        
        if let url:URL = URL(string: "http://www.newsday.com/entertainment/long-island-events") {
            UIApplication.shared.open(url)
        }
        
    }
 }
