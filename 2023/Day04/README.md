# 4일

https://adventofcode.com/2023/day/4

## 입력

예제 입력:

```
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
```

줄바꿈으로 나누고 또 `|`로 나누고 정규식으로 숫자만 뽑아서 `Int`를 생성하여 배열에 저장한다.

```
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
```

타입은 `[(Array<Int>.SubSequence, [Int])]`이 된다.

## 1부

`|` 왼쪽에 있는 숫자들 중 같은 숫자가 오른쪽에 있는 갯수로 계산한 점수의 합계를 구하는 문제이다.

어떤 값들에 포함되었는지 확인할 때는 `Set`(집합)을 쓰는 게 효율적이니 왼쪽에 있는 숫자들로 만들자.

```
print(input
    .map { (w, m) in
        let s = Set(w)
```

이제 오른쪽 숫자들 중 집합에 포함된 것만 남겨서

```
        return m
            .filter { s.contains($0) }
```

갯수를 구한다.

```
            .count
    }
```

점수 계산은 일치하는 숫자가 1개이면 1점 이후 1개 마다 두배가 된다.
일치하는 숫자가 n개이면 2의 n-1 제곱이다.

```
    .map { $0 > 0 ? pow(2, $0 - 1) : 0 }
```

점수를 합산하면 1부의 답이다.

```
    .reduce(0, +)
)
```

## 2부

사실은 점수라는 건 없었다고...
10번 카드에 일치하는 숫자가 5개 있으면 11번부터 15번까지의 카드를 1장씩 더 받는다.
이 것은 더 받는 카드가 없게 될 때까지 반복한다.
입력에 있는 최대 카드 번호를 넘는 카드는 받지 않는다.
위 규칙으로 입력을 처리했을 때 입력에 있던 카드와 더 받은 카드를 모두 합한 갯수를 구하는 문제이다.

카드의 갯수를 저장하는 배열을 정의하자.  처음에는 입력에 있는 카드를 한 장씩 갖고 있다.  입력에는 카드번호가 1부터 시작하지만 스위프트의 배열은 0부터이다.

```
var cards = Array(repeating: 1, count: input.count)
```

입력에 대해 `for` 반복문으로 처리한다.  일치하는 숫자가 없는 경우는 건너뛴다.

```
for (i, (w, m)) in input.enumerated() {
    let s = Set(w)
    let n = m.filter { s.contains($0) }.count
    guard n > 0 else { continue }
```

다음 `n`개의 카드에 `i`번 카드의 갯수를 더한다.  입력에 없는 카드번호는 건너뛴다.
 
```
    for j in (i + 1)...(i + n) {
        guard j < cards.count else { break }
        cards[j] += cards[i]
    }
}
```

카드 갯수를 합산하면 끝!

```
print(cards.reduce(0, +))
```

## 결론

`Set`을 쓸 줄 알면 큰 어려움 없이 풀 수 있는 문제이다.

