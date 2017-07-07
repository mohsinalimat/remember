//
//  ThingEntity+CoreDataClass.swift
//  Remember
//
//  Created by Songbai Yan on 06/07/2017.
//  Copyright © 2017 Songbai Yan. All rights reserved.
//

import Foundation
import CoreData

public class ThingEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThingEntity> {
        return NSFetchRequest<ThingEntity>(entityName: "Thing")
    }
    
    @NSManaged public var content: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var index: Int32
    @NSManaged public var thingTag: NSSet?
}

extension ThingEntity {
    
    @objc(addThingTagObject:)
    @NSManaged public func addToThingTag(_ value: ThingTagEntity)
    
    @objc(removeThingTagObject:)
    @NSManaged public func removeFromThingTag(_ value: ThingTagEntity)
    
    @objc(addThingTag:)
    @NSManaged public func addToThingTag(_ values: NSSet)
    
    @objc(removeThingTag:)
    @NSManaged public func removeFromThingTag(_ values: NSSet)
    
}
