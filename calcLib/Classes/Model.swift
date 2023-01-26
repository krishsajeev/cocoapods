//
//  Data.swift
//  CALC
//
//  Created by sajeev-pt6810 on 17/01/23.
//

import Foundation

public class Model {
    
    
    private var num: Model.Number
    private var numStk: Model.Stack<Int>
    private var opStk: Model.Stack<Model.Operation>
    
    init() {
        self.num = Model.Number()
        self.numStk = Model.Stack<Int> ()
        self.opStk = Model.Stack<Model.Operation> ()
        
    }
    
    // --------------------------- Data Structures ----------------------
    
    public enum Digit: Int, CaseIterable, CustomStringConvertible {
        case zero = 0, one, two, three, four, five, six, seven, eight, nine
        
        public var description: String {
            "\(rawValue)"
        }
        
    }

    public enum Operation: String, CaseIterable, CustomStringConvertible {
        case addition = "+", subtraction = "-", multiplication = "*", division = "/"
        
        public var description: String {
            switch (self) {
            case .addition:
                return "+"
            case .subtraction:
                return "-"
            case .multiplication:
                return "*"
            case .division:
                return "/"
            }
        }
    }

    public enum Button: Hashable, CustomStringConvertible {
        case operation(_ operation: Operation)
        case digit(_ number: Digit)
        case compute
        case allClear
        
        public var description: String {
            switch (self) {
            case .operation(let operation):
                return operation.description
            case .digit(let number):
                return number.description
            case .compute:
                return "="
            case .allClear:
                return "AC"
            }
        }
    }
    
    
    private class Stack<T> {    // Stack datastructure to perform Infix expression evaluation
        private var items: [T] = []
        
        func peek() -> T? {
            if isEmpty() {
                return nil
            }
            else {
                return items.first
            }
        }
        
        func isEmpty() -> Bool {
            return items.isEmpty
        }
        
        func pop() -> T {
            return items.removeFirst()
        }
      
        func push(_ element: T?) {
            if element != nil {
                items.insert(element!, at: 0)
            }
        }
        
        func size() -> Int {
            return items.count
        }
    }

    private class Number {  // Wrapper Class to hold a number
        private var value: Int?
        
        init() {
            self.value = nil
        }
        
        func get() -> Int? {
            return self.value
        }
        
        func set(value: Int) {
            if self.value == nil {
                self.value = 0
            }
            self.value = self.value! * 10 + value
        }
        
        func clear() {
            self.value = nil
        }
        
    }


    public func buttonPressed(_ button: Model.Button) -> (expression: String?, result: String?, replace: Bool){
        switch (button) {
        case .compute:
            return compute()    // = Button pressed
        case .allClear:
            return reset()    // AC Button pressed
        case .operation:
            return operation(button: button)  // +, -, /, * button pressed
        case .digit:
            return click(button: button) // 0 ... 9 button pressed
        }
    }
    
    
    private func compute() -> (expression: String?, result: String?, replace: Bool){
        numStk.push(num.get())
        num.clear()
        
        let result = purgeStacks(operators: opStk, numbers: numStk)
        if !result {
            var displayMessage = reset()
            displayMessage.result = "ERROR"
            return displayMessage
        }
        return (nil, String(numStk.peek()!), true)
    }
    
    private func operation(button: Model.Button) -> (expression: String?, result: String?, replace: Bool){
        
        let op = Model.Operation(rawValue: button.description)!
        
        numStk.push(num.get())
        num.clear()
        
        
        if !opStk.isEmpty() {
            if !(Model.compare(op1: opStk.peek()!, op2: op) < 0) {
                let result = purgeStacks(operators: opStk, numbers: numStk)
                if !result {
                    var displayMessage = reset()
                    displayMessage.result = "ERROR"
                    return displayMessage
                }
            }
        }
        opStk.push(op)
        
        return (button.description, nil, false)
    }
    
    private func click(button: Model.Button) -> (expression: String?, result: String?, replace: Bool){
        let number = Model.getNumber(number: button.description)
        
        //expressionChange(text: number.description)
        
        num.set(value: number)
        
        return (number.description, nil, false)
    }
    
    
    private func reset() -> (expression: String?, result: String?, replace: Bool){
        numStk = Model.Stack<Int> ()
        opStk = Model.Stack<Model.Operation> ()
        num.clear()
        
        return (" ", " ", true)
    }
    
    private func purgeStacks(operators: Model.Stack<Model.Operation>, numbers: Model.Stack<Int>) -> Bool{ //Infix Expression evaluation algorithm
        if(numbers.size() - 1 != operators.size()) {
            return false
        }
        while (!operators.isEmpty()) {
            var num1 = 0
            var num2 = 0
            
            if(!numbers.isEmpty()){
                num1 = numbers.pop()
            }
            if(!numbers.isEmpty()){
                num2 = numbers.pop()
            }
            
            let result = Model.calculate(num1: num2, op: operators.pop(), num2: num1)
            
            if result == nil {
                return false
            }
            else{
                numStk.push(result)
            }
            
        }
        return true
    }
    

    //-------------- Helper functions used by Controller -------------------

    private static func getNumber(number: String) -> Int { // Returns the Integer value of a numeral
        return Int(number)!
    }
    
    private static func getPrecedence(op: Operation) -> Int {   // Returns the precedence rank for the Operation
        switch(op) {
        case Operation.addition, Operation.subtraction:
            return 0
        case Operation.division, Operation.multiplication:
            return 1
        }
    }

    private static func compare(op1: Operation, op2: Operation) -> Int{  // Compare two Operations using precedence ranks
        return getPrecedence(op: op1) - getPrecedence(op: op2)
    }

    private static func calculate(num1: Int, op: Operation, num2: Int) -> Int? { // Calculate the result for a binary Operation
        switch(op){
        case Operation.addition:
            return num1 + num2
        case Operation.multiplication:
            return num1 * num2
        case Operation.division:
            if num2 == 0 {
                return nil
            }
            else {
                return num1 / num2
            }
        case Operation.subtraction:
            return num1 - num2
        }
    }
    
}
