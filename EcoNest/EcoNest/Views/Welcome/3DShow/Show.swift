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
            if isLoading {
                Text("3D is loading...")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                SceneKitView(modelName: modelName,isLoading: $isLoading)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoading = false
            }
        }
    }
}

struct SceneKitView: UIViewRepresentable {
    let modelName: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.systemBackground

        // Temporary directory for storing downloaded files
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let objURL = tmpDir.appendingPathComponent("\(modelName).obj")
        let mtlURL = tmpDir.appendingPathComponent("\(modelName).mtl")
        let textureURL = tmpDir.appendingPathComponent("\(modelName).png")

        // Firebase references for downloading files
        let storage = Storage.storage()
        let objRef = storage.reference(withPath: "3D/\(modelName).obj")
        let mtlRef = storage.reference(withPath: "3D/\(modelName).mtl")
        let textureRef = storage.reference(withPath: "3D/\(modelName).png")

        // Start downloading the files sequentially
        objRef.write(toFile: objURL) { _, error in
            guard error == nil else {
                print("OBJ download error: \(error!.localizedDescription)")
                return
            }

            mtlRef.write(toFile: mtlURL) { _, error in
                guard error == nil else {
                    print("MTL download error: \(error!.localizedDescription)")
                    return
                }

                textureRef.write(toFile: textureURL) { _, error in
                    guard error == nil else {
                        print("Texture download error: \(error!.localizedDescription)")
                        return
                    }

                    // Log file existence for debugging
                    print("OBJ exists:", FileManager.default.fileExists(atPath: objURL.path))
                    print("MTL exists:", FileManager.default.fileExists(atPath: mtlURL.path))
                    print("Texture exists:", FileManager.default.fileExists(atPath: textureURL.path))

                    // After all files are downloaded, load the scene
                    do {
                        let sceneSource = SCNSceneSource(url: objURL, options: [
                            .assetDirectoryURLs: [tmpDir]
                        ])

                        if let scene = sceneSource?.scene(options: nil) {
                            // Apply texture manually if needed
                            if let node = scene.rootNode.childNodes.first,
                               let geometry = node.geometry {
                                let material = SCNMaterial()
                                material.diffuse.contents = UIImage(contentsOfFile: textureURL.path)
                                geometry.materials = [material]
                            }

                            // Notify that the scene is ready and update UI
                            DispatchQueue.main.async {
                                sceneView.scene = scene
                                isLoading = false  // Finished loading, hide ProgressView
                            }
                        } else {
                            print("Failed to load scene from source.")
                        }
                    } catch {
                        print("Scene load error: \(error.localizedDescription)")
                    }
                }
            }
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // No dynamic updates needed for this case
    }
}
