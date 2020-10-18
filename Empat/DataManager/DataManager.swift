//
//  DataManager.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    enum Status {
        case checked
        case unchecked
        case updated
        case error(error: Error?)
    }
    
    struct ItemExistanceModel {
        let isExist: Bool?
        let isError: Error?
        let isUpdated: Bool?
    }
    
    private var items: [Item]?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Empat")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    override init() {
        super.init()
        
    }
    
    func fetchItems() -> [SavedItem] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<SavedItem>(entityName: "SavedItem")
        let sectionSortDescriptor = NSSortDescriptor(key: "lastUpdate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch let err {
            print("failed to fetch nore folders:",err)
            return []
        }
    }
    
    private func saveNewFavourite(item: Item, comment: String?)  {
        let context = persistentContainer.viewContext
        let savedItem = NSEntityDescription.insertNewObject(forEntityName: "SavedItem", into: context) as! SavedItem
        savedItem.firstName = item.firstname
        savedItem.lastName = item.lastname
        savedItem.id = item.id
        savedItem.placeOfWork = item.placeOfWork
        savedItem.position = item.position
        if let comment = comment {
            savedItem.userComment = comment
        }
        savedItem.linkPDF = item.linkPDF
        savedItem.lastUpdate = item.lastUpdate
        do {
            try context.save()
        } catch let err {
            print("Failed to save new note folder:",err)
        }
    }
    
    private func getNoSpacingComment(comment: String?) -> String? {
        var noSpacingsComment = comment
        let whiteSpace: CharacterSet = CharacterSet.whitespacesAndNewlines
        let trimmed = comment?.trimmingCharacters(in: whiteSpace)
        if trimmed?.count == 0 {
            noSpacingsComment = nil
        }
        return noSpacingsComment
    }
    
    func checkItem(item: Item, comment: String?, completion: ((Status) -> Void)?) {
        
        let existanceModel: ItemExistanceModel = checkIfExist(item: item, comment: getNoSpacingComment(comment: comment))
        if let isExist = existanceModel.isExist {
            if isExist == false {
                saveNewFavourite(item: item, comment: getNoSpacingComment(comment: comment))
                completion?(.checked)
            } else {
                uncheckFav(item: item)
                completion?(.unchecked)
            }
        }
    }
    
    func uncheckFav(item: Item) {
        let existanceModel: ItemExistanceModel = checkIfExist(item: item, comment: "")
        if let isExist = existanceModel.isExist {
            if isExist == true {
                removeItem(itemId: item.id)
            }
        }
    }
    
    func checkIfExist(item: Item, comment: String?) -> ItemExistanceModel {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if results.count == 0 {
                return ItemExistanceModel(isExist: false, isError: nil, isUpdated: nil)
            }
            let resultItem = results.first as! SavedItem
            print(resultItem.userComment, comment )
            if resultItem.userComment != comment {
                return ItemExistanceModel(isExist: true, isError: nil, isUpdated: true)
            }
            return ItemExistanceModel(isExist: true, isError: nil, isUpdated: nil)
        } catch let error {
            return ItemExistanceModel(isExist: nil, isError: error, isUpdated: nil)
        }
    }
    
    func removeItem(itemId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", itemId)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                persistentContainer.viewContext.delete(objectData)
                try persistentContainer.viewContext.save()
            }
        } catch let error {
            print("Remove item \(itemId) in SavedItem entity error :", error)
        }
    }
    
    
    
    
    func alreadySaved(item: Item) -> Bool? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if results.count == 0 {
                return false
            }
            if  let _ = results.first as? SavedItem {
                return true
            }
            return nil
        } catch  {
            return nil
        }
    }
    
    
    enum UpdateStatus {
        case updated
        case noChanges
        case error
    }
    
    func updateFavouriteItem(id: String, comment: String, completion: ((UpdateStatus) -> Void)) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            
            let resultItem = results.first as! SavedItem
            
            if resultItem.userComment != getNoSpacingComment(comment: comment)  {
                updateComment(itemID: id, comment: comment)
                completion(.updated)
            } else {
                completion(.noChanges)
            }
        } catch {
            completion(.error)
        }
    }
    
    func  updateComment(itemID: String, comment: String?)  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", itemID)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            let savedItem = results.first as! SavedItem
            savedItem.setValue(getNoSpacingComment(comment: comment), forKey: "userComment")
            savedItem.setValue(Date(), forKey: "lastUpdate")
            try persistentContainer.viewContext.save()
        } catch {
            print("Error update with comment", comment, "for id: \(itemID)")
        }
    }
    
    func deleteAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                persistentContainer.viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in SavedItem entity error :", error)
        }
    }
    
    func getRequest(searchText: String, completion: @escaping (([Item]) -> Void)) {
        
        NetworkService.performRequest(querry: searchText, cahcePolicy: .reloadIgnoringLocalAndRemoteCacheData) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                print(data)
                
                do {
                    let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
                    if let items = searchResults.items {
                        completion(items)
                    } else {
                        completion([])
                    }
                } catch {
                    let nserror = error as NSError
                    print("Decoding error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}



