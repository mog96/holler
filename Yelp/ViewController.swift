//
//  ViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var searchBar = UISearchBar(frame: CGRect(x: 30, y: 8, width: 100, height: 20))
    
    var client: YelpClient!
    var businesses = NSArray()
    
    var selectedCategories = [NSMutableSet(), NSMutableSet(), NSMutableSet(), NSMutableSet()]
    
    let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
    let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
    let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
    let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()

        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        fetchBusinessesWithQuery("Restaurants", params: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        SVProgressHUD.dismiss()
    }
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell") as! BusinessCell
        
        var business = self.businesses[indexPath.row] as! Business
        
        cell.thumbnailImageView.setImageWithURL(NSURL(string: business.imageUrl))
        cell.nameLabel.text = business.name
        cell.distanceLabel.text = NSString(format: "%.2f mi", business.distance) as String
        cell.ratingImageView.setImageWithURL(NSURL(string: business.ratingImageUrl))
        cell.numReviewsLabel.text = NSString(format: "%ld Reviews", business.numReviews) as String
        cell.addressLabel.text = business.address
        cell.categoryLabel.text = business.categories
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Search Bar
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        fetchBusinessesWithQuery(searchBar.text, params: nil)
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // MARK: Actions
    
    @IBAction func onTap(sender: AnyObject) {
        self.view.endEditing(true)                  // NEED TO END SEARCHBAR EDITING, NOT VIEW
    }
    
    
    // MARK: Protocol implementations
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [NSMutableSet]) {
        self.selectedCategories = filters
        println("FILTER STRINGS \(formFilterString())")
        fetchBusinessesWithQuery("Restaurants", params: formFilterString())
    }
    
    // MARK: Private
    
    func formFilterString() -> NSDictionary {
        var filters = NSMutableDictionary();
        var i = 0
        for filterHeader in self.selectedCategories {
            if filterHeader.count > 0 {
                var names = NSMutableArray()
                for category in filterHeader {
                    names.addObject(category)
                }
                let categoryFilter = names.componentsJoinedByString(",")
                switch i {
                case 0:
                    filters.setObject(categoryFilter, forKey: "category_filter")
                case 1:
                    filters.setObject(categoryFilter, forKey: "sort")
                case 2:
                    filters.setObject(categoryFilter, forKey: "radius_filter")
                default:
                    filters.setObject(categoryFilter, forKey: "deals_filter")
                }
            }
            i++
        }
        return filters
    }
    
    func fetchBusinessesWithQuery(query: String, params: NSDictionary?) {
        client.searchWithTerm(query, params: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println(response)
            var buisnessDictionaries = response["businesses"] as! NSArray
            self.businesses = self.businessesWithDictionaries(buisnessDictionaries)
            self.tableView.reloadData()
            
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        })
    }
    
    func businessesWithDictionaries(dictionaries: NSArray) -> NSArray {
        var businesses = NSMutableArray()
        for dictionary in dictionaries {
            var business = Business(dictionary: dictionary as! NSDictionary)
            businesses.addObject(business)
        }
        return businesses
    }
    
    // MARK: Default
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowFilters" {
            let filtersNC = segue.destinationViewController as! UINavigationController
            let filtersVC = filtersNC.viewControllers[0] as! FiltersViewController
            filtersVC.delegate = self
            filtersVC.selectedCategories = selectedCategories
        }
    }
    
    
    
    // MARK: SCRAPS
    
    //        if self.selectedCategories.count > 0 {
    //
    //            var names = NSMutableArray()
    //            for category in self.selectedCategories {
    //                names.addObject(category)
    //            }
    //            let categoryFilter = names.componentsJoinedByString(",")
    //            filters.setObject(categoryFilter, forKey: "category_filter")
    //        }

}

