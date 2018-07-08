
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHelper : NSObject  {
  
    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
    
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        print("INIT ProductID:")
        print(productIdentifiers)
        super.init()
    }
}

// MARK: - StoreKit API

extension IAPHelper {
  
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        print("Request Products")
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
        
        print("YOYOYOY")
        print(productsRequest)
    }
    
    public func buyProduct(_ product: SKProduct) {
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return false
    }
  
    public class func canMakePayments() -> Bool {
        return true
    }
  
    public func restorePurchases() {
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        print("YOYOYOY2")
        print(response.products)
        productsRequestCompletionHandler?(true, products)
        print("YOYOYOY3")
        clearRequestAndHandler()
        
        print("YOYOYOY4")
        print(productsRequest)
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}
