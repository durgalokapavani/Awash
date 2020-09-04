//
//  AwashCache.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import Cache

class AwashCache {
    static let shared = AwashCache()
    fileprivate var diskConfig:DiskConfig?
    fileprivate var memoryConfig:MemoryConfig?
    var storage:Storage<Data>?
    
    private init() {
        diskConfig = DiskConfig(
            // The name of disk storage, this will be used as folder name within directory
            name: "Awash",
            // Expiry date that will be applied by default for every added object
            // if it's not overridden in the `setObject(forKey:expiry:)` method
            expiry: .date(Date().addingTimeInterval(2*24*3600)), //48 hours
            // Maximum size of the disk cache storage (in bytes)
            maxSize: 10000000, //10 MB
            // Where to store the disk cache. If nil, it is placed in `cachesDirectory` directory.
            directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true).appendingPathComponent("Meditations"),
            // Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
            protectionType: .complete
        )
        
        memoryConfig = MemoryConfig(
            // Expiry date that will be applied by default for every added object
            // if it's not overridden in the `setObject(forKey:expiry:)` method
            expiry: .date(Date().addingTimeInterval(2*60*60)),
            /// The maximum number of objects in memory the cache should hold
            countLimit: 20,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            totalCostLimit: 0
        )
        
        storage = try? Storage<Data>(diskConfig: diskConfig!, memoryConfig: memoryConfig!, transformer: TransformerFactory.forCodable(ofType: Data.self))
        
    }
}
