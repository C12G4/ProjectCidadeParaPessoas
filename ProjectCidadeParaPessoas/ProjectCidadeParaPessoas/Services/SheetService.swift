//
//  SheetService.swift
//  ProjectCidadeParaPessoas
//
//  Created by Tamires Mendes da Silva on 15/04/26.
//

import UIKit

class SheetService {
    static var shared = SheetService()
    var isSheetShowing: Bool = false
    var name: String = ""
    var audio: String = ""
    var date: String = ""
    
    private init() {}
    
}
