//
//  HashTable.swift
//  TD
//
//  Created by Sharon Wolfovich on 19/02/2021.
//

import Foundation

class HashTable<K: Hashable, V> {
    typealias Bucket = [HashElement<K, V>]
    var buckets: [Bucket]
    
    init(capacity: Int) {
        assert(capacity > 0)
        buckets = Array<Bucket>(repeatElement([], count: capacity))
    }
    
    func index(for key: K) -> Int {
        return abs(key.hashValue) % buckets.count
    }
    
    func retrieveValue(for key: K) -> [V]? {
        let index = self.index(for: key)
        var array = [V]()
        for element in buckets[index] {
            if element.key == key {
                array.append(element.value!)
                //return element.value
            }
        }
        return array
    }
    
    //@discardableResult
    func updateValue(_ value: V, forKey key: K) {//-> V? {
        var itemIndex: Int
        itemIndex = self.index(for: key)
        
        // Append new element.
        // This bucket cell not necessarily empty
        buckets[itemIndex].append(HashElement(key: key, value: value))
        
        
            //return nil
    }
    
    func removeValue(for key: K) -> V? {
        let index = self.index(for: key)
        for (i, element) in buckets[index].enumerated() {
            if element.key == key {
                buckets[index].remove(at: i)
                return element.value
            }
        }
        
        return nil
    }
}
