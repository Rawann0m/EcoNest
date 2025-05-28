//
//  3DShow.swift
//  EcoNest
//
//  Created by Rawan on 07/05/2025.
//

import SwiftUI
import SceneKit
import FirebaseStorage

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene?

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        view.backgroundColor = UIColor.systemBackground
        view.scene = scene
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
    }
}


struct SceneKitLoaderView: View {
    let modelName: String
    @State private var isLoading = true
    @State private var scene: SCNScene?

    var body: some View {
        ZStack {
            if isLoading {
                Image("loading-placeholder")
                    .resizable()
                    .frame(width:300,height: 300)
            } else if let loadedScene = scene {
                SceneKitView(scene: loadedScene)
            } else {
                Text("Failed to load 3D model")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadModel()
        }
    }

    private func loadModel() {
        let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let objURL = tmpDir.appendingPathComponent("\(modelName).obj")
        let mtlURL = tmpDir.appendingPathComponent("\(modelName).mtl")
        let textureURL = tmpDir.appendingPathComponent("\(modelName).png")

        let storage = Storage.storage()
        let objRef = storage.reference(withPath: "3D/\(modelName).obj")
        let mtlRef = storage.reference(withPath: "3D/\(modelName).mtl")
        let textureRef = storage.reference(withPath: "3D/\(modelName).png")

        objRef.write(toFile: objURL) { _, error in
            guard error == nil else {
                print("OBJ download error: \(error!.localizedDescription)")
                isLoading = false
                return
            }

            mtlRef.write(toFile: mtlURL) { _, error in
                guard error == nil else {
                    print("MTL download error: \(error!.localizedDescription)")
                    isLoading = false
                    return
                }

                textureRef.write(toFile: textureURL) { _, error in
                    guard error == nil else {
                        print("Texture download error: \(error!.localizedDescription)")
                        isLoading = false
                        return
                    }

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
