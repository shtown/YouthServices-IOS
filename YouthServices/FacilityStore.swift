//
//  FacilityStore.swift
//  GEER
//
//  Created by Southampton Dev on 8/8/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit


class FacilityStore  {
  
  
  var allFacilities = [Facility]()
  
  
  func processFacilitiesRequest(data: Data?, error: NSError?) -> FacilitiesResult {
    
    guard let jsonData = data else  {
      return .failure(error!)
    }
    
    return FacilitiesAPI.facilitiesFromJSONData(jsonData)
  }
  
  
  let session: URLSession = {
    
    let config = URLSessionConfiguration.default
    return URLSession(configuration: config)
    
  }()
  
  func fetchFacilities(completion: @escaping (FacilitiesResult) -> Void)  {
    
    let url = FacilitiesAPI.facilitiesURL()
    let request = URLRequest(url: url as URL)
    let task = session.dataTask(with: request, completionHandler: {
      (data, response, error)  -> Void in
      
      let result = self.processFacilitiesRequest(data: data, error: error as NSError?)
      completion(result)
      
    })  

    task.resume()
  }
  
}
