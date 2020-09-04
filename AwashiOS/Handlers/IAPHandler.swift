
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHandler : NSObject  {
    static let shared = IAPHandler()
    
    static let IAPHandlerPurchaseNotification = "IAPHandlerPurchaseNotification"
    //fileprivate let productIdentifiers: Set<ProductIdentifier>
    var purchasedProducts: [ProductIdentifier: Purchase] = [:]
    var availableProducts: [ProductIdentifier: SKProduct] = [:]
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    fileprivate var postPurchaseUseCase: PostPurchaseUseCase?
    
    public static let productIdMonthlySubscription = "come.awashapp.awashiOS.subscription"
    public static let productIdAnnualSubscription = "com.awashapp.awashiOS.subscription.annual"
    
    let productIdentifiers = [productIdMonthlySubscription, productIdAnnualSubscription]
    
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func updatePurchasedProducts(products: [Purchase]) {
        products.forEach{
            self.purchasedProducts[$0.productId!] = $0
        }
    }
    
}

// MARK: - StoreKit API

extension IAPHandler {
    
    public func requestProducts(productIdentifiers: Set<ProductIdentifier>, completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        AnalyticsHandler.shared.trackEvent(of: .event, name: "USER_BUYING_PRODUCT", additionalInfo: ["productIdentifier": product.productIdentifier])
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        if let purchasedProduct = purchasedProducts[productIdentifier] {
            return !purchasedProduct.isSubscriptionExpired
        }
        return false
    }
    
    public func isSubscriptionActive() -> Bool {
        var active = false
        purchasedProducts.forEach { (productId, purchase) in
            
            if let expiraton =  purchase.verifiedReceipt["expirationDate"] as? Double {
                
                let expirationDate = Date(timeIntervalSince1970: (expiraton / 1000.0))
                if expirationDate > Date()  {
                    active = true
                }
                
                let components = Calendar.current.dateComponents([.hour], from: Date(), to: expirationDate)
                print("Expiration Date: ", expirationDate)
                print("Current Date: ", Date())
                //If less than 24 hours
                if let hours = components.hour, (hours > 0 && hours <= 24) {
                    self.postReceipt(productIdentifier: purchase.productId!)
                }
            }
            
        }
        return active
    }
    
    public func subscriptionExpirationDate() -> Date {
        var expiryDate = Date()
        purchasedProducts.forEach { (productId, purchase) in
            
            if let expiraton =  purchase.verifiedReceipt["expirationDate"] as? Double {
                
                expiryDate = Date(timeIntervalSince1970: (expiraton / 1000.0))
                
            }
            
        }
        return expiryDate
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHandler: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("Loaded list of products...")
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        AnalyticsHandler.shared.trackEvent(of: .event, name: "GET_STORE_PRODUCTS_FAILED", additionalInfo: ["error": error.localizedDescription])
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHandler: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                AnalyticsHandler.shared.trackEvent(of: .event, name: "TRANSACTION_PURCHASED", additionalInfo: ["productIdentifier": transaction.payment.productIdentifier])
                self.postReceipt(productIdentifier: transaction.payment.productIdentifier)
                break
            case .failed:
                AnalyticsHandler.shared.trackEvent(of: .event, name: "TRANSACTION_FAILED", additionalInfo: ["productIdentifier": transaction.payment.productIdentifier])
                fail(transaction: transaction)
                break
            case .restored:
                AnalyticsHandler.shared.trackEvent(of: .event, name: "TRANSACTION_RESTORED", additionalInfo: ["productIdentifier": transaction.payment.productIdentifier])
                queue.finishTransaction(transaction)
                self.postReceipt(productIdentifier: transaction.payment.productIdentifier)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    // Post purchase will create a new purchase and validates the receipt on server side
    private func postReceipt(productIdentifier: String ) {
        if let receiptString = loadReceipt() {
            let purchase = PostPurchase(productId: productIdentifier, receiptData: receiptString)
            postPurchaseUseCase = PostPurchaseUseCase(purchase: purchase)
            postPurchaseUseCase?.delegate = self
            postPurchaseUseCase?.performAction()
        }
        
        
    }
    
    private func loadReceipt() -> String? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let receiptString = data.base64EncodedString(options: [])
            return receiptString
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHandler.IAPHandlerPurchaseNotification), object: identifier)
    }
}

//MARK: PostPurchaseUseCaseDelegate
extension IAPHandler: PostPurchaseUseCaseDelegate {
    func postPurchaseSuccess(_ purchase: Purchase?) {
        AnalyticsHandler.shared.trackEvent(of: .event, name: "PURCHASE_SUCCESS", additionalInfo: ["productIdentifier":(purchase?.productId)!])
        purchasedProducts[(purchase?.productId)!] = purchase
        let currentQueue : SKPaymentQueue = SKPaymentQueue.default();
        for transaction in currentQueue.transactions {
            if (transaction.transactionState == SKPaymentTransactionState.purchased ) {
                deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
                AnalyticsHandler.shared.trackEvent(of: .event, name: "TRANSACTION_FINISHED", additionalInfo: ["productIdentifier": transaction.payment.productIdentifier, "transactionState": "purchased"])
                currentQueue.finishTransaction(transaction);
            } else if transaction.transactionState == SKPaymentTransactionState.restored  {
                currentQueue.finishTransaction(transaction);
            }
        }
    }
    
    func postPurchaseFailure(_ error: (title: String, message: String), backendError: BackendError?) {
        AnalyticsHandler.shared.trackEvent(of: .event, name: "PURCHASE_FAILED", additionalInfo: [:])
    }
    
    
}
