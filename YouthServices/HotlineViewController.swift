//
//  HotlineViewController.swift
//  YouthServices
//
//  Created by Southampton Dev on 10/17/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit

class HotlineViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func showHotlineWebsite(_ sender: UIButton) {
        
        if let website = sender.title(for: .normal) {
            if let url:URL = URL(string: "http://" + website) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func showHotlineTel(_ sender: UIButton) {
        
         if let phone = sender.title(for: .normal) {
            if let url:URL = URL(string: "tel://" + phone) {
                UIApplication.shared.open(url)
            }
        }       
    }

    @IBAction func showSpanishHotlineTel(_ sender: UIButton) {
        
        if let phone = sender.title(for: .normal) {
            if let url:URL = URL(string: "tel://" + phone) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func showLifelineTel(_ sender: UIButton) {
        
        if sender.title(for: .normal) != nil {
            if let url:URL = URL(string: "tel://800-273-8255") {
                UIApplication.shared.open(url)
            }
        }
    }

    @IBAction func showSpanishLifelineTel(_ sender: UIButton) {
        
        if let phone = sender.title(for: .normal) {
            if let url:URL = URL(string: "tel://" + phone) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func showChildAbuseTel(_ sender: UIButton) {
        
        if let phone = sender.title(for: .normal) {
            if let url = URL(string: "tel://" + phone) {
                UIApplication.shared.open(url)
            }
        }
    }
 
    @IBAction func showSubstanceAbuseTel(_ sender: UIButton) {
        
        if let phone = sender.title(for: .normal) {
            if let url = URL(string: "tel://" + phone) {
                UIApplication.shared.open(url)
            }
        }
    }
}
