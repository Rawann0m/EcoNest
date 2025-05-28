//
//  AuthViewModel.swift
//  EcoNest
//
//  Created by Rawan on 05/05/2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// A view model responsible for handling user authentication logic,
/// including sign-up, login, logout, and session management.
class AuthViewModel:ObservableObject {
    
    //MARK: - Variables
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var resetError: String?
    @Published var resetSuccessMessage: String?
    @AppStorage("AppleLanguages") var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    // MARK: - Initialization
    /// Checks user authentication status when the view model is initialized
    init() {
        checkUserLoggedIn()
    }
    
    // MARK: - Check Login State
    /// Determines if a user is already logged in using Firebase
    func checkUserLoggedIn(){
        if FirebaseManager.shared.auth.currentUser != nil {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }
    
    // MARK: - Log In Function
    /// Attempts to log the user in with Firebase Auth
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    ///   - completion: Closure returning success status and optional error message
    func logIn(email: String, password: String, completion: @escaping (Bool,String?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            AlertManager.shared.showAlert(title: "Error".localized(using: currentLanguage), message: "FillAll".localized(using: currentLanguage))
            completion(false, "Empty fields")
            return
        }
        
        guard isValidEmail(email) else {
            AlertManager.shared.showAlert(title: "InvalidEmail".localized(using: currentLanguage), message: "ValidEmail".localized(using: currentLanguage))
            completion(false, "Invalid email")
            return
        }
        
        isLoading = true
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController { //  This will get the root view controller of the app
                        let alert = UIAlertController(title: "LoginFailed".localized(using: self.currentLanguage), message:self.mapFirebaseError(error), preferredStyle: .alert) // This will make an alert controller that has the title i chose with the message i chose
                        alert.addAction(UIAlertAction(title: "OK".localized(using: self.currentLanguage), style: .default)) // Adding the ok button to dismiss the alert
                        rootVC.present(alert, animated: true) // Present it the screen
                    }
                    
                    completion(false, self.mapFirebaseError(error))
                    return
                }
                
                guard let uid = result?.user.uid else {
                    let message = "User ID not found"
                    AlertManager.shared.showAlert(title: "Error", message: message)
                    completion(false, message)
                    return
                }
                
                self.handleSuccessfulLogin(uid: uid, completion: completion)
            }
        }
    }
    
    // MARK: - Log Out Function
    /// Signs out the user and clears session info from storage
    func logOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
            isAuthenticated = false
            print("User logged out successfully")
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sign Up Function
    /// Registers a new user with Firebase Authentication and stores user data in Firestore
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: Email address
    ///   - password: Password
    ///   - confirmPassword: Password confirmation
    ///   - completion: Closure returning success status and optional error message
    func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping (Bool,String?) -> Void) {
        
        // Check password match first
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            AlertManager.shared.showAlert(title: "Error".localized(using: currentLanguage), message: "FillAll".localized(using: currentLanguage))
            completion(false, "Empty fields")
            return
        }
        
        guard isValidEmail(email) else {
            AlertManager.shared.showAlert(title: "InvalidEmail".localized(using: currentLanguage), message: "ValidEmail".localized(using: currentLanguage))
            completion(false, "Invalid email")
            return
        }
        
        guard password == confirmPassword else {
            AlertManager.shared.showAlert(title: "PasswordMismatch".localized(using: currentLanguage), message: "PasswordMismatchMsg".localized(using: currentLanguage))
            completion(false, "Password mismatch")
            return
        }
        
        guard isValidPassword(password) else {
            AlertManager.shared.showAlert(title: "WeakPassword".localized(using: currentLanguage), message: "WeakPasswordMsg".localized(using: currentLanguage))
            completion(false, "Weak password")
            return
        }
        
        isLoading = true
        // Create user
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController { //  This will get the root view controller of the app
                        let alert = UIAlertController(title: "SignupFailed".localized(using: self.currentLanguage), message:self.mapFirebaseError(error), preferredStyle: .alert)// This will make an alert controller that has the title i chose with the message i chose
                        alert.addAction(UIAlertAction(title: "OK", style: .default))// Adding the ok button to dismiss the alert
                        rootVC.present(alert, animated: true) // Present it on the screen
                    }
                    
                    completion(false, self.mapFirebaseError(error))
                    return
                }
                
                guard let uid = result?.user.uid else {
                    completion(false, "User ID not found")
                    return
                }
                // Save data to fire store
                self.saveUserData(uid: uid, name: name, email: email)
                self.isAuthenticated = true
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Successful Login Handling
    
    /// Handles logic after a successful login.
    private func handleSuccessfulLogin(uid: String, completion: @escaping (Bool, String?) -> Void) {
        
        fetchUserFromFirestore(uid: uid) { success in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                    completion(true, nil)
                } else {
                    let message = "Failed to fetch user data"
                    AlertManager.shared.showAlert(title: "Error".localized(using: self.currentLanguage), message: message)
                    completion(false, message)
                }
            }
        }
    }
    
    // MARK: - Firestore - Save and Fetch
    
    /// Saves user data to Firestore after signup.
    private func saveUserData(uid: String, name: String, email: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "username": name,
            "email": email,
            "profileImage": ""
        ])  { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved to Firestore.")
                self.fetchUserFromFirestore(uid: uid, completion: { _ in })
            }
        }
    }
    
    /// Fetches user data from Firestore to store locally in Core Data.
    func fetchUserFromFirestore(uid: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("User document not found")
                completion(false)
                return
            }
            
            
            let username = data["username"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            completion(true)
        }
    }
    
    // MARK: - Delete User
    
    /// Deletes a user's account from Firebase Auth and Firestore after reauthentication.
    func deleteUserAccount(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let user = FirebaseManager.shared.auth.currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])))
            return
        }
        let service = "com.EcoNest"
        let savedPassword = KeychainHelper.shared.read(service: service, account: email)
        let credential = EmailAuthProvider.credential(withEmail: email, password: savedPassword ?? "")
        
        // Re-authenticate - firebase wont allow user to delete until it reauthenticated
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let uid = user.uid
            let db = Firestore.firestore()
            
            // Delete user from Firestore
            db.collection("users").document(uid).delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Delete from Firebase Auth
                user.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.isAuthenticated = false
                        completion(.success(" User successfully deleted from Firebase and Firestore."))
                    }
                }
            }
        }
    }
    
    func savePasswordIfNeeded(account: String, newPassword: String) {
        let service = "com.EcoNest"

        if let existingPassword = KeychainHelper.shared.read(service: service, account: account) {
            // Check if it's already the same
            if existingPassword == newPassword {
                print("Password is the same, no need to update.")
                return
            }
        }

        // Save or update the password
        KeychainHelper.shared.save(service: service, account: account, password: newPassword)
        print("Password saved or updated.")
    }

    
    // MARK: - Reset Password
    private let db = Firestore.firestore()
    func resetPasswordWithEmailLookup(for email: String) {
        
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    let message = "Something went wrong."
                    AlertManager.shared.showAlert(title: "Error".localized(using: self.currentLanguage), message: message)
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    print("No matching email found in Firestore.")
                    let message = "No user found with this email."
                    AlertManager.shared.showAlert(title: "Error".localized(using: self.currentLanguage), message: message)
                    return
                }
                
                if let correctEmail = doc.get("email") as? String {
                    print("Exact email found: \(correctEmail)")
                    self.sendResetEmail(to: correctEmail)
                } else {
                    let message = "Invalid email format."
                    AlertManager.shared.showAlert(title: "Error".localized(using: self.currentLanguage), message: message)
                }
            }
    }
    
    private func sendResetEmail(to email: String) {
        print("Sending password reset email to: \(email)")
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Reset error: \(error.localizedDescription)")
                let message = error.localizedDescription
                AlertManager.shared.showAlert(title: "Error".localized(using: self.currentLanguage), message: message)
            } else {
                let message = "Password reset email sent."
                AlertManager.shared.showAlert(title: "Success".localized(using: self.currentLanguage), message: message)
            }
        }
    }
    // MARK: - Validation Helpers
    
    /// Validates if an email string matches proper format.
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    /// Validates password strength (min 8 chars, at least 1 uppercase, 1 lowercase, 1 number).
    func isValidPassword(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,}$")
        return passwordTest.evaluate(with: password)
    }
    
    // MARK: - Firebase Error Mapping
    
    /// Converts Firebase error codes to user-friendly messages.
    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        
        guard nsError.domain == AuthErrorDomain else {
            return error.localizedDescription
        }
        
        guard let authErrorCode = AuthErrorCode(rawValue: nsError.code) else {
            return "UnknownError".localized(using: self.currentLanguage)
        }
        
        switch authErrorCode {
        case .invalidCredential:
            return "CredentialsError".localized(using: self.currentLanguage)
            
        case .emailAlreadyInUse:
            return "AssociatedEmail".localized(using: self.currentLanguage)
            
        case .invalidEmail:
            return "EmailInvalid".localized(using: self.currentLanguage)
            
        case .weakPassword:
            return "WeakPasswordMsg2".localized(using: self.currentLanguage)
            
        case .networkError:
            return "NetworkError".localized(using: self.currentLanguage)
            
        case .tooManyRequests:
            return "2Many".localized(using: self.currentLanguage)
            
        case .internalError:
            return "InternalError".localized(using: self.currentLanguage)
            
        default:
            return "UnknownError".localized(using: self.currentLanguage)
        }
    }
}



