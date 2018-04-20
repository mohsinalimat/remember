//
//  SearchService.swift
//  Remember
//
//  Created by Songbai Yan on 24/07/2017.
//  Copyright © 2017 Songbai Yan. All rights reserved.
//

import Foundation

class SearchService {
    private let thingStorage = ThingStorage(context: CoreStorage.shared.persistentContainer.viewContext)
    
    private(set) var things = [ThingModel]()
    
    init() {
        things = thingStorage.findAll()
    }
    
    func getThings(byTag tag: String) -> [ThingModel] {
        let thingTagStorage = ThingTagStorage()
        let tagStorage = TagStorage(context: CoreStorage.shared.persistentContainer.viewContext)
        var filteredThings = [ThingModel]()
        if let tagModel = tagStorage.find(by: tag) {
            let thingTags = thingTagStorage.getThingTags(by: tagModel)
            let thingTagIds = thingTags.map({$0.thingId!})
            filteredThings = things.filter { (thing) -> Bool in
                return thingTagIds.contains(thing.id)
            }
        }
        return filteredThings
    }
    
    func getThings(byText searchText: String) -> [ThingModel] {
        let filteredThings = self.things.filter({ (thing) -> Bool in
            return thing.content.contains(searchText)
        })
        return filteredThings
    }
}
