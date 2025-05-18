//
//  CreatePostViewModel.swift
//  EcoNest
//
//  Created by Rayaheen Mseri on 13/11/1446 AH.
//

import SwiftUI
import FirebaseFirestore

class CreatePostViewModel: ObservableObject {

    func addPost(communityId: String, post: Post){
        let createdPost = ["content": post.content, "timestamp": post.timestamp, "userId": post.userId, "likes": post.likes] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("community")
            .document(communityId)
            .collection("posts")
            .document()
            .setData(createdPost) { error in
                if let error = error {
                    print(error)
                    return
                }
                print("successfully saved post data")
            }
        
    }
    
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
    
}
