import Foundation

let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")

let gs = input.enumerated().map { offset, line in
    (offset + 1,
     line
        .split(separator: ";")
        .map { set in
            Dictionary(uniqueKeysWithValues:
                        set
                .matches(of: #/(\d+) (red|green|blue)/#)
                .map { m in
                    (String(m.2), Int(String(m.1))!)
                })
        })
}

// part 1

print(gs
    .filter { _, g in
        g.allSatisfy { d in
            d.allSatisfy { (k, v) -> Bool in
                switch k {
                case "red": v <= 12
                case "green": v <= 13
                case "blue": v <= 14
                default: fatalError()
                }
            }
        }
    }
    .map(\.0).reduce(0, +))

// part 2

let ps = gs.map { _, g in
    ["red", "green", "blue"].map { c in
        g.map { $0[c] ?? 0 }
            .max()!
    }
    .reduce(1, *)
}

print(ps.reduce(0, +))
