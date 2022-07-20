extends WAT.Test

const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('../functions.gd')


func test_parse() -> void:
    var reader = StringReader.new('15')
    var result = f.int().parse(reader)
    asserts.is_null(result.error)
    asserts.is_equal(result.value, 15)
    asserts.is_false(reader.can_read())


func test_parse_too_small() -> void:
    var reader = StringReader.new('-5')
    var result = f.int(0, 100).parse(reader)
    asserts.is_not_null(result.error)
    asserts.is_equal(result.error.cursor, 0)


func test_parse_too_big() -> void:
    var reader = StringReader.new('5')
    var result = f.int(-100, 0).parse(reader)
    asserts.is_not_null(result.error)
    asserts.is_equal(result.error.cursor, 0)


func test_to_string() -> void:
    asserts.string_contains(str(f.int()), 'int()')
    asserts.string_contains(str(f.int(-100)), 'int(-100)')
    asserts.string_contains(str(f.int(-100, 100)), 'int(-100, 100)')
