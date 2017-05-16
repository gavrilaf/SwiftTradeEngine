//
//  FastDeque.swift
//  SwiftOrderBook
//
//  Created by Eugen Fedchenko on 5/16/17.
//
//

import Foundation

public final class FastDeque<E> {
    
    public init() {
        nilNode = Node<E>()
        nilNode.next = nilNode
        nilNode.prev = nilNode
    }
    
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == E {
        nilNode = Node<E>()
        nilNode.next = nilNode
        nilNode.prev = nilNode
        
        elements.forEach {
            pushLast($0)
        }
    }
    
    public var isEmpty: Bool {
        return first == nil
    }
    
    public var first: E? {
        return nilNode.next?.value
    }
    
    public var last: E? {
        return nilNode.prev?.value
    }
    
    public func pushFirst(_ e: E) {
        let node = Node(value: e)
        
        node.next = nilNode.next
        node.prev = nilNode
        
        nilNode.next?.prev = node
        nilNode.next = node
    }
    
    public func pushLast(_ e: E) {
        let node = Node(value: e)
        
        node.prev = nilNode.prev
        node.next = nilNode
        
        nilNode.prev?.next = node
        nilNode.prev = node
    }
    
    @discardableResult
    public func popFirst() -> E? {
        let value = nilNode.next?.value
        nilNode.next = nilNode.next?.next
        nilNode.next?.prev = nilNode
        return value
    }
    
    @discardableResult
    public func popLast() -> E? {
        let value = nilNode.prev?.value
        nilNode.prev = nilNode.prev?.prev
        nilNode.prev?.next = nilNode
        return value
    }
    
    public func clear() {
        nilNode.next = nilNode
        nilNode.prev = nilNode
    }
    
    public func updateFirst(block: (inout E) -> Void) {
        if let f = nilNode.next {
            block(&(f.value!))
        }
    }
    
    public func remove(check: (E) -> Bool) {
        var node = nilNode.next
        while let value = node?.value {
            if check(value) {
                node?.next?.prev = node?.prev
                node?.prev?.next = node?.next
                break
            } else {
                node = node?.next
            }
        }
    }
    
    // MARK:
    
    fileprivate class Node<E> {
        var value: E?
        
        var next: Node?
        weak var prev: Node?
        
        init() {
            value = nil
        }
        
        init(value: E) {
            self.value = value
        }
    }
    
    fileprivate let nilNode: Node<E>
}


extension FastDeque: CustomStringConvertible {
    public var description: String {
        var s = "FastDeque["
        
        var p = self.nilNode.next
        var first = true
        while let v = p?.value {
            if first {
                first = false
            } else {
                s += ", "
            }
            s += String(describing: v)
            
            p = p?.next
        }
        
        s += "]"
        return s
    }
}
