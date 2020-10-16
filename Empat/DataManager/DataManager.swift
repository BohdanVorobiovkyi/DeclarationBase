//
//  DataManager.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    var items: [Item]?
    
//    lazy var lastQuerryText: String = {
//        if let lastquerry = UserDefaults.standard.object(forKey: "lastQuerry"){
//            return "\(lastquerry)"
//        }
//        return ""
//    }()
//
//    var itemsCount: Int {
//        if let numberOfObjects =  fetchedResultsController.sections?.first?.numberOfObjects {
//            return numberOfObjects == 0 ? 1 : numberOfObjects
//        }
//        return 1
//    }
    
    private var isLoading: Bool = false
    private var currentPage: Int = 1
    //MARK: CoreData container an fetchedResultsController
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubClient")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<SavedItem> = {
        let fetchRequest: NSFetchRequest<SavedItem> = SavedItem.fetchRequest()
        //        fetchRequest.fetchBatchSize = 30
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
    
    
    //MARK: Network request with re-saving results to CD / Next batch load
    func getRequest(searchText: String, completion: @escaping (([Item]) -> Void)) {
        isLoading = true
        NetworkService.performRequest(querry: searchText, cahcePolicy: .reloadIgnoringLocalAndRemoteCacheData) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                print(data)
                
                do {
                    let searchResults = try newJSONDecoder().decode(SearchResult.self, from: data)
                    completion(searchResults.items)
                    
                } catch {
                    self?.isLoading = false
                    let nserror = error as NSError
                    fatalError("Decoding error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}



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
