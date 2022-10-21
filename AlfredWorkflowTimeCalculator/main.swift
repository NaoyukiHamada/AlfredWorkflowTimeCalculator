//
//  main.swift
//  AlfredWorkflowTimeCalculator
//
//  Created by Naoyuki Hamada on 2022/10/21.
//
//

import Foundation

struct ScriptFilter: Codable {
    let items: [Item]
    struct Item: Codable {
        let title: String
        var subtitle: String? = nil
        var arg: String? = nil
    }

    func toJsonString() -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
//            print(error.localizedDescription)
        }
        return nil
    }
}

extension String {
    func stringTokens(splitMarks: Set<String>) -> [String] {
        var string = ""
        var desiredOutput = [String]()
        // 文字列を1つずつチェック
        for ch in self {
            if splitMarks.contains(String(ch)) {
                // 分割文字の場合
                if !string.isEmpty {
                    // 文字列が空でない場合は、分割文字の前に文字列があったということなので先に配列に追加
                    desiredOutput.append(string)
                }
                // 分割文字を配列に追加
                desiredOutput.append(String(ch))
                // 仮の文字列の箱をリセット
                string = ""
            } else {
                // 分割文字でない場合は文字列をつなげる
                string += String(ch)
            }
        }
        if !string.isEmpty {
            // 最後の文字列を配列に追加
            desiredOutput.append(string)
        }
        return desiredOutput
    }
}

func convertToMinute(timeString: String) -> Int? {
    let timeComponents: [Int] =
            timeString.components(separatedBy: ":")
                    .map { s -> Int? in
                        Int(s)
                    }.compactMap { $0 }
    if timeComponents.count != 2 {
        return nil
    }
    var n = 60
    return timeComponents.reduce(0) {
        defer { n /= 60 }
        return ($0 ?? 0) + $1 * n
    }
}

let splitMarks: Set = ["+", "-"]

let args = CommandLine.arguments
let arg = args[1]
//print(args[1])

let allComponent = arg.stringTokens(splitMarks: splitMarks)
//print(allComponent)

var totalMinute = 0

enum OperatorType {
    case plus
    case minus
}

var operatorType = OperatorType.plus
for component in allComponent {
    if splitMarks.contains(component) {
        if component == "+" {
            operatorType = OperatorType.plus
        } else if component == "-" {
            operatorType = OperatorType.minus
        } else {
//            print("Invalid operator format \(component). e.g.[+,-]")
            if let result = ScriptFilter(items: [ScriptFilter.Item(title: "Invalid operator format '\(component)'. e.g.[+,-]")]).toJsonString() {
                print(result)
            }
            exit(0)
        }
    } else {
        if let minute = convertToMinute(timeString: component) {
            if operatorType == OperatorType.plus {
                totalMinute += minute
            } else if operatorType == OperatorType.minus {
                totalMinute -= minute
            }
        } else {
//            print("Invalid time format \(component). e.g.00:00")
            if let result = ScriptFilter(items: [ScriptFilter.Item(title: "Invalid time format '\(component)'. e.g.00:00")]).toJsonString() {
                print(result)
            }
            exit(0)
        }
    }
}


//print("totalMinute \(totalMinute)")
//print("timeInterval \(TimeInterval(totalMinute * 60))")
let dcf = DateComponentsFormatter()
dcf.allowedUnits = [.hour, .minute]
dcf.unitsStyle = .positional
dcf.zeroFormattingBehavior = .pad
if let displayTime = dcf.string(from: TimeInterval(totalMinute * 60)) {
    var resultDisplayTime = ""
    if totalMinute < 0 && !displayTime.contains("-") {
        resultDisplayTime = "-\(displayTime)"
    } else {
        resultDisplayTime = displayTime
    }
//    print("resultDisplayTime \(resultDisplayTime)")
    if let result = ScriptFilter(items: [ScriptFilter.Item(title: resultDisplayTime, subtitle: "copy to clipboard", arg: resultDisplayTime)]).toJsonString() {
        print(result)
    }
}
