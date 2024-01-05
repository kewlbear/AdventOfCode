import Foundation

let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")
    .map(String.init)

var dict = [[Int]: [Substring]]()

func add(number: Substring, to p: [Int]) {
    dict[p] = (dict[p] ?? []) + [number]
}

func isAdjacent(number range: Range<Int>, symbol col: Int) -> Bool {
    range.contains(col) || range.lowerBound == col + 1 || range.upperBound == col
}

extension Substring {
    var column: Int {
        base.distance(from: base.startIndex, to: startIndex)
    }
    
    var range: Range<Int> {
        let l = column
        return l..<(l + count)
    }
}

var lastNumbers = [Substring]()
var lastSymbols = [Int]()

for (r, line) in input.enumerated() {
    var numbers = [Substring]()
    var symbols = [Int]()
    
    for m in line.matches(of: #/\d+|[^\.]/#) {
        if m.0.first!.isNumber {
            let range = m.0.range
            for symbol in lastSymbols.filter({ isAdjacent(number: range, symbol: $0) }) {
                add(number: m.0, to: [r - 1, symbol])
            }
            if symbols.last == range.startIndex - 1 {
                add(number: m.0, to: [r, symbols.last!])
            }
            numbers.append(m.0)
        } else {
            let col = m.0.column
            for number in lastNumbers.filter({ isAdjacent(number: $0.range, symbol: col) }) {
                add(number: number, to: [r, col])
            }
            if numbers.last?.range.endIndex == col {
                add(number: numbers.last!, to: [r, col])
            }
            symbols.append(col)
        }
    }
    
    lastNumbers = numbers
    lastSymbols = symbols
}

print(
    dict
        .flatMap { $0.value }
        .map(String.init)
        .compactMap(Int.init)
        .reduce(0, +),
    dict
        .filter {
            let p = $0.key
            let line = input[p[0]]
            return line[line.index(line.startIndex, offsetBy: p[1])] == "*" &&
            $0.value.count == 2
        }
        .map {
            $0.value
                .map(String.init)
                .compactMap(Int.init)
                .reduce(1, *)
        }
        .reduce(0, +)
)
