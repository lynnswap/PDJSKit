// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import JavaScriptCore

public extension String{
    /// スケジュール定義文字列に書かれた JavaScript 関数名を重複なく抽出する。
    ///
    /// - Parameter source: `test(), aaa()` 形式のスケジュール文字列
    /// - Returns: 抽出された識別子の集合（重複なし）
    func extractFunctionNames() -> Set<String> {
        // 1) 行・ブロックコメントを除去
        let withoutComments = self
            .replacingOccurrences(of: #"//.*"#,  with: "", options: .regularExpression)
            .replacingOccurrences(of: #"/\*[\s\S]*?\*/"#, with: "", options: .regularExpression)
        
        // 2) 「識別子 + (」パターンを抽出
        let pattern = #"\b([$_a-zA-Z][$_0-9a-zA-Z]*)\s*\("#
        let regex   = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: withoutComments,
                                    range: NSRange(withoutComments.startIndex..., in: withoutComments))
        
        return Set(
            matches.compactMap { Range($0.range(at: 1), in: withoutComments) }
                .map{ String(withoutComments[$0]) }
        )
    }
}
public extension JSContext{
    /// JavaScriptCore にロード済みのスクリプト内で
    /// `availableNames` に列挙された関数が実在するか検査し、利用可能なものを返す。
    ///
    /// - Parameters:
    ///   - names: 抽出候補（`extractFunctionNames` の戻り値）
    ///   - context: 実行対象となる `JSContext`
    /// - Returns: `names` に含まれるうち、`typeof window[name] === 'function'` で true となる順序付き配列
    func filterAvailableFunctions<S: Sequence>(
        from names: S
    ) -> [String] where S.Element == String {
        
        let json = try! JSONEncoder().encode(Array(names))
        let js   = """
        (function(list){
            return list.filter(function(n){ return typeof window[n] === 'function'; });
        })(\(String(data: json, encoding: .utf8)!));
        """
        return self.evaluateScript(js)?.toArray() as? [String] ?? []
    }
}
public func evaluateScheduledFunctions(
    userScript: String,
    scheduleDefinition: String,
    in context: JSContext = JSContext()
) -> [String] {

    context.evaluateScript("var window = this;")
    context.evaluateScript(userScript)

    let candidates = scheduleDefinition.extractFunctionNames()
    return context.filterAvailableFunctions(from: candidates)
}

/// ユーザースクリプト内で定義されたグローバル関数名を抽出する。
///
/// - Parameters:
///   - userScript: JavaScript 関数を含むスクリプト文字列
///   - context: 評価に利用する `JSContext`
/// - Returns: `window` に追加された関数の一覧（定義順）
public func listDefinedFunctions(
    userScript: String,
    in context: JSContext = JSContext()
) -> [String] {

    context.evaluateScript("var window = this;")
    let baseline = context.evaluateScript("Object.getOwnPropertyNames(window)")?.toArray() as? [String] ?? []
    context.evaluateScript(userScript)

    let baselineJSON = String(data: try! JSONEncoder().encode(baseline), encoding: .utf8)!
    let js = """
    (function(before){
        var lookup = Object.create(null);
        before.forEach(function(key){ lookup[key] = true; });
        return Object.getOwnPropertyNames(window).filter(function(key){
            if (lookup[key]) { return false; }
            return typeof window[key] === 'function';
        });
    })(\(baselineJSON));
    """

    return context.evaluateScript(js)?.toArray() as? [String] ?? []
}
