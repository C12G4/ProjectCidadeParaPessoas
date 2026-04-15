//
//  CoreDataService.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 08/04/26.
//

import CoreData
import Combine


class CoreDataController: ObservableObject{
    
    @Published var cards: [Card] = []
    
    func getCards() -> [Card] {
        cards = CoreDataService.shared.fetchAllCards()
        return cards
    }
    
    func createCard(name: String, id: UUID, lat: Double, longe: Double, audio: String, compartilhado: Bool, date: Date){
        let result = CoreDataService.shared.createCard(name: name, id: id, lat: lat, longe: longe, audio: audio, compartilhado: compartilhado,date: date)
        self.cards.append(result)
    }
    
    func deleteCard(_ card: Card){
        CoreDataService.shared.deleteCard(card)
    }
}
