//
//  DataManager.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<SavedItem> = {
        let fetchRequest: NSFetchRequest<SavedItem> = SavedItem.fetchRequest()
        //                fetchRequest.fetchBatchSize = 30
        let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
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
//        fetchRequest.fetchBatchSize = 20
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
    
    
    private func updateComment(item: Item, comment: String?)  {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            let savedItem = results.first as! SavedItem
            savedItem.setValue(comment, forKey: "userComment")
            savedItem.setValue(Date(), forKey: "lastUpdate")
//            savedItem.setValue("SSSSS", forKey: "position")
            
            try persistentContainer.viewContext.save()
        } catch {
            print("Error update with comment", comment, "for id: \(item.id)")
        }
        
    }
   
    enum ProcessStatus {
        case added
        case exist
        case error(error: Error)
        case deleted
        case updated
    }
    
    struct ItemExistanceModel {
        let isExist: Bool?
        let isError: Error?
        let isUpdated: Bool?
    }
    
   
    func addNewItem(item: Item, comment: String?, completion: ((ProcessStatus) -> Void)?) {
        let existanceModel: ItemExistanceModel = checkIfExist(item: item, comment: comment)
        print(existanceModel)
        if let isExist = existanceModel.isExist {
            if isExist == false {
                saveNewFavourite(item: item, comment: comment)
                completion?(.added)
            } else {
                if let isUpdated = existanceModel.isUpdated, isUpdated == true {
                    updateComment(item: item, comment: comment)
                    completion?(.updated)
                } else {
                completion?(.exist)
                }
            }
        }
       
        if let isError = existanceModel.isError {
            completion?(.error(error: isError))
        }
    }
    

    private func checkIfExist(item: Item, comment: String?) -> ItemExistanceModel {
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

//extension DataManager: NSFetchedResultsControllerDelegate {
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print(controller.fetchedObjects)
//    }
//
//}



//import CoreData
//
//struct CoreDataManager {
//    
//    static let shared = CoreDataManager()
//    
//    let persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "Empat")
//        container.loadPersistentStores(completionHandler: { (storeDescription, err) in
//            if let err = err {
//                fatalError("Loading of stores failed: \(err)")
//            }
//        })
//        return container
//    }()
//    
//    
//    //MARK:- create new note
//    func createNewNote(date: Date, text: String) ->  {
//        let context = persistentContainer.viewContext
//        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Sea", into: context) as! Note
//        newNote.text = text
//        newNote.date = date
//
//        do {
//            try context.save()
//            return newNote
//        } catch let err {
//            print("Failed to save new note folder:",err)
//            return newNote
//        }
//    }
//    
//    //MARK:- Fetch Notes From DB
//    func fetchNotes() -> [Note] {
//        let context = persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
//        fetchRequest.fetchBatchSize = 20
//        do {
//            let notes = try context.fetch(fetchRequest)
//            return notes
//        } catch let err {
//            print("failed to fetch nore folders:",err)
//            return []
//        }
//    }
//    //MARK:- Delete from BD
//    func deleteNote(note: Note) -> Bool {
//        let context = persistentContainer.viewContext
//        context.delete(note)
//        
//        do {
//            try context.save()
//            return true
//        } catch let err {
//            print("error deleting note entity instance",err)
//            return false
//        }
//    }
//     //MARK:- Save updated notes
//    func saveUpdatedNote(note: Note, newText: String) {
//        let context = persistentContainer.viewContext
//        note.text = newText
//        note.date = Date()
//        
//        do {
//            try context.save()
//        } catch let err {
//            print("error saving/updating note",err)
//        }
//        
//    }
//     //MARK:- Search and Filter requests
//    func fetchSearchRequest(searchText: String) -> [Note] {
//        let context = persistentContainer.viewContext
//        let request: NSFetchRequest<Note> = Note.fetchRequest()
//        
//        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", searchText)
//        request.sortDescriptors = [NSSortDescriptor(key: "text", ascending: false)]
//        
//        do {
//            let notes = try context.fetch(request)
//            return notes
//        } catch let err {
//            print("failed to fetch nore folders:",err)
//            return []
//        }
//    }
//    
//    func fetchFilteredRequest() -> [Note] {
//        let context = persistentContainer.viewContext
//        let request: NSFetchRequest<Note> = Note.fetchRequest()
//        
//        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//        
//        do {
//            let notes = try context.fetch(request)
//            return notes
//        } catch let err {
//            print("failed to fetch nore folders:",err)
//            return []
//        }
//    }
//}
