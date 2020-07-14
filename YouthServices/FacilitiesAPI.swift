//
//  FacilitiesAPI.swift
//  YouthServices
//
//  Created by Southampton Dev on 7/22/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import Foundation

enum FacilitiesResult  {
    case success([Facility])
    case failure(Error)
}

enum FacilitiesError: Error {
    case invalidJSONData
}

struct FacilitiesAPI  {
    
    fileprivate static let baseURLString = "https://gis.southamptontownny.gov/youthservices/getyouthservicesjson.ashx"
    
    fileprivate static let dateFormatter: DateFormatter =  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    fileprivate static func facilityFromJSONObject(_ json: [String: AnyObject]) -> Facility?  {
        
        guard let
            
            name = json["F_Name"] as? String,
            let addr  = json["Address"] as? String,
            let phone = json["Phone1"] as? String,
            let url = json["WebLink"] as? String,
            let fee = json["Fee"] as? String,
            let lat = json["Lat"] as? String,
            let lon = json["Lon"] as? String,
            let cat = json["category"] as? String,
            let hamlet = json["Township"] as? String,
            let email =  json["Email"] as? String,
            let description = json["Desc"] as? String else {
                return nil
        }
     
        
        return Facility(F_Name:name, Desc:description,  Address:addr, Telephone: phone, WebLink: url, Fee: fee, Lat: lat, Lon: lon, Category: cat, Hamlet: hamlet, Email: email, DistFromCenter: 0.0)
    }
    
    
    static func facilitiesURL() -> URL  {
        
        var components = URLComponents(string: baseURLString)!
        
        let queryItems = [URLQueryItem]()
        
        components.queryItems = queryItems
        
        return components.url!
    }
    
    
    static func facilitiesFromJSONData(_ data: Data) -> FacilitiesResult  {
        
        do {

            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let facilities = jsonDictionary["services"] as? [String:AnyObject],
                let facilitiesArray = facilities["service"] as? [[String:AnyObject]] else {
                    return .failure(FacilitiesError.invalidJSONData)
            }
            
            var finalFacilities = [Facility]()
            for facilityJSON in facilitiesArray  {
                
                if let facility = facilityFromJSONObject(facilityJSON)  {
                    
                    finalFacilities.append(facility)
                }
            }
            
            if finalFacilities.count == 0 && facilitiesArray.count > 0  {
                
                return .failure(FacilitiesError.invalidJSONData)
            }
            
            return .success(finalFacilities)
        }
        catch let error {
            return .failure(error)
        }
    }
}
