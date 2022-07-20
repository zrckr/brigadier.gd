extends WAT.Test

const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('../functions.gd')


func test_parse_word() -> void:
    var reader = StringReader.new('hello')
    var result = f.word().parse(reader)
    asserts.is_null(result.error)
    asserts.is_equal(result.value, 'hello')


func test_parse_string() -> void:
    var reader = StringReader.new('"hello world"')
    var result = f.string().parse(reader)
    asserts.is_null(result.error)
    asserts.is_equal(result.value, 'hello world')


func test_parse_greedy_string() -> void:
    var reader = StringReader.new('Hello world! This is a test.')
    var result = f.greedy_string().parse(reader)
    asserts.is_null(result.error)
    asserts.is_equal(result.value, 'Hello world! This is a test.')


func test_to_string() -> void:
    asserts.string_contains(str(f.string()), 'string()')
