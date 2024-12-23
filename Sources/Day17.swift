import Foundation

public enum Day17 {
    public enum Part1 {
        static func solve(_ data: String) -> String {
            data.chronospatialComputerInput
                .run()
                .output
                .reduce("") { str, value in
                    str + String(value) + ","
                }.dropLastChar
        }
    }

    public enum Part2 {
        static func solve(_ data: String) -> Int {
            -1
        }
    }
}

extension String {
    var chronospatialComputerInput: ChronospatialComputer {
        let parts = splitByEmptyLines
        let registers = parts[0].lines()

        return ChronospatialComputer(
            registerA: registers.registerValues(index: 0),
            registerB: registers.registerValues(index: 1),
            registerC: registers.registerValues(index: 2),
            program: parts[1].extractIntValues
        )
    }

    fileprivate var extractIntValues: [Int] {
        split(separator: ":").last!
        .map(String.init)
        .compactMap(Int.init)
    }

    var dropLastChar: String {
        String(self.dropLast())
    }
}

private extension Array where Element == String {
    func registerValues(index: Int) -> Int {
        Int(String(self[index].split(separator: ": ").last!))!
    }
}

struct ChronospatialComputer {
    var registerA: Int
    var registerB: Int
    var registerC: Int
    var program: [Int]
    var instructionPointer: Int = 0
    var output: [Int] = []

    func run() -> ChronospatialComputer {
        var updatedState = self
        while updatedState.instructionPointer < program.count {
            updatedState = updatedState.processNextInstruction()
        }
        return updatedState
    }

    func processNextInstruction() -> ChronospatialComputer {
        let opcode = Opcode(rawValue: program[instructionPointer])!

        var updatedState = self
        updatedState.instructionPointer += 2
        switch opcode {
        case .adv: // division
            updatedState.registerA = advOpcodeOuput()
            return updatedState
        case .bxl:
            // bitwise XOR of registerB and literalOperand -> register B
            updatedState.registerB = bitwiseXOR(first: registerB, second: literalOperand)
            return updatedState
        case .bst:
            updatedState.registerB = comboOperand % 8
            return updatedState
        case .jnz:
            guard registerA != 0 else { return updatedState } // no-op
            updatedState.instructionPointer = literalOperand
            return updatedState
        case .bxc:
            updatedState.registerB = bitwiseXOR(first: registerB, second: registerC)
            return updatedState
        case .out:
            updatedState.output.append(comboOperand % 8)
            return updatedState
        case .bdv:
            updatedState.registerB = advOpcodeOuput()
            return updatedState
        case .cdv:
            updatedState.registerC = advOpcodeOuput()
            return updatedState
        }
    }

    func bitwiseXOR(first: Int, second: Int) -> Int {
        first ^ second
    }

    func advOpcodeOuput() -> Int {
        let numerator = Decimal(registerA)
        let denominator = pow(2, comboOperand)
        let quotient = numerator / denominator
        return Int(floor(NSDecimalNumber(decimal: quotient).doubleValue))
    }

    var literalOperand: Int {
        program[instructionPointer + 1]
    }

    var comboOperand: Int {
        let operand = literalOperand
        switch operand {
        case 0...3: return operand
        case 4: return registerA
        case 5: return registerB
        case 6: return registerC
        case 7: preconditionFailure("7 is reserved for future use")
        default: preconditionFailure("Invalid operand: \(operand)")
        }
    }
}

struct ChronospatialComputerInstruction {
    let opcode: Opcode
    let operand: Int
}

enum Operand: Int {
    case zero = 0
    case one
    case two
    case three
    case four // value register A
    case five // value register B
    case six // value register C
    case seven // reserved
}

enum Opcode: Int {
    case adv = 0
    case bxl
    case bst
    case jnz
    case bxc
    case out
    case bdv
    case cdv
}

// 3 registers -> A, B, C -> can hold any integer
// 3-bit numbers -> 0 through 7
// eight instructions identified by 3-bit opcode
// each instruction reads 3-bit number after it as an input -> operand
// instruction pointer -> position in program from which next opcode will be read
//   -> starts at 0 -> first 3-bit number
//   -> except for jump instructions, pointer increase by 2 after each instruction is processed (move past opcode and operand)
//   -> if computer tries to read an opcode past the end of the program it halts

// 0,1,2,3
// opcode 0, pass to 1
// opcode 2, pass to 3
// halt

// two types of operand
// literal operand value is itself
// combo operand

// 0 through 3 -> literal 0 through 3
// 4 -> register A
// 5 -> register B
// 6 -> register C
// 7 reserved (not in valid programs)

// instructions
// 0 -> adv -> division
//   -> numerator is value in A register, denominator is 2 power of combo operand
// 1 -> bxl
// 2 -> bst
// 3 -> jnz
// 4 -> bxc
// 5 -> out
// 6 -> bdv
// 7 -> cdv

// Register A: 729
// Register B: 0
// Register C: 0
//
// Program: 0,1,5,4,3,0

// Run program
// -> run opcode 0 (adv), pass to operand 1 (literal 1)
// -> run opcode 5 (out), pass to operand 4 (register A value)
// -> run opcode 3 (jnz), pass to operand 0 (literal 0)
