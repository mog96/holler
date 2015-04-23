//
//  Business.swift
//  Yelp
//
//  Created by Mateo Garcia on 4/20/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject {
    
    var imageUrl: String
    var name: String
    var ratingImageUrl: String
    var numReviews: Int
    var address: String
    var categories: String
    var distance: CGFloat
    
    init(dictionary: NSDictionary) {
        var categories = dictionary["categories"] as! NSArray
        var categoryNames = NSMutableArray()
        categories.enumerateObjectsUsingBlock { (object, index, stop) -> Void in
            categoryNames.addObject(object[0])
        }
        
        // INSERT CHECKS TO MAKE SURE URL IS VALID
        
        self.categories = categoryNames.componentsJoinedByString(", ")
        
        println("CATEGORES \(self.categories)")
        
        self.name = dictionary["name"] as! String
        var imageUrl = dictionary["image_url"] as? String?
        if let unwrappedUrl = imageUrl! {
            self.imageUrl = unwrappedUrl
        } else {
            self.imageUrl = ""
        }
        
        var streetArray = dictionary.valueForKeyPath("location.address") as! NSArray
        var street: String
        if streetArray.count != 0 {
            street = streetArray[0] as! String
        } else {
            street = ""
        }
        
        var neighborhoodArray = dictionary.valueForKeyPath("location.neighborhoods") as? NSArray?
        var neighborhood: String
        if let neighborhoodArrayUnwrapped = neighborhoodArray! {
            neighborhood = neighborhoodArrayUnwrapped[0] as! String
        } else {
            neighborhood = ""
        }
        
        if street == "" && neighborhood == "" {
            self.address = ""
        } else if street == "" && neighborhood != "" {
            self.address = neighborhood
        } else if street != "" && neighborhood == "" {
            self.address = street
        } else {
            self.address = NSString(format: "%@, %@", street, neighborhood) as String
        }
        
        self.numReviews = dictionary["review_count"] as! Int
        self.ratingImageUrl = dictionary["rating_img_url"] as! String
        var milesPerMeter = CGFloat(0.000621371)
        var rawDistance = dictionary["distance"] as! CGFloat
        self.distance = rawDistance * milesPerMeter
    }
}
