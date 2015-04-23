//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Mateo Garcia on 4/20/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [NSMutableSet])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: FiltersViewControllerDelegate?
    
    var selectedCategories = [NSMutableSet(), NSMutableSet(), NSMutableSet(), NSMutableSet()]
    
    let filterHeaders = [("CATEGORIES", "category_filter"), ("SORT BY", "sort"), ("RADIUS", "radius_filter"), ("DEALS", "deals_filter")]
    
    let categories = [("Nightlife", "nightlife"), ("Real Estate", "realestate"), ("Religious Organizations", "religiousorgs"), ("Shopping", "shopping")]
    let sorts = [("Best Match", 0), ("Distance", 1), ("Highest Rated", 2)]
    let radii = [(".3 miles", 482.8032), ("1 mile", 1609.34), ("5 miles", 8046.72), ("20 miles", 32186.9)]
    let deals = [("Only show deals", true)]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // self.tableView.registerClass(SwitchCell, forCellReuseIdentifier: CellIdentifier)
        // self.tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    // MARK: Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return filterHeaders.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return categories.count
        case 1:
            return sorts.count
        case 2:
            return radii.count
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        
        cell.delegate = self  // NECESSARY for SwitchCellDelegate protocol to work!
        
        switch indexPath.section {
        case 0:  // Category
            println(self.selectedCategories[indexPath.section])
            cell.categorySwitch.on = self.selectedCategories[indexPath.section].containsObject(self.categories[indexPath.row].1)
            cell.categorySwitchLabel!.text = self.categories[indexPath.row].0
        case 1:  // Sort by
            cell.categorySwitch.on = self.selectedCategories[indexPath.section].containsObject(self.sorts[indexPath.row].1)
            cell.categorySwitchLabel!.text = self.sorts[indexPath.row].0
        case 2:  // Radius
            cell.categorySwitch.on = self.selectedCategories[indexPath.section].containsObject(self.radii[indexPath.row].1)
            cell.categorySwitchLabel!.text = self.radii[indexPath.row].0
        default: // Deals
            cell.categorySwitch.on = self.selectedCategories[indexPath.section].containsObject(self.deals[indexPath.row].1)
            cell.categorySwitchLabel!.text = self.deals[indexPath.row].0
        }
        
//        let switchState = cellStates[indexPath.row]
//        if let state = switchState {                // if there's a value for switch's state
//            cell.filterSwitch.on = state
//        } else {
//            cell.filterSwitch.on = false            // default value is false for all categories
//            cellStates[indexPath.row] = false
//        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40.0))
        headerView.backgroundColor = UIColor.redColor()
        var headerViewLabel = UILabel(frame: CGRect(x: 8, y: -3, width: tableView.frame.width, height: 30.0))
        headerViewLabel.text = self.filterHeaders[section].0
        headerViewLabel.textColor = UIColor.whiteColor()
        headerView.insertSubview(headerViewLabel, atIndex: 0)
        // headerView.sizeToFit()
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Switch Cell protocol implementation
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        if value {
            switch indexPath.section {
            case 0:
                self.selectedCategories[indexPath.section].addObject(self.categories[indexPath.row].1)
            case 1:
                var i = 0
                for category in selectedCategories[indexPath.section] {
                    self.selectedCategories[indexPath.section].removeObject(category)
                }
                self.selectedCategories[indexPath.section].addObject(self.sorts[indexPath.row].1)
            case 2:
                var i = 0
                for category in selectedCategories[indexPath.section] {
                    self.selectedCategories[indexPath.section].removeObject(category)
                }
                self.selectedCategories[indexPath.section].addObject(self.radii[indexPath.row].1)
            default:
                self.selectedCategories[indexPath.section].addObject(self.deals[indexPath.row].1)
            }
        } else {
            switch indexPath.section {
            case 0:
                self.selectedCategories[indexPath.section].removeObject(self.categories[indexPath.row].1)
            case 1:
                self.selectedCategories[indexPath.section].removeObject(self.sorts[indexPath.row].1)
            case 2:
                self.selectedCategories[indexPath.section].removeObject(self.radii[indexPath.row].1)
            default:
                self.selectedCategories[indexPath.section].removeObject(self.deals[indexPath.row].1)
            }
        }
    }
    
    // MARK: Default

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchButtonPressed(sender: UIBarButtonItem) {
        delegate?.filtersViewController?(self, didUpdateFilters: selectedCategories) // send dictionary to protocol implementers to save state of user filters
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    // Mark: SCRAPS
    
    // let categories = [(name: "Nightlife", code: "nightlife"), (name: "Real Estate", code: "realestate"), (name: "Religious Organizations", code: "religiousorgs"), (name: "Shopping", code: "shopping")]
    
    // let filters = [(("Categories", "category_filter"), [(name: "Nightlife", code: "nightlife"), (name: "Real Estate", code: "realestate"), (name: "Religious Organizations", code: "religiousorgs"), (name: "Shopping", code: "shopping")]), (("Sort by", "sort"), [("Best Match", 0), ("Distance", 1), ("Highest Rated", 2)]), (("Radius", "radius_filter"), [(".3 miles", 482.8032), ("1 mile", 1609.34), ("5 miles", 8046.72), ("20 miles", 32186.9)]), (("Deals", "deals_filter"), [("Only show deals", "1")])]
    
    // let filters = [("Categories", ["Nightlife", "Real Estate", "Religious Organizations", "Shopping"]), ("Sort by", ["Best Match", "Distance", "Highest Rated"]), ("Distance", [".3 miles", "1 mile", "5 miles", "20 miles"]), ("Other", ["Deals"])]


}
