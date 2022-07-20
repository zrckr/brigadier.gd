extends WAT.Test

const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('../functions.gd')


func test_parse_vector2i() -> void:
    var reader = StringReader.new('1 2')
    var result = f.vector2().parse(reader)
    
    asserts.is_null(result.error)
    result = result.value
    
    asserts.is_equal_approx_(result.x.value, 1.0)
    asserts.is_equal_approx_(result.y.value, 2.0)


func test_parse_vector2() -> void:
    var reader = StringReader.new('1.2 -2.3')
    var result = f.vector2().parse(reader)
    
    asserts.is_null(result.error)
    result = result.value
    
    asserts.is_equal_approx_(result.x.value, 1.2)
    asserts.is_equal_approx_(result.y.value, -2.3)


func test_relative() -> void:
    var reader = StringReader.new('~1 ~2')
    var result = f.vector2().parse(reader)
    
    asserts.is_null(result.error)
    result = result.value
    
    asserts.is_equal_approx_(result.x.value, 1.0)
    asserts.is_true(result.x.relative)

    asserts.is_equal_approx_(result.y.value, 2.0)
    asserts.is_true(result.y.relative)


func test_global() -> void:
    var reader = StringReader.new('^1 ^2')
    var result = f.vector2().parse(reader)
    
    asserts.is_null(result.error)
    result = result.value
    
    asserts.is_equal_approx_(result.x.value, 1.0)
    asserts.is_true(result.x.global)

    asserts.is_equal_approx_(result.y.value, 2.0)
    asserts.is_true(result.y.global)


func test_wrong_mixed() -> void:
    var reader = StringReader.new('~^1 2')
    var result = f.vector2().parse(reader)
    asserts.is_not_null(result.error)

    reader = StringReader.new('1 ^^2')
    result = f.vector2().parse(reader)
    asserts.is_not_null(result.error)

    reader = StringReader.new('~~1 2')
    result = f.vector2().parse(reader)
    asserts.is_not_null(result.error)


func test_correct_mixed() -> void:
    var reader = StringReader.new('^~1 2')
    var result = f.vector2().parse(reader)
    
    asserts.is_null(result.error)
    result = result.value
    
    asserts.is_equal_approx_(result.x.value, 1.0)
    asserts.is_true(result.x.global)
    asserts.is_true(result.x.relative)

    asserts.is_equal_approx_(result.y.value, 2.0)
    asserts.is_false(result.y.global)
    asserts.is_false(result.y.relative)
