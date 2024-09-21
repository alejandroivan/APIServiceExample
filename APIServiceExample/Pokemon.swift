//
//  Pokemon.swift
//  APIServiceExample
//
//  Created by Alejandro Melo Domínguez on 20-09-24.
//

import Foundation

struct Pokemon: Decodable {
    let name: String
    let order: Int
    let weight: Double
}
