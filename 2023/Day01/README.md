# 1일

https://adventofcode.com/2023/day/1

## 입력

예제 입력은 아래와 같다.

```
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

파일을 읽고 줄바꿈("\n")으로 나눌 수 있고

```
let path = CommandLine.arguments[1]
let input = try! String(contentsOfFile: path)
    .split(separator: "\n")
```

표준 입력 스트림에서 한 줄씩 읽을 수도 있다.

```
var input = [String]()

while let line = readLine() {
    input.append(line)
}
```
 
위의 경우 input의 타입은 Substring 배열이고 아래는 String 배일이다.  Xcode에서 실행하려면 위 방법이 좋고 아래는 다른 프로그램의 출력을 파이프로 전달받을 때 편리하다. 

## 1부

각 줄의 첫 번째 숫자와 마지막 숫자를 붙여 만든 두 자리 숫자의 합을 구하는 문제이다.  예제의 경우 `12`, `38`, `15`, `77`을 더해서 `142`가 된다.

각 줄에서 숫자를 찾는 방법은 여러 가지가 있지만 지금은 정규식을 사용한다.  숫자에 해당하는 정규식 패턴은 `\d`이므로 아래와 같이 하면 모든 숫자에 대한 일치(match)의 배열을 얻는다.

```
    let m = line.matches(of: #/\d/#)
```

정규식을 사용하려면 Package.swift에 아래 줄을 추가해준다.

```
    platforms: [.macOS(.v13)],
```

지금은 Swift Package에서 사용하는 것이 아니라면 `/\d/`로 쓸 수 있다.
문제에서 요구하는 것은 첫번째와 마지막 숫자를 붙인 것이므로 아래와 같이 한다.

```
    m.first!.0 + m.last!.0
```

이 문자열을 이용해 Int 값을 구한다.

```
    Int(m.first!.0 + m.last!.0)!
```

위 과정을 for 문을 사용해 합산할 수도 있지만 지금은 map reduce를 사용한다.

```
input.map {
    let m = $0.matches(of: #/\d/#)
    return Int(m.first!.0 + m.last!.0)!
}  
```

결과는 Int 배열이 된다.  이 것을 합산하려면 

```
.reduce(0, +))
```

  
## 2부

one, two, three, four, five, six, seven, eight, nine도 유효한 숫자로 친다는 조건이 추가되었다.
예를 들어

```
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

의 경우 `29`, `83`, `13`, `24`, `42`, `14`, `76`을 더한 `281`이 답이다.

정규식을 아래와 같이 바꾸면 될 것이다.

```
/\d|one|two|three|four|five|six|seven|eight|nine/
```

숫자로 바꾸는 것은 딕셔너리를 사용한다.

```
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
```

편의를 위해 함수를 하나 정의한다.

```
func f(_ s: Substring) -> String {
    return t[String(s)] ?? String(s)
}
```

Int 값을 만드는 부분도 바꾼다.

```
    Int(f(m.first!.0) + f(m.last!.0))!
```

그런데 잘못된 답이 나온다.  사실 이 글을 쓰기 이전에 사용한 코드는 정답이 나온다.  정규식 처리 부분이 조금 달라서 비교하면서 원인을 찾아봤다.  입력에 아래와 같은 줄이 있다.

```
1six15ninebgnzhtbmlxpnrqoneightfhp
```

전에 사용한 코드는 `eight`을 찾는데 `matches(of:)`는 `one`을 찾는다!  검색을 해보니 아직까지 Swift는 overlapping match를 지원하지 않는 것으로 보인다.  따라서 지금은 아래와 같은 코드를 사용한다.

```
    let first = $0.firstMatch(of: #/\d|one|two|three|four|five|six|seven|eight|nine/#)
    let last = $0.wholeMatch(of: #/.*(\d|one|two|three|four|five|six|seven|eight|nine).*/#)
    return Int(f(first!.0) + f(last!.1))!
```

`last`의 경우 괄호 안의 값을 써야하기 때문에 `.1`인 것에 주의하자.

## 결론

정규식을 사용하면 쉽게 풀 수 있는 문제이다.  Swift에도 빨리 overlapping match 지원이 추가되면 좋겠다.

