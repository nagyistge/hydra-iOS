//
//  RestoSandwiches.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation
import ObjectMapper

@objc class RestoSandwich: NSObject, NSCoding, Mappable {
    var name: String
    var ingredients: [String]
    var priceSmall: String
    var priceMedium: String
    
    override convenience init() {
        self.init(name: "", ingredients: [], priceSmall: "", priceMedium: "")
    }
    
    init(name: String, ingredients: [String], priceSmall: String, priceMedium: String) {
        self.name = name
        self.ingredients = ingredients
        self.priceSmall = priceSmall
        self.priceMedium = priceMedium
    }

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.name <- map["name"]
        self.ingredients <- map["ingredients"]
        self.priceSmall <- map["price_small"]
        self.priceMedium <- map["price_medium"]
    }

    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObjectForKey("name") as? String,
              let ingredients = decoder.decodeObjectForKey("ingredients") as? [String],
              let priceSmall = decoder.decodeObjectForKey("priceSmall") as? String,
              let priceMedium = decoder.decodeObjectForKey("priceMedium") as? String
            else {return nil}
        
        self.init(name: name, ingredients: ingredients, priceSmall: priceSmall, priceMedium: priceMedium)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(ingredients, forKey: "ingredients")
        coder.encodeObject(priceSmall, forKey: "priceSmall")
        coder.encodeObject(priceMedium, forKey: "priceMedium")
    }
}