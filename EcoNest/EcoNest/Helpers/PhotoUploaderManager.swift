//
//  PhotoUploaderManager.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 21/11/1446 AH.
//

import SwiftUI
import FirebaseStorage

/// A singleton class responsible for uploading images to Firebase Storage.
/// Supports uploading multiple images, individual post images, and user profile images.
class PhotoUploaderManager {
    
    /// Shared singleton instance
    static let shared = PhotoUploaderManager()
    
    private init() {}
    
    /// Uploads multiple images to Firebase Storage under the "Posts" directory.
    /// - Parameters:
    ///   - images: An array of `UIImage` objects to upload.
    ///   - completion: A closure called when all uploads finish, returning
    ///                 either an array of URLs on success, or an error on failure.
    func uploadImages(images: [UIImage], isPost: Bool,completion: @escaping (Result<[URL], Error>) -> Void) {
        let group = DispatchGroup()           // To track multiple async upload tasks
        var uploadedURLs: [URL] = []          // Store successfully uploaded URLs
        var uploadError: Error?               // Capture any error occurred
        
        for image in images {
            group.enter()                     // Mark start of an upload task
            uploadImages(image: image, isPost: isPost) { result in
                switch result {
                case .success(let url):
                    uploadedURLs.append(url)
                case .failure(let error):
                    uploadError = error       // Capture error but continue uploading others
                }
                group.leave()                 // Mark end of an upload task
            }
        }
        
        // Called when all uploads have completed
        group.notify(queue: .main) {
            if let error = uploadError {
                completion(.failure(error))  // Return failure if any upload failed
            } else {
                completion(.success(uploadedURLs))  // Return array of URLs on success
            }
        }
    }
    
    /// Uploads a single image to Firebase Storage under the "Posts" directory.
    /// - Parameters:
    ///   - image: The `UIImage` to upload.
    ///   - completion: Closure called with the resulting URL or error.
    func uploadImages(image: UIImage,isPost: Bool, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 0, userInfo: nil)))
            return
        }
        
        var storageRef: StorageReference? = nil
        let imageID = UUID().uuidString
        if isPost{
            storageRef = FirebaseManager.shared.storage.reference().child("Posts/\(imageID).jpg")
        } else {
            storageRef = FirebaseManager.shared.storage.reference().child("Messages/\(imageID).jpg")
        }
        
        
        // Upload image data to Firebase Storage
        if let storageRef = storageRef {
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Fetch the download URL after successful upload
                storageRef.downloadURL { url, error in
                    if let url = url {
                        completion(.success(url))
                    } else {
                        completion(.failure(error ?? NSError(domain: "URL error", code: 0, userInfo: nil)))
                    }
                }
            }
        }
    }
    
    /// Uploads a user profile image to Firebase Storage under the "UserProfile" directory.
    /// - Parameters:
    ///   - image: The `UIImage` to upload.
    ///   - completion: Closure called with the resulting URL or error.
    func uploadUserImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 0, userInfo: nil)))
            return
        }
        
        let imageID = UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference().child("UserProfile/\(imageID).jpg")
        
        // Upload profile image data
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Retrieve the download URL
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(error ?? NSError(domain: "URL error", code: 0, userInfo: nil)))
                }
            }
        }
    }
    
    func DeleteImage(text: String, start: String, end: String) {
        guard let startRange = text.range(of: start),
              let endRange = text.range(of: end, range: startRange.upperBound..<text.endIndex) else {
            return
        }

        let encodedPath = String(text[startRange.upperBound..<endRange.lowerBound])
        
        guard let decodedPath = encodedPath.removingPercentEncoding else {
            print("Failed to decode path: \(encodedPath)")
            return
        }

        let storage = FirebaseManager.shared.storage
        let storageRef = storage.reference()
        let imageRef = storageRef.child(decodedPath)
        
        imageRef.delete { error in
            if let error = error {
                print("Error deleting image: \(error.localizedDescription)")
            } else {
                print("Image successfully deleted: \(decodedPath)")
            }
        }
    }
}
