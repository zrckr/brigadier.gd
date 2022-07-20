extends './argument_type.gd'

const ERR_INT_TOO_SMALL := 'int must not be less than %d, found %s'
const ERR_INT_TOO_BIG := 'int must not be more than %d, found %s'

const INT_MAX := 2147483647
const INT_MIN := -2147483648

var _minimum: int
var _maximum: int
    

func _init(minimum = INT_MIN, maximum = INT_MAX) -> void:
    _minimum = minimum
    _maximum = maximum
    

func parse(reader: StringReader) -> Result:
    var start = reader.cursor
    var result = reader.read_int()
    if result.error:
        return result
    
    if result.value < _minimum:
        reader.cursor = start
        return Result.error(
            StringReader.Error.new(reader, ERR_INT_TOO_SMALL % [_minimum, result.value]))
        
    if result.value > _maximum:
        reader.cursor = start
        return Result.error(
            StringReader.Error.new(reader, ERR_INT_TOO_BIG % [_maximum, result.value]))

    return result


func get_examples() -> Array:
    return ["0", "123", "-123"]


func _to_string() -> String:
    if _minimum == INT_MIN && _maximum == INT_MAX:
        return "int()"
    elif _maximum == INT_MAX:
        return "int(%d)" % _minimum
    else:
        return "int(%d, %d)" % [_minimum, _maximum]
