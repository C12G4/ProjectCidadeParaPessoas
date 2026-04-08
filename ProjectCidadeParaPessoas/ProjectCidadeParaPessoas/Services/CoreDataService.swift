//
//  CoreDataService.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 08/04/26.
//

import CoreData
internal import Combine

class ContentViewModel: ObservableObject{
    
    @Published var cards: [Card] = []
    
    func getCards(){
        cards = CoreDataController.shared.fetchAllCards()
    }
    
    func createCard(name: String, id: UUID, lat: Double, longe: Double, audio: String){
        let result = CoreDataController.shared.createCard(name: name, id: id, lat: lat, longe: longe, audio: audio)
        self.cards.append(result)
    }
    
    func deleteCard(_ card: Card){
        CoreDataController.shared.deleteCard(card)
    }
}
