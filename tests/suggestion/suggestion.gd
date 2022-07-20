extends WAT.Test

const Suggestion = preload('res://addons/brigadier/main/suggestion/suggestion.gd')
const StringRange = preload('res://addons/brigadier/main/context/string_range.gd')


func test_apply_insertation_start() -> void:
    var suggestion = Suggestion.new(StringRange.at(0), 'And so I said: ')
    asserts.is_equal(suggestion.apply('Hello world!'), 'And so I said: Hello world!')


func test_apply_insertation_middle() -> void:
    var suggestion = Suggestion.new(StringRange.at(6), 'small ')
    asserts.is_equal(suggestion.apply('Hello world!'), 'Hello small world!')


func test_apply_insertation_end() -> void:
    var suggestion = Suggestion.new(StringRange.at(5), ' world!')
    asserts.is_equal(suggestion.apply('Hello'), 'Hello world!')


func test_apply_replacement_start() -> void:
    var suggestion = Suggestion.new(StringRange.between(0, 5), 'Goodbye')
    asserts.is_equal(suggestion.apply('Hello world!'), 'Goodbye world!')


func test_apply_replacement_middle() -> void:
    var suggestion = Suggestion.new(StringRange.between(6, 11), 'Alex')
    asserts.is_equal(suggestion.apply('Hello world!'), 'Hello Alex!')


func test_apply_replacement_end() -> void:
    var suggestion = Suggestion.new(StringRange.between(6, 12), 'Creeper!')
    asserts.is_equal(suggestion.apply('Hello world!'), 'Hello Creeper!')


func test_apply_replacement_everything() -> void:
    var suggestion = Suggestion.new(StringRange.between(0, 12), 'Oh dear.')
    asserts.is_equal(suggestion.apply('Hello world!'), 'Oh dear.')


func test_expand_unchanged() -> void:
    var suggestion = Suggestion.new(StringRange.at(1), 'oo')
    asserts.is_equal(suggestion.expand('f', StringRange.at(1)), suggestion)


func test_expand_left() -> void:
    var s = Suggestion.new(StringRange.at(1), 'oo')
    var a = s.expand('f', StringRange.between(0, 1))
    var b = Suggestion.new(StringRange.between(0, 1), 'foo')
    asserts.is_equal(str(a), str(b))


func test_expand_right() -> void:
    var s = Suggestion.new(StringRange.at(0), 'minecraft:')
    var a = s.expand('fish', StringRange.between(0, 4))
    var b = Suggestion.new(StringRange.between(0, 4), 'minecraft:fish')
    asserts.is_equal(str(a), str(b))


func test_expand_both() -> void:
    var s = Suggestion.new(StringRange.at(11), 'minecraft:')
    var a = s.expand('give Steve fish_block', StringRange.between(5, 21))
    var b = Suggestion.new(StringRange.between(5, 21), 'Steve minecraft:fish_block')
    asserts.is_equal(str(a), str(b))


func test_expand_replacement() -> void:
    var s = Suggestion.new(StringRange.between(6, 11), 'strangers')
    var b = s.expand('Hello world!', StringRange.between(0, 12))
    var a = Suggestion.new(StringRange.between(0, 12), 'Hello strangers!')
    asserts.is_equal(str(a), str(b))
