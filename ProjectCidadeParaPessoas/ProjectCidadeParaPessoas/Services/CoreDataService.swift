//
//  CoreDataController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 08/04/26.
//

import Foundation
import CoreData
import Combine

class CoreDataService: ObservableObject{
    
    static let shared = CoreDataService()
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext{
        persistentContainer.viewContext
    }
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "CoreDataModel")
        
        persistentContainer.loadPersistentStores{ _, error in
            if let error = error{
                fatalError("Could not load CoreData stack: \(error.localizedDescription)")
            }
        }
    }
    
    func saveContext(){
        if viewContext.hasChanges{
            do{
                try viewContext.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    func createCard(name: String, id: UUID, lat: Double, longe: Double, audio: String, compartilhado: Bool) -> Card{
        
        let card = Card(context: viewContext)
        
        card.id = id
        card.name = name
        card.lat = lat
        card.longe = longe
        card.audio = audio
        card.compartilhado = compartilhado
        saveContext()
        return card
    }
    
    func fetchAllCards() -> [Card] {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do{
            let result = try viewContext.fetch(fetchRequest)
            saveContext()
            return result
        } catch {
            print("Error fetching Books: \(error.localizedDescription)")
            return[]
        }
    }
    
    func deleteCard(_ card: Card){
        viewContext.delete(card)
        saveContext()
    }
}
