# 2일

https://adventofcode.com/2023/day/2

## 입력

```
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
```

1일과 마찬가지로 줄바꿈으로 나눈다.

```
let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")
```

## 1부

입력에 있는 게임 중 빨간(r) 큐브 12개, 녹색(g) 큐브 13개, 파란(b) 큐브 14개로 가능한 갯수를 알아내는 문제이다.

게임 ID는 1부터 증가하는 번호이기 때문에 `enumerated()`로 생성되는 `offset`에 1을 더한 값을 쓴다.

```
let gs = input.enumerated().map { offset, line in
    (offset + 1,
```

각 줄을 `";"`으로 나누고 정규식 `/(\d+) (red|green|blue)/`으로 세트별 큐브 개수와 색깔을 뽑는다.

```
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
```
 
위의 결과는 `[[[String: Int]]]`가 된다.  정규식의 두 번째 괄호가 딕셔너리의 키이고 첫 번째가 값이다.

불가능한 게임을 제외하기 위해 `filter`를 사용한다.  각 게임의 모든 세트가 가 가능해야 하고 모든 컬러가 가능해야 하기 때문에 `allSatisfy`를 두 번 쓴다.

```
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
```

결과는 ID의 합이므로 `.map(\.0).reduce(0, +)`를 사용한다.

## 2부

각 게임의 컬러별 최대 큐브 갯수를 모두 곱하면 파워가 된다.  모든 게임의 파워를 더하면 2부의 답이다.

모든 게임에 대해 컬러별로 큐브 갯수를 `map`한다.

```
let ps = gs.map { _, g in
    ["red", "green", "blue"].map { c in
        g.map { $0[c] ?? 0 }
```

컬러별로 최대 큐브 갯수를 구한다.

```
            .max()!
    }
```

모든 컬러의 값을 곱해서 파워를 구한다.

```
    .reduce(1, *)
}
```

모든 파워를 더한다.

```
.reduce(0, +)
```

## 결론

이번에도 정규식과 `map`, `reduce`, `allSatisfy`, `Dictionary(uniqueKeysWithValues:)` 등을 알면 어렵지 않게 풀 수 있는 문제다.
