import Testing
@testable import PDJSKit

@Test("extractFunctionNames") func extractFunctionNames() {
    let source = "test(), aaa(),\nfoo()"
    let result = source.extractFunctionNames()
    #expect(result == Set(["test", "aaa", "foo"]))
}

@Test("evaluateScheduledFunctions") func evaluateScheduledFunctionsTest() {
    let scheduleSource = """
    test(), aaa(),
    foo()

    """
    let testScript = """
    function test(){
        console.log('aaa');
    }
    function foo(){
        console.log('aaa');
    }
    """
    let names = evaluateScheduledFunctions(
        userScript: testScript,
        scheduleDefinition: scheduleSource
    )
    #expect(names == ["test", "foo"])
}
