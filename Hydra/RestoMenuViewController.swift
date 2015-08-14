//
//  RestoMenuViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var days: [NSDate] = []
    var menus: [RestoMenu?] = []
    var legend: [RestoLegendItem] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "reloadMenu", name: RestoStoreDidReceiveMenuNotification, object: nil)
        center.addObserver(self, selector: "reloadInfo", name: RestoStoreDidUpdateInfoNotification, object: nil)
        center.addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        days = calculateDays()
        reloadMenu()
        reloadInfo()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func reloadMenu() {
        // New menus are available
        let store = RestoStore.sharedStore()
        var menus = [RestoMenu?]()
        for day in days {
            let menu = store.menuForDay(day) as RestoMenu?
            menus.append(menu)
        }
        self.menus = menus
        
        //TODO: reload collectionview cells
    }
    
    func reloadInfo() {
        // New info is available
        self.legend = (RestoStore.sharedStore().legend as? [RestoLegendItem])!
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        let firstDay = self.days[0]
        self.days = self.calculateDays()
        
        if !firstDay.isEqualToDateIgnoringTime(self.days[0]) {
            self.reloadMenu()
        }
    }
    
    func calculateDays() -> [NSDate] {
        // Find the next x days to display
        var day = NSDate()
        var days = [NSDate]()
        while (days.count < 5) { //TODO: replace with var
            if day.isTypicallyWorkday() {
                days.append(day)
            }
            day = day.dateByAddingDays(1)
        }
        return days
    }
}

extension RestoMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.days.count + 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0: // info cell
            return collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)
        case 1...self.days.count:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("restoMenuOpenCell", forIndexPath: indexPath) as! RestoMenuCollectionCell
            
            cell.restoMenu = self.menus[indexPath.row-1]
            return cell
        case self.days.count + 1: // map cell
            return collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)
        default:
            debugPrint("Shouldn't be here")
            return collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height) // cells always fill the whole screen
    }
}