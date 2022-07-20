extends WAT.Test

const SuggestionsBuilder = preload('res://addons/brigadier/main/suggestion/suggestions_builder.gd')
const Suggestion = preload('res://addons/brigadier/main/suggestion/suggestion.gd')
const Suggestions = preload('res://addons/brigadier/main/suggestion/suggestions.gd')
const StringRange = preload('res://addons/brigadier/main/context/string_range.gd')


func test_merge_empty() -> void:
    var merged = Suggestions.merge('foo b', [])
    asserts.is_true(merged.is_empty(), 'No suggestions merged')


func test_merge_single() -> void:
    var singleton = [Suggestion.new(StringRange.at(5), 'ar')]
    var suggestions = Suggestions.new(StringRange.at(5), singleton)
    var merged = Suggestions.merge('foo b', [suggestions])
    asserts.is_equal(str(merged), str(suggestions))


func test_merge_multiple() -> void:
    var a = Suggestions.new(StringRange.at(5), [
        Suggestion.new(StringRange.at(5), "ar"), 
        Suggestion.new(StringRange.at(5), "az"), 
        Suggestion.new(StringRange.at(5), "Az"),
    ])
    
    var b = Suggestions.new(StringRange.between(4, 5), [
        Suggestion.new(StringRange.between(4, 5), "foo"),
        Suggestion.new(StringRange.between(4, 5), "qux"),
        Suggestion.new(StringRange.between(4, 5), "apple"),
        Suggestion.new(StringRange.between(4, 5), "Bar"),
    ])

    var suggestions = [
        Suggestion.new(StringRange.between(4, 5), "apple"),
        Suggestion.new(StringRange.between(4, 5), "bar"),
        Suggestion.new(StringRange.between(4, 5), "Bar"),
        Suggestion.new(StringRange.between(4, 5), "baz"),
        Suggestion.new(StringRange.between(4, 5), "bAz"),
        Suggestion.new(StringRange.between(4, 5), "foo"),
        Suggestion.new(StringRange.between(4, 5), "qux"),
    ]
    
    var merged = Suggestions.merge("foo b", [a, b])
    asserts.is_equal(str(merged.suggestions), str(suggestions))
