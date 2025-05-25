//
//  OrderStatus.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//


// Enum to represent the various statuses an order can have
// Conforms to String for raw values and CaseIterable to allow iteration over all cases
enum OrderStatus: String, CaseIterable {
    
    case awaitingPickup = "Awaiting pickup"
    case cancelled = "Cancelled"
}
