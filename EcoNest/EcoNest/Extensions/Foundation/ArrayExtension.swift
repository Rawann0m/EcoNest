//
//  File.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 12/11/1446 AH.
//


import Foundation

extension Array {
    // Chunked method splits the array into smaller arrays of a specified size
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)]) // Ensures that the end index does not exceed the array bounds
            // The min function takes two values and returns the smaller one
            // It compares the intended end index ($0 + size) with the total count of the array (count)
        }
    }
}

