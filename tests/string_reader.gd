extends WAT.Test

const StringReader = preload('res://addons/brigadier/main/string_reader.gd')


func test_can_read() -> void:
    var reader = StringReader.new('abc')
    asserts.is_true(reader.can_read())
    reader.skip()   # 'a'
    asserts.is_true(reader.can_read())
    reader.skip()   # 'b'
    asserts.is_true(reader.can_read())
    reader.skip()   # 'c'
    asserts.is_false(reader.can_read())


func test_get_remaining_length() -> void:
    var reader = StringReader.new('abc')
    asserts.is_equal(reader.remaining_length, 3)
    reader.cursor = 1
    asserts.is_equal(reader.remaining_length, 2)
    reader.cursor = 2
    asserts.is_equal(reader.remaining_length, 1)
    reader.cursor = 3
    asserts.is_equal(reader.remaining_length, 0)


func test_can_read_length() -> void:
    var reader = StringReader.new('abc')
    asserts.is_true(reader.can_read(1))
    asserts.is_true(reader.can_read(2))
    asserts.is_true(reader.can_read(3))
    asserts.is_false(reader.can_read(4))
    asserts.is_false(reader.can_read(5))


func test_peek() -> void:
    var reader = StringReader.new('abc')
    asserts.is_equal(reader.peek(), ord('a'))
    asserts.is_equal(reader.cursor, 0)
    reader.cursor = 2
    asserts.is_equal(reader.peek(), ord('c'))
    asserts.is_equal(reader.cursor, 2)


func test_peek_length() -> void:
    var reader = StringReader.new('abc')
    asserts.is_equal(reader.peek(0), ord('a'))
    asserts.is_equal(reader.peek(2), ord('c'))
    asserts.is_equal(reader.cursor, 0)
    reader.cursor = 1
    asserts.is_equal(reader.peek(1), ord('c'))
    asserts.is_equal(reader.cursor, 1)


func test_next() -> void:
    var reader = StringReader.new('abc')
    asserts.is_equal(reader.next(), ord('a'))
    asserts.is_equal(reader.next(), ord('b'))
    asserts.is_equal(reader.next(), ord('c'))
    asserts.is_equal(reader.cursor, 3)


func test_skip() -> void:
    var reader = StringReader.new('abc')
    reader.skip()
    asserts.is_equal(reader.cursor, 1)


func test_get_remaining() -> void:
    var reader = StringReader.new('Hello!')
    asserts.is_equal(reader.remaining, 'Hello!')
    reader.cursor = 3
    asserts.is_equal(reader.remaining, 'lo!')
    reader.cursor = 6
    asserts.is_equal(reader.remaining, '')


func test_get_read() -> void:
    var reader = StringReader.new('Hello!')
    asserts.is_equal(reader.read, '')
    reader.cursor = 3
    asserts.is_equal(reader.read, 'Hel')
    reader.cursor = 6
    asserts.is_equal(reader.read, 'Hello!')


func test_clear_whitespaces_none() -> void:
    var reader = StringReader.new('Hello!')
    reader.clear_whitespaces()
    asserts.is_equal(reader.string, 'Hello!')


func test_clear_whitespaces_mixed() -> void:
    var reader = StringReader.new(' \t \t\nHello!')
    reader.clear_whitespaces()
    asserts.is_equal(reader.string, 'Hello!')


func test_clear_whitespaces_empty() -> void:
    var reader = StringReader.new('')
    reader.clear_whitespaces()
    asserts.is_equal(reader.string, '')


func test_read_unquoted_string() -> void:
    var reader = StringReader.new('hello world')
    asserts.is_equal(reader.read_unquoted_string().value, 'hello')
    asserts.is_equal(reader.read, 'hello')
    asserts.is_equal(reader.remaining, ' world')


func test_read_unquoted_string_empty() -> void:
    var reader = StringReader.new('')
    asserts.is_equal(reader.read_unquoted_string().value, '')
    asserts.is_equal(reader.read, '')
    asserts.is_equal(reader.remaining, '')


func test_read_unquoted_string_empty_with_remaining() -> void:
    var reader = StringReader.new(' hello world')
    asserts.is_equal(reader.read_unquoted_string().value, '')
    asserts.is_equal(reader.read, '')
    asserts.is_equal(reader.remaining, ' hello world')


func test_read_quoted_string() -> void:
    var reader = StringReader.new('\"hello world\"')
    asserts.is_equal(reader.read_quoted_string().value, 'hello world')
    asserts.is_equal(reader.read, '\"hello world\"')
    asserts.is_equal(reader.remaining, '')


func test_read_single_quoted_string() -> void:
    var reader = StringReader.new('\'hello world\'')
    asserts.is_equal(reader.read_quoted_string().value, 'hello world')
    asserts.is_equal(reader.read, '\'hello world\'')
    asserts.is_equal(reader.remaining, '')


func test_read_mixed_quoted_string_double_inside_single() -> void:
    var reader = StringReader.new("'hello \"world\"'")
    asserts.is_equal(reader.read_quoted_string().value, "hello \"world\"")
    asserts.is_equal(reader.read, "'hello \"world\"'")
    asserts.is_equal(reader.remaining, '')


func test_read_mixed_quoted_string_single_inside_double() -> void:
    var reader = StringReader.new("\"hello 'world'\"")
    asserts.is_equal(reader.read_quoted_string().value, "hello 'world'")
    asserts.is_equal(reader.read, "\"hello 'world'\"")
    asserts.is_equal(reader.remaining, '')


func test_read_quoted_string_empty() -> void:
    var reader = StringReader.new('')
    asserts.is_equal(reader.read_quoted_string().value, '')
    asserts.is_equal(reader.read, '')
    asserts.is_equal(reader.remaining, '')


func test_read_quoted_string_empty_quoted() -> void:
    var reader = StringReader.new("\"\"")
    asserts.is_equal(reader.read_quoted_string().value, '')
    asserts.is_equal(reader.read, "\"\"")
    asserts.is_equal(reader.remaining, '')


func test_read_quoted_string_empty_quoted_with_remaining() -> void:
    var reader = StringReader.new("\"\" hello world")
    asserts.is_equal(reader.read_quoted_string().value, '')
    asserts.is_equal(reader.read, "\"\"")
    asserts.is_equal(reader.remaining, " hello world")


func test_read_quoted_string_with_escaped_quote() -> void:
    var reader = StringReader.new("\"hello \\\"world\\\"\"")
    asserts.is_equal(reader.read_quoted_string().value, "hello \"world\"")
    asserts.is_equal(reader.read, "\"hello \\\"world\\\"\"")
    asserts.is_equal(reader.remaining, '')


func test_read_quoted_string_with_escaped_escapes() -> void:
    var reader = StringReader.new("\"\\\\o/\"")
    asserts.is_equal(reader.read_quoted_string().value, "\\o/")
    asserts.is_equal(reader.read, "\"\\\\o/\"")
    asserts.is_equal(reader.remaining, '')


func test_read_quoted_string_with_remaining() -> void:
    var reader = StringReader.new("\"hello world\" foo bar")
    asserts.is_equal(reader.read_quoted_string().value, "hello world")
    asserts.is_equal(reader.read, "\"hello world\"")
    asserts.is_equal(reader.remaining, " foo bar")


func test_read_quoted_string_with_immediate_remaining() -> void:
    var reader = StringReader.new("\"hello world\"foo bar")
    asserts.is_equal(reader.read_quoted_string().value, "hello world")
    asserts.is_equal(reader.read, "\"hello world\"")
    asserts.is_equal(reader.remaining, "foo bar")


func test_read_quoted_string_no_open() -> void:
    var reader = StringReader.new("hello world\"")
    var result = reader.read_quoted_string()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_quoted_string_no_close() -> void:
    var reader = StringReader.new("\"hello world")
    var result = reader.read_quoted_string()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 12)


func test_read_quoted_string_invalid_escape() -> void:
    var reader = StringReader.new("\"hello\\nworld\"")
    var result = reader.read_quoted_string()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 7)


func test_read_quoted_string_invalid_quote_escape() -> void:
    var reader = StringReader.new("'hello\\\"\'world")
    var result = reader.read_quoted_string()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 7)


func test_read_string_no_quotes() -> void:
    var reader = StringReader.new('hello world')
    asserts.is_equal(reader.read_string().value, 'hello')
    asserts.is_equal(reader.read, 'hello')
    asserts.is_equal(reader.remaining, ' world')


func test_read_string_single_quotes() -> void:
    var reader = StringReader.new("'hello world'")
    asserts.is_equal(reader.read_string().value, "hello world")
    asserts.is_equal(reader.read, "'hello world'")
    asserts.is_equal(reader.remaining, '')


func test_read_string_double_quotes() -> void:
    var reader = StringReader.new("\"hello world\"")
    asserts.is_equal(reader.read_string().value, "hello world")
    asserts.is_equal(reader.read, "\"hello world\"")
    asserts.is_equal(reader.remaining, '')


func test_read_int() -> void:
    var reader = StringReader.new("1234567890")
    asserts.is_equal(reader.read_int().value, 1234567890)
    asserts.is_equal(reader.read, "1234567890")
    asserts.is_equal(reader.remaining, '')


func test_read_int_negative() -> void:
    var reader = StringReader.new("-1234567890")
    asserts.is_equal(reader.read_int().value, -1234567890)
    asserts.is_equal(reader.read, "-1234567890")
    asserts.is_equal(reader.remaining, '')


func test_read_int_invalid() -> void:
    var reader = StringReader.new('12.34')
    var result = reader.read_int()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_int_none() -> void:
    var reader = StringReader.new('')
    var result = reader.read_int()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_int_with_remaining() -> void:
    var reader = StringReader.new('1234567890 foo bar')
    asserts.is_equal(reader.read_int().value, 1234567890)
    asserts.is_equal(reader.read, "1234567890")
    asserts.is_equal(reader.remaining, ' foo bar')


func test_read_int_with_remaining_immediate() -> void:
    var reader = StringReader.new('1234567890foo bar')
    asserts.is_equal(reader.read_int().value, 1234567890)
    asserts.is_equal(reader.read, "1234567890")
    asserts.is_equal(reader.remaining, 'foo bar')


func test_read_float() -> void:
    var reader = StringReader.new('123')
    asserts.is_equal_approx_(reader.read_float().value, 123.0)
    asserts.is_equal(reader.read, "123")
    asserts.is_equal(reader.remaining, '')


func test_read_float_with_decimal() -> void:
    var reader = StringReader.new('12.34')
    asserts.is_equal_approx_(reader.read_float().value, 12.34)
    asserts.is_equal(reader.read, "12.34")
    asserts.is_equal(reader.remaining, '')


func test_read_float_negative() -> void:
    var reader = StringReader.new('-123')
    asserts.is_equal_approx_(reader.read_float().value, -123.0)
    asserts.is_equal(reader.read, "-123")
    asserts.is_equal(reader.remaining, '')


func test_read_float_invalid() -> void:
    var reader = StringReader.new('12.34.56')
    var result = reader.read_float()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_float_none() -> void:
    var reader = StringReader.new('')
    var result = reader.read_float()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_float_with_remaining() -> void:
    var reader = StringReader.new('12.34 foo bar')
    asserts.is_equal_approx_(reader.read_float().value, 12.34)
    asserts.is_equal(reader.read, "12.34")
    asserts.is_equal(reader.remaining, ' foo bar')


func test_read_float_with_remaining_immediate() -> void:
    var reader = StringReader.new('12.34foo bar')
    asserts.is_equal_approx_(reader.read_float().value, 12.34)
    asserts.is_equal(reader.read, "12.34")
    asserts.is_equal(reader.remaining, 'foo bar')


func test_expect_correct() -> void:
    var reader = StringReader.new('abc')
    reader.expect('a')
    asserts.is_equal(reader.cursor, 1)


func test_expect_incorrect() -> void:
    var reader = StringReader.new('bcd')
    var result = reader.expect('a')
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_expect_none() -> void:
    var reader = StringReader.new('')
    var result = reader.expect('a')
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_boolean_correct() -> void:
    var reader = StringReader.new('true')
    asserts.is_equal(reader.read_bool().value, true)
    asserts.is_equal(reader.read, 'true')


func test_read_boolean_incorrect() -> void:
    var reader = StringReader.new('tuesday')
    var result = reader.read_bool()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_read_boolean_non() -> void:
    var reader = StringReader.new('')
    var result = reader.read_bool()
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)
