//
//  Item.swift
//  Empat
//
//  Created by Богдан Воробйовський on 15.10.2020.
//

import Foundation

struct SearchResult: Decodable {
    let page: Page?
    let items: [Item]?
}

struct Item: Decodable {
    let id: String
    let firstname, lastname, placeOfWork: String?
    let position: String?
    let linkPDF: String?
    let comment: String?
    let lastUpdate: Date? 
}

struct Page: Decodable {
    let batchSize,currentPage: Int?
    let totalItems: String?
    
    
}
