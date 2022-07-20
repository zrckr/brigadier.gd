extends WAT.Test

const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('../functions.gd')


func test_parse_true() -> void:
    var reader = StringReader.new('true')
    var result = f.bool().parse(reader) 
    asserts.is_null(result.error)
    asserts.is_equal(result.value, true)


func test_parse_false() -> void:
    var reader = StringReader.new('false')
    var result = f.bool().parse(reader) 
    asserts.is_null(result.error)
    asserts.is_equal(result.value, false)
