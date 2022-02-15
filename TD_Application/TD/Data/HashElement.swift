//
//  HashElement.swift
//  TD
//
//  Created by Sharon Wolfovich on 19/02/2021.
//

import Foundation

class HashElement<K: Hashable, V> {
    var key: K
    var value: V?
    
    init(key: K, value: V){
        self.key = key
        self.value = value
    }
    
}
