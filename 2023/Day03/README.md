# 3일

https://adventofcode.com/2023/day/3

## 입력

예제 입력은 아래와 같다.

```
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
```



```
let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")
    .map(String.init)
```


## 1부

`.`을 제외한 특수기호에 인접한(대각선으로라도) 숫자(부품번호)의 합을 구하는 문제이다.

각 줄의 숫자와 기호에 대해 이전 줄의 숫자와 기호에 인접한지를 확인하자.  
기호에 인접한 숫자를 확인한 경우 저장하는 딕셔너리를 정의한다.

```
var dict = [[Int]: [Substring]]()
```

딕셔너리의 키(key)는 기호의 위치(행과 열)를 담은 배열이다.  튜플로 하고 싶었지만 [`Hashable` 프로토콜을 아직 지원하지 않는 문제](https://www.reddit.com/r/swift/comments/132ecs7/comment/ji4o1d2/)가 있다.

편의를 위해 딕셔너리에 숫자를 추가하는 함수를 정의하자.

```
func add(number: Substring, to p: [Int]) {
    dict[p] = (dict[p] ?? []) + [number]
}
```

위/아래 줄의 숫자와 기호가 대각선을 포함해 인접한 경우는 세 가지 이다.

```
.111.22.33.
..*....#...
```
  
1. 숫자의 열 범위에 기호의 열이 포함되는 경우 (111과 *)
1. 숫자의 마지막 열 다음 열에 기호가 있는 경우 (22와 #)
1. 숫자의 첫 열 앞 열에 기호가 있는 경우 (33과 #)

코드로는 

```
func isAdjacent(number range: Range<Int>, symbol col: Int) -> Bool {
    range.contains(col) || range.lowerBound == col + 1 || range.upperBound == col
}
```

그런데 스위프트 문자열의 인덱스는 `Int`가 아니기 때문에 변환하는 computed property를 `Substring`의 확장에 정의하자.

```
extension Substring {
    var column: Int {
        base.distance(from: base.startIndex, to: startIndex)
    }
    
    var range: Range<Int> {
        let l = column
        return l..<(l + count)
    }
}
```

이전 줄에 있는 숫자와 기호의 위치를 저장하는 배열이다.  첫 줄의 경우 이전 줄이 없기 때문에 빈 배열로 초기화한다.

```
var lastNumbers = [Substring]()
var lastSymbols = [Int]()
```

각 줄에서 찾은 숫자와 기호를 저장할 배열을 정의한다.

```
for (r, line) in input.enumerated() {
    var numbers = [Substring]()
    var symbols = [Int]()
```
   
현재 줄에서 정규식으로 찾은 숫자와 기호의 범위를 배열에 저장한다.

```
    for m in line.matches(of: #/\d+|[^\.]/#) {
```

배열의 원소가 숫자이면 이전 줄의 기호들과 인접한지 확인한다.

```
        if m.0.first!.isNumber {
            let range = m.0.range
            for symbol in lastSymbols.filter({ isAdjacent(number: range, symbol: $0) }) {
```

인접하면 숫자를 딕셔너리에 저장한다.

```
                add(number: m.0, to: [r - 1, symbol])
            }
```

현재 줄의 마지막 기호가 이 숫자 바로 앞 열에 있으면 숫자를 딕셔너리에 저장한다.

```
            if symbols.last == range.startIndex - 1 {
                add(number: m.0, to: [r, symbols.last!])
            }
```

숫자를 `numbers` 배열에 추가한다.

```
            numbers.append(m.0)
```

배열의 원소가 기호인 경우 이전 줄의 숫자들과 인접하면 딕셔너리에 해당 숫자를 저장한다.

```
        } else {
            let col = m.0.column
            for number in lastNumbers.filter({ isAdjacent(number: $0.range, symbol: col) }) {
                add(number: number, to: [r, col])
            }
```

현재 줄의 마지막 숫자가 기호 바로 앞 열에 있을 경우도 저장한다.

```
            if numbers.last?.range.endIndex == col {
                add(number: numbers.last!, to: [r, col])
            }
```

기호의 열을 `symbols` 배열에 추가한다.

```
            symbols.append(col)
        }
    }
```

현재 줄의 처리가 끝나면 현재 줄에서 발견한 숫자와 기호를 이전 줄을 위한 변수로 옮기고 다음 줄을 처리한다.

```
    lastNumbers = numbers
    lastSymbols = symbols
}
```

기호에 인접한 숫자는 모두 딕셔너리에 들어있으니 합산하면 1부의 답이다.

```
print(dict
    .flatMap { $0.value }
    .map(String.init)
    .compactMap(Int.init)
    .reduce(0, +),
```

사실 1부 만을 위해서는 딕셔너리에 넣지 않고 바로 합계 변수에 더해주는게 더 효율적이다.

## 2부

기호 중 `*` 글자이고 인접한 숫자가 딱 2개인 기어(gear)들의 기어비(gear ratio)를 합산하는 문제이다.  기어비는 인접한 숫자들을 곱한 것이다.

딕셔너리에 있는 기호 중 `*`이고 값으로 두 개의 원소를 가진 배열인 것들을 찾아서 계산한다.

```
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
```

문자열의 인덱스를 구하는 부분이 좀 복잡해 보인다.

## 결론

문자열에서 두자릿수 이상의 숫자를 찾는 데는 역시 정규식이 편리하다.
스위프트의 문자열은 숫자 인덱싱을 지원하지 않기 때문에 인접여부를 확인하는 부분은 대응하는 숫자 인덱스를 구해서 사용했다.
튜플이 `Hashable` 프로토콜을 지원하는 날이 어서 왔으면!
 
