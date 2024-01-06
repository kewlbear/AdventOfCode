import Foundation

let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")
    .map {
        let m = $0.split(separator: "|")
            .map {
                $0.matches(of: #/\d+/#)
                    .map(\.0)
                    .map(String.init)
                    .compactMap(Int.init)
            }
        return (m[0][1...], m[1])
    }

print(input
    .map { (w, m) in
        let s = Set(w)
        return m
            .filter { s.contains($0) }
            .count
    }
    .map { $0 > 0 ? pow(2, $0 - 1) : 0 }
    .reduce(0, +)
)

var cards = Array(repeating: 1, count: input.count)

for (i, (w, m)) in input.enumerated() {
    let s = Set(w)
    let n = m.filter { s.contains($0) }.count
    guard n > 0 else { continue }
    
    for j in (i + 1)...(i + n) {
        guard j < cards.count else { break }
        cards[j] += cards[i]
    }
}

print(cards.reduce(0, +))
