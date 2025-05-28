//
//  3DShow.swift
//  EcoNest
//
//  Created by Rawan on 07/05/2025.
//

import SwiftUI
import SceneKit
import FirebaseStorage

/// A SwiftUI wrapper for displaying a SceneKit scene.
struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene?

    /// Creates and configures the SCNView.
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.autoenablesDefaultLighting = true    // Enable default lighting
        view.allowsCameraControl = true          // Allow user to rotate/zoom/pan
        view.backgroundColor = UIColor.systemBackground  // Match system background color
        view.scene = scene     // Assign scene
        return view
    }
    /// Updates the SCNView when state changes.
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
    }
}

/// A view that loads and displays a 3D model (.obj, .mtl, and .png) from Firebase Storage using SceneKit.
struct SceneKitLoaderView: View {
    
    // MARK: - Variables
    
    let modelName: String
    @State private var isLoading = true
    @State private var scene: SCNScene?

    // MARK: - View
    
    var body: some View {
        ZStack {
            if isLoading {
                // Show placeholder while loading
                Image("loading-placeholder")
                    .resizable()
                    .frame(width:300,height: 300)
            } else if let loadedScene = scene {
                SceneKitView(scene: loadedScene)
            } else {
                // Display error message if model fails to load
                Text("Failed to load 3D model")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadModel()
        }
    }
    
    // MARK: - Model Loading
    
    /// Downloads and loads the .obj, .mtl, and texture files from Firebase, and creates a SceneKit scene.

    private func loadModel() {
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let objURL = tmpDir.appendingPathComponent("\(modelName).obj")
        let mtlURL = tmpDir.appendingPathComponent("\(modelName).mtl")
        let textureURL = tmpDir.appendingPathComponent("\(modelName).png")

        let storage = Storage.storage()
        let objRef = storage.reference(withPath: "3D/\(modelName).obj")
        let mtlRef = storage.reference(withPath: "3D/\(modelName).mtl")
        let textureRef = storage.reference(withPath: "3D/\(modelName).png")

        // Download .obj file
        objRef.write(toFile: objURL) { _, error in
            guard error == nil else {
                print("OBJ download error: \(error!.localizedDescription)")
                isLoading = false
                return
            }

            // Download .mtl file
            mtlRef.write(toFile: mtlURL) { _, error in
                guard error == nil else {
                    print("MTL download error: \(error!.localizedDescription)")
                    isLoading = false
                    return
                }

                // Download texture file
                textureRef.write(toFile: textureURL) { _, error in
                    guard error == nil else {
                        print("Texture download error: \(error!.localizedDescription)")
                        isLoading = false
                        return
                    }

                    // Load scene asynchronously
                    DispatchQueue.global().async {
                        do {
                            let sceneSource = SCNSceneSource(url: objURL, options: [
                                .assetDirectoryURLs: [tmpDir]
                            ])

                            if let loadedScene = sceneSource?.scene(options: nil) {
                                if let node = loadedScene.rootNode.childNodes.first,
                                   let geometry = node.geometry {
                                    let material = SCNMaterial()
                                    material.diffuse.contents = UIImage(contentsOfFile: textureURL.path)
                                    geometry.materials = [material]
                                }

                                // Update UI on main thread
                                DispatchQueue.main.async {
                                    self.scene = loadedScene
                                    self.isLoading = false
                                }
                            } else {
                                print("Failed to load scene from source.")
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                }
                            }
                        } catch {
                            print("Scene load error: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
        }
    }
}
