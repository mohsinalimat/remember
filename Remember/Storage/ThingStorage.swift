//
//  ThingRepository.swift
//  Remember
//
//  Created by Songbai Yan on 21/12/2016.
//  Copyright © 2016 Songbai Yan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ThingStorage {
    
    func getThings() -> [ThingModel] {
        return getThingsFromLocalDB()
    }
    
    func create(_ thing: ThingModel) {
        createAndSaveThingInLocalDB(thing: thing)
    }
    
    func delete(_ thing: ThingModel) {
        deleteThing(by: thing.id)
    }
    
    func edit(_ thing: ThingModel) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Thing")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let entity = NSEntityDescription.entity(forEntityName: "Thing", in: appDelegate.persistentContainer.viewContext)
        request.entity = entity
        let predicate = NSPredicate(format: "%K == %@", "id", thing.id!)
        request.predicate = predicate
        do {
            if let results = try appDelegate.persistentContainer.viewContext.fetch(request) as? [NSManagedObject] {
                for result in results {
                    result.setValue(thing.content, forKey: "content")
                    appDelegate.saveContext()
                }
            }
        } catch {
            
        }
    }
    
    func save(sorted things: [ThingModel]) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Thing")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let entity = NSEntityDescription.entity(forEntityName: "Thing", in: appDelegate.persistentContainer.viewContext)
        request.entity = entity
        for thing in things {
            let predicate = NSPredicate(format: "%K == %@", "id", thing.id!)
            request.predicate = predicate
            do {
                if let results = try appDelegate.persistentContainer.viewContext.fetch(request) as? [NSManagedObject] {
                    for result in results {
                        result.setValue(thing.index, forKey: "index")
                    }
                }
            } catch {
                
            }
        }
        appDelegate.saveContext()
    }
    
    private func deleteThing(by thingId: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Thing")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let entity = NSEntityDescription.entity(forEntityName: "Thing", in: appDelegate.persistentContainer.viewContext)
        request.entity = entity
        let predicate = NSPredicate(format: "%K == %@", "id", thingId)
        request.predicate = predicate
        do {
            if let results = try appDelegate.persistentContainer.viewContext.fetch(request) as? [NSManagedObject] {
                for result in results {
                    appDelegate.persistentContainer.viewContext.delete(result)
                    appDelegate.saveContext()
                }
            }
        } catch {
            
        }
    }
    
    private func createAndSaveThingInLocalDB(thing: ThingModel) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let object: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "Thing", into: viewContext)
        object.setValue(thing.content, forKey: "content")
        object.setValue(thing.createdAt, forKey: "createdAt")
        object.setValue(thing.id, forKey: "id")
        object.setValue(thing.index, forKey: "index")
        appDelegate.saveContext()
    }
    
    private func getThingsFromLocalDB() -> [ThingModel] {
        var things = [ThingModel]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Thing")
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let results = try appDelegate.persistentContainer.viewContext.fetch(request) as? [ThingEntity] {
                if !results.isEmpty {
                    for result in results {
                        things.append(result.toModel())
                    }
                }
            }
        } catch {
        }
        
        things.sort { $0.index < $1.index }
        
        return things
    }
}
