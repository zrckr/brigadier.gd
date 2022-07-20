#warning-ignore-all:shadowed_variable

extends Reference

const Result = preload('./result.gd')

class Error:
    extends './error.gd'

    const CONTEXT_AMOUNT := 10

    var string: String setget , _get_string
    var cursor: int setget , _get_cursor
    
    func _init(reader: Reference, message: String, code: int = FAILED).(message, code) -> void:
        self.string = reader.string
        self.cursor = reader.cursor
        
    func get_message() -> String:
        var text = message
        var context = _get_context()
        if not context.empty():
            text += ' at position {%d}: {%s}' % [cursor, context]
        
        return text
    
    func _get_context() -> String:
        var text = ''
        if not string or cursor < 0:
            return text
        
        var pos = min(len(string), cursor)
        if pos > CONTEXT_AMOUNT:
            text += '...'

        var start = max(0, pos - CONTEXT_AMOUNT)
        text += string.substr(start, pos - start)
        text += '<--[HERE]'
        return text

    func _get_string() -> String:
        return string

    func _get_cursor() -> int:
        return cursor


const ERR_READER_INVALID_FLOAT := "invalid float '%s'" 
const ERR_READER_INVALID_INT := "invalid int '%s'"
const ERR_READER_INVALID_BOOL := "invalid bool, expected true or false but found '%s'"
const ERR_READER_INVALID_ESCAPE := "invalid escape sequence '%s' in quoted string"

const ERR_READER_EXPECTED_START_OF_QUOTE := 'expected quote to start a string'
const ERR_READER_EXPECTED_END_OF_QUOTE := 'unclosed quoted string'
const ERR_READER_EXPECTED_INT := 'expected int'
const ERR_READER_EXPECTED_FLOAT := 'expected float'
const ERR_READER_EXPECTED_BOOL := 'expected bool'
const ERR_READER_EXPECTED_SYMBOL := "expected symbol '%s'"

const SYNTAX_ESCAPE = ord('\\')
const SYNTAX_DOUBLE_QUOTE = ord('"')
const SYNTAX_SINGLE_QUOTE = ord("'")

var string: String = ''
var cursor: int = 0

var read: String setget, _get_read
var remaining: String setget , _get_remaining
var remaining_length: int setget , _get_remaining_length


func _init(variant) -> void:
    if variant is get_script():
        string = variant.string
        cursor = variant.cursor
    elif variant is String:
        string = variant
    

func can_read(length: int = 1) -> bool:
    return cursor + length <= string.length()


func peek(offset: int = 0) -> int:
    return string.ord_at(cursor + offset)


func next() -> int:
    var result = string.ord_at(cursor)
    cursor += 1
    return result


func skip() -> void:
    cursor += 1
    
    
func read_int() -> Result:
    var start = cursor
    while can_read() and is_allowed_number(peek()):
        skip()
        
    var number = string.substr(start, cursor - start)
    if number.empty():
        return Result.error(
            Error.new(self, ERR_READER_EXPECTED_INT))
        
    if not number.is_valid_integer():
        cursor = start
        return Result.error(
            Error.new(self, ERR_READER_INVALID_INT % number))

    return Result.ok(number.to_int())


func read_float() -> Result:
    var start = cursor
    while can_read() and is_allowed_number(peek()):
        skip()
        
    var number = string.substr(start, cursor - start)
    if number.empty():
        return Result.error(
            Error.new(self, ERR_READER_EXPECTED_FLOAT))
        
    if not number.is_valid_float():
        cursor = start
        return Result.error(
            Error.new(self, ERR_READER_INVALID_FLOAT % number))

    return Result.ok(number.to_float())


func read_unquoted_string() -> Result:
    var start = cursor
    while can_read() and is_allowed_in_unquoted_string(peek()):
        skip()
        
    return Result.ok(string.substr(start, cursor - start))
    

func read_quoted_string() -> Result:
    if not can_read():
        return Result.ok('')
        
    var next = peek()
    if not is_quoted_string_start(next):
        return Result.error(
            Error.new(self, ERR_READER_EXPECTED_START_OF_QUOTE))

    skip()
    return read_string_until(next)
    
    
func read_string_until(terminator: int) -> Result:
    var text = ''
    var escaped = false
    
    while can_read():
        var c = next()
        if escaped:
            if c == terminator or c == SYNTAX_ESCAPE:
                text += char(c)
                escaped = false
            else:
                cursor -= 1
                return Result.error(
                    Error.new(self, ERR_READER_INVALID_ESCAPE % char(c))) 
        elif c == SYNTAX_ESCAPE:
            escaped = true
        elif c == terminator:
            return Result.ok(text)
        else:
            text += char(c)

    return Result.error(Error.new(
        self, ERR_READER_EXPECTED_END_OF_QUOTE))


func read_string() -> Result:
    if not can_read():
        return Result.ok('')
        
    var next = peek()
    if is_quoted_string_start(next):
        skip()
        return read_string_until(next)
    
    return read_unquoted_string()


func read_bool() -> Result:
    var start = cursor
    var result = read_string()
    
    if result.error:
        return Result.error(
            Error.new(self, ERR_READER_EXPECTED_BOOL))
    
    if result.value == 'true':
        return Result.ok(true)
    elif result.value == 'false':
        return Result.ok(false)
    else:
        cursor = start
        return Result.error(
            Error.new(self, ERR_READER_INVALID_BOOL % result.value))


func expect(chr) -> Result:
    if chr is String:
        chr = ord(chr)
    
    if not can_read() or peek() != chr:
        return Result.error(
            Error.new(self, ERR_READER_EXPECTED_SYMBOL % char(chr)))

    skip()
    return Result.empty()


func clear_whitespaces() -> void:
    string = string.strip_edges()


func _get_read() -> String:
    return string.substr(0, cursor)


func _get_remaining_length() -> int:
    return string.length() - cursor


func _get_remaining() -> String:
    return string.substr(cursor)


func _to_string() -> String:
    return 'StringReader{string=%s, cursor=%d}' % [string, cursor]


static func is_allowed_number(chr: int) -> bool:
    return (
        chr >= ord('0') and chr <= ord('9')
        or chr == ord('.') or chr == ord('-')
    )
    

static func is_quoted_string_start(chr: int) -> bool:
    return chr == SYNTAX_DOUBLE_QUOTE or chr == SYNTAX_SINGLE_QUOTE


static func is_allowed_in_unquoted_string(chr: int) -> bool:
    return (
        chr >= ord('0') and chr <= ord('9')
        or chr >= ord('A') and chr <= ord('Z')
        or chr >= ord('a') and chr <= ord('z')
        or chr == ord('_') or chr == ord('-')
        or chr == ord('.') or chr == ord('+')
    )
