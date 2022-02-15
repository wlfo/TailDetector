
public class LinkedList<T:Equatable> {
    var head: Node<T>?
    private var tail: Node<T>?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    //first
    public var first: Node<T>? {
        return head
    }
    
    //last
    public var last: Node<T>? {
        return tail
    }
    
    public func contains(pred: (T,T) -> Bool, value: T) -> Bool {
        if count > 0 {
            var node = head
            while node != nil {
                
                if pred(node!.value, value) {
                    return true
                }
                
                
                node = node!.next
            }
        } else {
            return false
        }
        
        return false
    }
    
    
    //Append node to LinkedList
    public func append(value: T) {
        let newNode = Node(value: value)
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    func insert(node: Node<T>, at index: Int) {
        if index == 0,
           tail == nil {
            head = node
            tail = node
        } else {
            guard let nodeAtIndex = nodeAt(index: index) else {
                print("Index out of bounds.")
                return
            }
            
            if nodeAtIndex.previous == nil {
                head = node
            }
            
            node.previous = nodeAtIndex.previous
            nodeAtIndex.previous?.next = node
            
            node.next = nodeAtIndex
            nodeAtIndex.previous = node
        }
    }
    
    //Find Node at Index
    public func nodeAt(index: Int) -> Node<T>? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }
    
    public func removeAll() {
        head = nil
        tail = nil
    }
    
    //remove Node
    public func remove(node: Node<T>) -> T {
        let previousNode = node.previous
        let nextNode = node.next
        
        if let prev = previousNode {
            prev.next = nextNode
        } else {
            head = nextNode
        }
        nextNode?.previous = previousNode
        
        if nextNode == nil {
            tail = previousNode
        }
        
        node.previous = nil
        node.next = nil
        
        return node.value
    }
    
    var count: Int {
        if (head?.value == nil) {
            return 0
        }
        else {
            var current: Node? = head
            var x: Int = 1
            
            //cycle through the list of items
            while ((current?.next) != nil) {
                current = current?.next!
                x += 1
            }
            return x
        }
    }
    
    
    //remove from index
    func remove(at index: Int) {
        var toDeleteNode = nodeAt(index: index)
        guard toDeleteNode != nil else {
            print("Index out of bounds.")
            return
        }
        
        let previousNode = toDeleteNode?.previous
        let nextNode = toDeleteNode?.next
        
        if previousNode == nil {
            head = nextNode
        }
        
        if toDeleteNode?.next == nil {
            tail = previousNode
        }
        
        previousNode?.next = nextNode
        nextNode?.previous = previousNode
        
        toDeleteNode = nil
    }
}


public class Node<T:Equatable>: Equatable {
    public static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
        return lhs.value == rhs.value
    }
    
    var value: T
    var next: Node<T>?
    weak var previous: Node<T>?
    
    init(value: T) {
        self.value = value
    }
}
