//
//  TagManagementViewControllerModel.swift
//  Remember
//
//  Created by Songbai Yan on 2018/4/21.
//  Copyright © 2018 Songbai Yan. All rights reserved.
//

import Foundation

class TagManagementViewControllerModel {
    private var tagStorage: TagStorage!
    private var thingTagStorage: ThingTagStorage!
    
    init(tagStorage: TagStorage, thingTagStorage: ThingTagStorage) {
        self.tagStorage = tagStorage
    }
    
    func deleteTag(_ tag: TagModel) {
        tagStorage.delete(tag)
        let thingTags = thingTagStorage.findThingTagsBy(tagId: tag.id)
        for thingTag in thingTags {
            thingTagStorage.delete(for: thingTag)
        }
    }
    
    func getAllTags() -> [TagModel] {
        return tagStorage.findAll()
    }
}
