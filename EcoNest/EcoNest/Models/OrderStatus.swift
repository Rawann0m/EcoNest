//
//  OrderStatus.swift
//  EcoNest
//
//  Created by Tahani Ayman on 15/11/1446 AH.
//


/// Represents the current status of an order.
enum OrderStatus: String, CaseIterable {
    
    case awaitingPickup = "Awaiting pickup"
    case cancelled = "Cancelled"
}
