//
//  KeychainHelper.swift
//  EcoNest
//
//  Created by Rawan on 15/05/2025.
//


import Foundation
import Security

/// A singleton class for securely saving and retrieving data using the iOS Keychain.
class KeychainHelper {
    
    // MARK: - Singleton Instance
    static let shared = KeychainHelper()

    // MARK: - Initializer
        
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    // MARK: - Public Methods

    /// Saves a password to the keychain with the specified service and account.
    ///
    /// - Parameters:
    ///   - service: A string to identify the service (e.g., "com.example.MyApp").
    ///   - account: A string to identify the account (e.g., username or email).
    ///   - password: The password or token to be securely stored.

    func save(service: String, account: String, password: String) {
        guard let passwordData = password.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData
        ]

        //SecItemDelete(query as CFDictionary) // Ensure no duplicate
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Reads a saved password from the keychain for the given service and account.
    ///
    /// - Parameters:
    ///   - service: The service identifier used during save.
    ///   - account: The account identifier used during save.
    /// - Returns: The stored password as a `String`, or `nil` if not found.
    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }
}
