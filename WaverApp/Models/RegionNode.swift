//
//  RegionNode.swift
//  Waver
//
//  Created by Quincy Keele on 2/18/25.
//

import Foundation

struct RegionNode: Identifiable {
    let id = UUID()
    let name: String
    let children: [RegionNode]
}

let regionTree: [RegionNode] = [
    RegionNode(
        name: "Hawaii",
        children: [
            RegionNode(
                name: "Oʻahu",
                children: [
                    RegionNode(name: "North Shore", children: []),
                    RegionNode(name: "South Shore", children: []),
                    RegionNode(name: "East Side",  children: []),
                    RegionNode(name: "West Side",  children: [])
                ]
            ),
            RegionNode(name: "Maui",     children: []),
            RegionNode(name: "Kauaʻi",    children: []),
            RegionNode(name: "Island of Hawaiʻi", children: []),
            RegionNode(name: "Molokaʻi", children: []),
            RegionNode(name: "Lānaʻi", children: [])
        ]
    ),
    RegionNode(
        name: "United States",
        children: [
            RegionNode(
                name: "California",
                children: [
                    RegionNode(name: "Los Angeles County", children: []),
                    RegionNode(name: "Orange County", children: []),
                    RegionNode(name: "San Diego County", children: []),
                    RegionNode(name: "Santa Cruz County", children: []),
                    RegionNode(name: "Ventura County", children: [])
                ]
            ),
            RegionNode(name: "Florida",       children: []),
            RegionNode(name: "New York",      children: []),
            RegionNode(name: "New Jersey",    children: []),
            RegionNode(name: "North Carolina",children: []),
            RegionNode(name: "South Carolina",children: []),
            RegionNode(name: "Texas",         children: []),
            RegionNode(name: "Oregon",        children: []),
            RegionNode(name: "Washington",    children: [])
        ]
    )
]
