//
//  AlertState.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//



import SwiftUI

// MARK: - Alert State Structure

/// A structure representing the current state of an alert.
/// Used to control the presentation and content of an alert in SwiftUI.
struct AlertState {
    var isPresented: Bool = false
    var title: String = ""
    var message: String = ""
}

// MARK: - Alert Manager

/// A singleton class responsible for managing alert presentation across the app.
/// Use `AlertManager.shared` to trigger alerts from anywhere.
class AlertManager: ObservableObject {
    static let shared = AlertManager()
    private init() {}
    
    @Published var alertState = AlertState()
    
    /// Displays an alert with the given title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message content of the alert.
    func showAlert(title: String, message: String) {
        print("Attempting to show alert: \(title) - \(message)")
        DispatchQueue.main.async {
            self.alertState = AlertState(isPresented: true, title: title, message: message)
            print("Alert state updated: \(self.alertState)")
        }
    }
}
