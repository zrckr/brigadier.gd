extends WAT.Test

const SuggestionsBuilder = preload('res://addons/brigadier/main/suggestion/suggestions_builder.gd')
const Suggestion = preload('res://addons/brigadier/main/suggestion/suggestion.gd')
const StringRange = preload('res://addons/brigadier/main/context/string_range.gd')

var builder: SuggestionsBuilder


func pre() -> void:
    var string = 'Hello w'
    builder = SuggestionsBuilder.new(string, string.to_lower(), 6)


func test_suggest_appends() -> void:
    var result = builder \
        .suggest('world!') \
        .build()
    
    var suggestions = [Suggestion.new(StringRange.between(6, 7), 'world!')]

    asserts.is_equal(str(result.suggestions), str(suggestions))
    asserts.is_equal(str(result.ranges), str(StringRange.between(6, 7)))
    asserts.is_false(result.is_empty())


func test_suggest_replaces() -> void:
    var result = builder \
        .suggest('everybody') \
        .build()
    
    var suggestions = [Suggestion.new(StringRange.between(6, 7), 'everybody')]

    asserts.is_equal(str(result.suggestions), str(suggestions))
    asserts.is_equal(str(result.ranges), str(StringRange.between(6, 7)))
    asserts.is_false(result.is_empty())


func test_suggest_noop() -> void:
    var result = builder \
        .suggest('w') \
        .build()
    
    asserts.is_true(result.suggestions.empty())
    asserts.is_true(result.is_empty())


func test_suggest_multiple() -> void:
    var result = builder \
        .suggest('world!') \
        .suggest('everybody') \
        .suggest('weekend') \
        .build()

    var suggestions = [
        Suggestion.new(StringRange.between(6, 7), 'everybody'),
        Suggestion.new(StringRange.between(6, 7), 'weekend'),
        Suggestion.new(StringRange.between(6, 7), 'world!'),
    ]

    asserts.is_equal(str(result.suggestions), str(suggestions))
    asserts.is_equal(str(result.ranges), str(StringRange.between(6, 7)))
    asserts.is_false(result.is_empty())


func test_restart() -> void:
    builder.suggest("won't be included in restart");
    var other = builder.restart();
    
    asserts.is_not_equal(other, builder)
    asserts.is_equal(other.input, builder.input)
    asserts.is_equal(other.start, builder.start)
    asserts.is_equal(other.remaining, builder.remaining)


func test_sort_alphabetical() -> void:
    var result = builder \
        .suggest('2') \
        .suggest('4') \
        .suggest('6') \
        .suggest('8') \
        .suggest('30') \
        .suggest('32') \
        .build()

    var actual = []
    for suggestion in result.suggestions:
        actual.append(suggestion.text)

    asserts.is_equal(actual, ['2', '4', '6', '8', '30', '32'])


func test_sort_numerical() -> void:
    var result = builder \
        .suggest(2) \
        .suggest(4) \
        .suggest(6) \
        .suggest(8) \
        .suggest(30) \
        .suggest(32) \
        .build()

    var actual = []
    for suggestion in result.suggestions:
        actual.append(suggestion.text)

    asserts.is_equal(actual, ['2', '4', '6', '8', '30', '32'])


func test_sort_mixed() -> void:
    var result = builder \
        .suggest("11") \
        .suggest("22") \
        .suggest("33") \
        .suggest("a") \
        .suggest("b") \
        .suggest("c") \
        .suggest(2) \
        .suggest(4) \
        .suggest(6) \
        .suggest(8) \
        .suggest(30) \
        .suggest(32) \
        .suggest("3a") \
        .suggest("a3") \
        .build()

    var actual = []
    for suggestion in result.suggestions:
        actual.append(suggestion.text)

    asserts.is_equal(actual, ["2", "3a", "4", "6", "8", "11", "22", "30", "32", "33", "a", "a3", "b", "c"])
