//
//  CartViewModel.swift
//  EcoNest
//
//  Created by Tahani Ayman on 10/11/1446 AH.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// ViewModel responsible for managing cart-related operations such as adding to and fetching from Firestore.
class CartViewModel: ObservableObject {
    
    /// List of cart items currently stored in Firestore for the user.
    @Published var cartProducts: [Cart] = []
    
    /// Adds a product to the current user's cart in Firestore.
    /// - Parameter product: The product to be added to the cart.
    func addToCart(product: Product) {
        let db = FirebaseManager.shared.firestore
        
        db.collection("users")
            .document("QhB8R3sqxN96eEfTk1Me")
            .collection("cart")
            .document() // Generate a new document with a unique ID
            .setData([
                "productId": product.id,
                "quantity": 1,
                "price": product.price
            ]) { err in
                if let err = err {
                    print("Error adding to cart: \(err.localizedDescription)")
                }
            }
    }
    
    /// Fetches all cart items from Firestore and resolves them into complete `Cart` objects with full `Product` data.
    func fetchCartData() {
        let db = FirebaseManager.shared.firestore
        
        db.collection("users")
          .document("QhB8R3sqxN96eEfTk1Me")
          .collection("cart")
          .getDocuments { snapshot, error in
              
              guard let documents = snapshot?.documents else {
                  print("No cart data found.")
                  return
              }
              
              self.cartProducts = [] // Clear previously loaded data
              
              // Loop through each cart document
              for doc in documents {
                  let data = doc.data()
                  
                  // Extract fields from the cart document
                  guard let productId = data["productId"] as? String,
                        let quantity = data["quantity"] as? Int,
                        let price = data["price"] as? Double else { continue }
                  
                  // Fetch the full product details from the "ProductTH" collection
                  db.collection("ProductTH").document(productId).getDocument { productDoc, error in
                      if let productData = productDoc?.data() {
                          // Map Firestore data to the Product model
                          let product = Product(
                              id: productDoc!.documentID,
                              name: productData["name"] as? String ?? "",
                              description: productData["description"] as? String ?? "",
                              price: productData["price"] as? Double ?? 0.0,
                              image: productData["image"] as? String ?? "",
                              category: productData["category"] as? String ?? "",
                              quantity: productData["quantity"] as? Int ?? 0,
                              careLevel: productData["careLevel"] as? String ?? "",
                              color: productData["color"] as? String ?? "",
                              size: productData["size"] as? String ?? "",
                              isAddedToCart: true
                          )
                          
                          // Construct a Cart object with the fetched product
                          let cartItem = Cart(
                              id: doc.documentID,
                              product: product,
                              quantity: quantity,
                              price: price
                          )
                          
                          // Ensure updates are performed on the main thread
                          DispatchQueue.main.async {
                              self.cartProducts.append(cartItem)
                          }
                      }
                  }
              }
          }
    }
}
