//
//  Untitled.swift
//  EcoNest
//
//  Created by Rawan on 07/05/2025.
//

import SwiftUI
import SceneKit
import FirebaseStorage

struct Show: View {
    let modelName: String // pass model name
    @State private var isLoading = true

    var body: some View {
           ZStack {
               SceneKitView(modelName: modelName, isLoading: $isLoading)
                   .edgesIgnoringSafeArea(.all)
                   .opacity(isLoading ? 0 : 1)

               if isLoading {
                   VStack {
                       Image("loading-placeholder")
                           .resizable()
                           .frame(width: 250, height: 250)
                           .transition(.opacity)
                           .animation(.easeInOut, value: isLoading)
                   }
                   .zIndex(1)
               }
           }
       }
   }

//struct SceneKitView: UIViewRepresentable {
//    let modelName: String
//    @Binding var isLoading: Bool
//
//    func makeUIView(context: Context) -> SCNView {
//        let sceneView = SCNView()
//        sceneView.autoenablesDefaultLighting = true
//        sceneView.allowsCameraControl = true
//        sceneView.backgroundColor = UIColor.systemBackground
//        
//        // Temporary directory for storing downloaded files
//        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
//        let objURL = tmpDir.appendingPathComponent("\(modelName).obj")
//        let mtlURL = tmpDir.appendingPathComponent("\(modelName).mtl")
//        let textureURL = tmpDir.appendingPathComponent("\(modelName).png")
//
//        // Firebase references for downloading files
//        let storage = Storage.storage()
//        let objRef = storage.reference(withPath: "3D/\(modelName).obj")
//        let mtlRef = storage.reference(withPath: "3D/\(modelName).mtl")
//        let textureRef = storage.reference(withPath: "3D/\(modelName).png")
//
//        // Start downloading the files sequentially
//        objRef.write(toFile: objURL) { _, error in
//            guard error == nil else {
//                print("OBJ download error: \(error!.localizedDescription)")
//                return
//            }
//
//            mtlRef.write(toFile: mtlURL) { _, error in
//                guard error == nil else {
//                    print("MTL download error: \(error!.localizedDescription)")
//                    return
//                }
//
//                textureRef.write(toFile: textureURL) { _, error in
//                    guard error == nil else {
//                        print("Texture download error: \(error!.localizedDescription)")
//                        return
//                    }
//
//                    // Log file existence for debugging
//                    print("OBJ exists:", FileManager.default.fileExists(atPath: objURL.path))
//                    print("MTL exists:", FileManager.default.fileExists(atPath: mtlURL.path))
//                    print("Texture exists:", FileManager.default.fileExists(atPath: textureURL.path))
//
//                    // After all files are downloaded, load the scene
//                    do {
//                        let sceneSource = SCNSceneSource(url: objURL, options: [
//                            .assetDirectoryURLs: [tmpDir]
//                        ])
//
//                        if let scene = sceneSource?.scene(options: nil) {
//                            // Apply texture manually if needed
//                            if let node = scene.rootNode.childNodes.first,
//                               let geometry = node.geometry {
//                                let material = SCNMaterial()
//                                material.diffuse.contents = UIImage(contentsOfFile: textureURL.path)
//                                geometry.materials = [material]
//                            }
//
//                            // Notify that the scene is ready and update UI
//                            DispatchQueue.main.async {
//                                sceneView.scene = scene
//                                isLoading = false  // Finished loading, hide ProgressView
//                            }
//                        } else {
//                            print("Failed to load scene from source.")
//                        }
//                    } catch {
//                        print("Scene load error: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//
//        return sceneView
//    }
//
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // No dynamic updates needed for this case
//    }
//}

import SwiftUI
import SceneKit
import FirebaseStorage

struct SceneKitView: UIViewRepresentable {
    let modelName: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.systemBackground

        // Start downloading model files
        downloadModelAssets(modelName: modelName) { objURL, mtlURL, textureURL in
            let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())

            // Debug: Check file existence
            print("OBJ exists:", FileManager.default.fileExists(atPath: objURL.path))
            print("MTL exists:", FileManager.default.fileExists(atPath: mtlURL.path))
            print("Texture exists:", FileManager.default.fileExists(atPath: textureURL.path))

            // Load the scene from downloaded files
            let sceneSource = SCNSceneSource(url: objURL, options: [
                .assetDirectoryURLs: [tmpDir]
            ])

            if let scene = sceneSource?.scene(options: nil) {
                if let node = scene.rootNode.childNodes.first,
                   let geometry = node.geometry {
                    let material = SCNMaterial()
                    material.diffuse.contents = UIImage(contentsOfFile: textureURL.path)
                    geometry.materials = [material]
                }

                DispatchQueue.main.async {
                    sceneView.scene = scene
                    isLoading = false
                }
            } else {
                print("Failed to load scene from source.")
            }
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // No dynamic updates needed
    }

    // MARK: - Helper to get local file URLs and Firebase references
    private func getModelFileURLsAndRefs(modelName: String) -> (
        objURL: URL, mtlURL: URL, textureURL: URL,
        objRef: StorageReference, mtlRef: StorageReference, textureRef: StorageReference
    ) {
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let objURL = tmpDir.appendingPathComponent("\(modelName).obj")
        let mtlURL = tmpDir.appendingPathComponent("\(modelName).mtl")
        let textureURL = tmpDir.appendingPathComponent("\(modelName).png")

        let storage = Storage.storage()
        let objRef = storage.reference(withPath: "3D/\(modelName).obj")
        let mtlRef = storage.reference(withPath: "3D/\(modelName).mtl")
        let textureRef = storage.reference(withPath: "3D/\(modelName).png")

        return (objURL, mtlURL, textureURL, objRef, mtlRef, textureRef)
    }

    // MARK: - Helper to download all assets sequentially
    private func downloadModelAssets(
        modelName: String,
        completion: @escaping (_ objURL: URL, _ mtlURL: URL, _ textureURL: URL) -> Void
    ) {
        let (objURL, mtlURL, textureURL, objRef, mtlRef, textureRef) = getModelFileURLsAndRefs(modelName: modelName)

        objRef.write(toFile: objURL) { _, error in
            if let error = error {
                print("OBJ download error: \(error.localizedDescription)")
                return
            }

            mtlRef.write(toFile: mtlURL) { _, error in
                if let error = error {
                    print("MTL download error: \(error.localizedDescription)")
                    return
                }

                textureRef.write(toFile: textureURL) { _, error in
                    if let error = error {
                        print("Texture download error: \(error.localizedDescription)")
                        return
                    }

                    // All downloads successful
                    completion(objURL, mtlURL, textureURL)
                }
            }
        }
    }
}
