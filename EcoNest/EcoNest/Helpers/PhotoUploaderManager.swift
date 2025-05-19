//
//  PhotoUploaderManager.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 21/11/1446 AH.
//

import SwiftUI

class PhotoUploaderManager {
    static let shared = PhotoUploaderManager()
    
    func uploadImages(images: [UIImage], completion: @escaping (Result<[URL], Error>) -> Void) {
        let group = DispatchGroup()
        var uploadedURLs: [URL] = []
        var uploadError: Error?

        for image in images {
            group.enter()
            uploadImages(image: image) { result in
                switch result {
                case .success(let url):
                    uploadedURLs.append(url)
                case .failure(let error):
                    uploadError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = uploadError {
                completion(.failure(error))
            } else {
                completion(.success(uploadedURLs))
            }
        }
    }

    func uploadImages(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 0, userInfo: nil)))
            return
        }

        let imageID = UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference().child("Posts/\(imageID).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(error ?? NSError(domain: "URL error", code: 0, userInfo: nil)))
                }
            }
        }
    }
    
    func uploadUserImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid image data", code: 0, userInfo: nil)))
            return
        }

        let imageID = UUID().uuidString
        let storageRef = FirebaseManager.shared.storage.reference().child("UserProfile/\(imageID).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

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
