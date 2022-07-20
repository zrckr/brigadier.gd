extends WAT.Test

const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('../functions.gd')


func test_parse_int() -> void:
    var reader = StringReader.new('15')
    var result = f.float().parse(reader)
    
    asserts.is_null(result.error)
    asserts.is_equal_approx_(result.value, 15.0)
    asserts.is_false(reader.can_read())


func test_parse_float() -> void:
    var reader = StringReader.new('3.14')
    var result = f.float().parse(reader)
    
    asserts.is_null(result.error)
    asserts.is_equal_approx_(result.value, 3.14)
    asserts.is_false(reader.can_read())


func test_parse_too_small() -> void:
    var reader = StringReader.new('-5')
    var result = f.float(0.0, 100.0).parse(reader)
    
    asserts.is_not_null(result.error)
    asserts.is_equal(result.error.cursor, 0)


func test_parse_too_big() -> void:
    var reader = StringReader.new('5')
    var result = f.float(-100.0, 0.0).parse(reader)
    
    asserts.is_not_null(result.error)
    asserts.is_equal(result.error.cursor, 0)


func test_to_string() -> void:
    asserts.is_equal(str(f.float()), 'float()')
    asserts.is_equal(str(f.float(-100)), 'float(-100)')
    asserts.is_equal(str(f.float(-100, 100)), 'float(-100, 100)')
