import Foundation

let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")

// part 1

print(input.map {
    let m = $0.matches(of: #/\d/#)
    return Int(m.first!.0 + m.last!.0)!
}
.reduce(0, +))

// part 2

func f(_ s: Substring) -> String {
    let t = [
        "one":   "1",
        "two":   "2",
        "three": "3",
        "four":  "4",
        "five":  "5",
        "six":   "6",
        "seven": "7",
        "eight": "8",
        "nine":  "9",
    ]
    return t[String(s)] ?? String(s)
}

print(input.map {
    let first = $0.firstMatch(of: #/\d|one|two|three|four|five|six|seven|eight|nine/#)
    let last = $0.wholeMatch(of: #/.*(\d|one|two|three|four|five|six|seven|eight|nine).*/#)
    return Int(f(first!.0) + f(last!.1))!
}
.reduce(0, +))
