//
//  Trend.swift
//  Inhalt
//
//  Created by digvijay.s on 13/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class Trend: NSManagedObject {
    static func create(named trendName: String, in context: NSManagedObjectContext) {
        let trend = Trend(context: context)
        trend.title = trendName
    }
    
    static func get(in context: NSManagedObjectContext) -> [Trend] {
        let request: NSFetchRequest<Trend> = Trend.fetchRequest()
        do {
            let trends = try context.fetch(request)
            return trends
        }
        catch {
            print(error.localizedDescription)
        }
        
        return []
    }
}
