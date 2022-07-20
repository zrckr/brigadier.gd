#warning-ignore-all:return_value_discarded

extends WAT.Test

const Command = preload('res://addons/brigadier/main/functions/command.gd')
const CommandDispatcher = preload('res://addons/brigadier/main/command_dispatcher.gd')
const StringRange = preload('res://addons/brigadier/main/context/string_range.gd')
const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const Suggestion = preload('res://addons/brigadier/main/suggestion/suggestion.gd')
const Suggestions = preload('res://addons/brigadier/main/suggestion/suggestions.gd')
const f = preload('./functions.gd')

var subject: CommandDispatcher
var command: Command
var source: Object


func pre() -> void:
    subject = CommandDispatcher.new()
    source = Reference.new()
    command = Command.new()


func test_get_completion_suggestions_root_commands() -> void:
    subject.register(f.literal("foo"))
    subject.register(f.literal("bar"))
    subject.register(f.literal("baz"))
    
    var result = subject.get_completion_suggestions(subject.parse("", source))
    var suggestions = [
        Suggestion.new(StringRange.at(0), "bar"),
        Suggestion.new(StringRange.at(0), "baz"),
        Suggestion.new(StringRange.at(0), "foo"),
    ]
    
    asserts.is_equal(str(result.ranges), str(StringRange.at(0)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_root_commands_with_input_offset() -> void:
    subject.register(f.literal("foo"))
    subject.register(f.literal("bar"))
    subject.register(f.literal("baz"))
    
    var result = subject.get_completion_suggestions(subject.parse_reader(_input_with_offset("OOO", 3), source))
    var suggestions = [
        Suggestion.new(StringRange.at(3), "bar"),
        Suggestion.new(StringRange.at(3), "baz"),
        Suggestion.new(StringRange.at(3), "foo"),
    ]
    
    asserts.is_equal(str(result.ranges), str(StringRange.at(3)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_root_commands_partial() -> void:
    subject.register(f.literal("foo"))
    subject.register(f.literal("bar"))
    subject.register(f.literal("baz"))
    
    var result = subject.get_completion_suggestions(subject.parse("b", source))
    var suggestions = [
        Suggestion.new(StringRange.between(0, 1), "bar"),
        Suggestion.new(StringRange.between(0, 1), "baz"),
    ]
    
    asserts.is_equal(str(result.ranges), str(StringRange.between(0, 1)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_root_commands_partial_with_input_offset() -> void:
    subject.register(f.literal("foo"))
    subject.register(f.literal("bar"))
    subject.register(f.literal("baz"))
    
    var result = subject.get_completion_suggestions(subject.parse_reader(_input_with_offset("Zb", 1), source))
    var suggestions = [
        Suggestion.new(StringRange.between(1, 2), "bar"),
        Suggestion.new(StringRange.between(1, 2), "baz"),
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.between(1, 2)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_sub_commands() -> void:
    subject.register(
        f.literal("parent") \
            .then(f.literal("foo")) \
            .then(f.literal("bar")) \
            .then(f.literal("baz")) \
    )

    var result = subject.get_completion_suggestions(subject.parse("parent ", source))
    var suggestions = [
        Suggestion.new(StringRange.at(7), "bar"),
        Suggestion.new(StringRange.at(7), "baz"),
        Suggestion.new(StringRange.at(7), "foo"),
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.at(7)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_moving_cursor_sub_commands() -> void:
    subject.register(
        f.literal("parent_one") \
            .then(f.literal("faz")) \
            .then(f.literal("fbz")) \
            .then(f.literal("gaz")) \
    )

    subject.register(
        f.literal("parent_two")
    )

    _test_suggestions("parent_one faz ", 0, StringRange.at(0), ["parent_one", "parent_two"])
    _test_suggestions("parent_one faz ", 1, StringRange.between(0, 1), ["parent_one", "parent_two"])
    _test_suggestions("parent_one faz ", 7, StringRange.between(0, 7), ["parent_one", "parent_two"])
    _test_suggestions("parent_one faz ", 8, StringRange.between(0, 8), ["parent_one"])
    _test_suggestions("parent_one faz ", 10, StringRange.at(0), [])
    _test_suggestions("parent_one faz ", 11, StringRange.at(11), ["faz", "fbz", "gaz"])
    _test_suggestions("parent_one faz ", 12, StringRange.between(11, 12), ["faz", "fbz"])
    _test_suggestions("parent_one faz ", 13, StringRange.between(11, 13), ["faz"])
    _test_suggestions("parent_one faz ", 14, StringRange.at(0), [])
    _test_suggestions("parent_one faz ", 15, StringRange.at(0), [])


func test_get_completion_suggestions_sub_commands_partial() -> void:
    subject.register(
        f.literal("parent") \
            .then(f.literal("foo")) \
            .then(f.literal("bar")) \
            .then(f.literal("baz")) \
    )

    var parse = subject.parse("parent b", source)
    var result = subject.get_completion_suggestions(parse)
    var suggestions = [
        Suggestion.new(StringRange.between(7, 8), "bar"),
        Suggestion.new(StringRange.between(7, 8), "baz")
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.between(7, 8)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_sub_commands_partial_with_input_offset() -> void:
    subject.register(
        f.literal("parent") \
            .then(f.literal("foo")) \
            .then(f.literal("bar")) \
            .then(f.literal("baz")) \
    )

    var parse = subject.parse_reader(_input_with_offset("junk parent b", 5), source)
    var result = subject.get_completion_suggestions(parse)
    var suggestions = [
        Suggestion.new(StringRange.between(12, 13), "bar"),
        Suggestion.new(StringRange.between(12, 13), "baz"),
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.between(12, 13)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_redirect() -> void:
    var actual = subject.register(f.literal("actual").then(f.literal("sub")))
    subject.register(f.literal("redirect").redirect(actual))

    var parse = subject.parse("redirect ", source)
    var result = subject.get_completion_suggestions(parse)
    var suggestions = [
        Suggestion.new(StringRange.at(9), "sub"),
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.at(9)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_redirect_partial() -> void:
    var actual = subject.register(f.literal("actual").then(f.literal("sub")))
    subject.register(f.literal("redirect").redirect(actual))

    var parse = subject.parse("redirect s", source)
    var result = subject.get_completion_suggestions(parse)
    var suggestions = [
        Suggestion.new(StringRange.between(9, 10), "sub"),
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.between(9, 10)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_moving_cursor_redirect() -> void:
    var actual_one = subject.register(
        f.literal("actual_one") \
            .then(f.literal("faz")) \
            .then(f.literal("fbz")) \
            .then(f.literal("gaz")) \
    )

    subject.register(f.literal("actual_two"))
    subject.register(f.literal("redirect_one").redirect(actual_one))
    subject.register(f.literal("redirect_two").redirect(actual_one))

    _test_suggestions("redirect_one faz ", 0, StringRange.at(0), ["actual_one", "actual_two", "redirect_one", "redirect_two"])
    _test_suggestions("redirect_one faz ", 9, StringRange.between(0, 9), ["redirect_one", "redirect_two"])
    _test_suggestions("redirect_one faz ", 10, StringRange.between(0, 10), ["redirect_one"])
    _test_suggestions("redirect_one faz ", 12, StringRange.at(0), [])
    _test_suggestions("redirect_one faz ", 13, StringRange.at(13), ["faz", "fbz", "gaz"])
    _test_suggestions("redirect_one faz ", 14, StringRange.between(13, 14), ["faz", "fbz"])
    _test_suggestions("redirect_one faz ", 15, StringRange.between(13, 15), ["faz"])
    _test_suggestions("redirect_one faz ", 16, StringRange.at(0), [])
    _test_suggestions("redirect_one faz ", 17, StringRange.at(0), [])


func test_get_completion_suggestions_redirect_partial_with_input_offset() -> void:
    var actual = subject.register(f.literal("actual").then(f.literal("sub")))
    subject.register(f.literal("redirect").redirect(actual))

    var parse = subject.parse_reader(_input_with_offset("/redirect s", 1), source)
    var result = subject.get_completion_suggestions(parse)
    var suggestions = [
        Suggestion.new(StringRange.between(10, 11), "sub")
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.between(10, 11)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_redirect_lots() -> void:
    var loop = subject.register(f.literal("redirect"))
    subject.register(
        f.literal("redirect") \
            .then(
                f.literal("loop") \
                    .then(
                        f.argument("loop", f.int()) \
                            .redirect(loop)
                    )
            )
    )

    var result = subject.get_completion_suggestions(subject.parse("redirect loop 1 loop 02 loop 003 ", source))
    var suggestions = [
        Suggestion.new(StringRange.at(33), "loop")
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.at(33)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func test_get_completion_suggestions_execute_simulation() -> void:
    var execute = subject.register(f.literal("execute"))
    subject.register(
        f.literal("execute") \
            .then(
                f.literal("as") \
                    .then(
                        f.argument("name", f.word()) \
                            .redirect(execute)
                    )
            ) \
            .then(
                f.literal("store") \
                    .then(
                        f.argument("name", f.word()) \
                            .redirect(execute)
                    )
            ) \
            .then(
                f.literal("run") \
                    .executes(command)
            )
    )
    
    var parse = subject.parse("execute as Dinnerbone as", source)
    var result = subject.get_completion_suggestions(parse)
    asserts.is_true(result.is_empty())


func test_get_completion_suggestions_execute_simulation_partial() -> void:
    var execute = subject.register(f.literal("execute"))
    subject.register(
        f.literal("execute") \
            .then(
                f.literal("as") \
                    .then(f.literal("bar").redirect(execute)) \
                    .then(f.literal("baz").redirect(execute)) \
            ) \
            .then(
                f.literal("store") \
                    .then(
                        f.argument("name", f.word()) \
                            .redirect(execute)
                    )
            ) \
            .then(
                f.literal("run") \
                    .executes(command)
            )
    )
    
    var parse = subject.parse("execute as bar as ", source)
    var result = subject.get_completion_suggestions(parse)
    var suggestions = [
        Suggestion.new(StringRange.at(18), "bar"),
        Suggestion.new(StringRange.at(18), "baz"),
    ]

    asserts.is_equal(str(result.ranges), str(StringRange.at(18)))
    asserts.is_equal(str(result.suggestions), str(suggestions))


func _test_suggestions(contents: String, cursor: int, ranges: StringRange, suggestions: Array) -> void:
    var result = subject.get_completion_suggestions(subject.parse(contents, source), cursor)
    asserts.is_equal(str(result.ranges), str(ranges))

    var expected = []
    for suggestion in suggestions:
        expected.append(Suggestion.new(ranges, suggestion))

    asserts.is_equal(str(result.suggestions), str(expected))


func _input_with_offset(input: String, offset: int) -> StringReader:
    var result = StringReader.new(input)
    result.cursor = offset
    return result
