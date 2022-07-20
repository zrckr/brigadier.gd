extends './argument_type.gd'

const ERR_FLOAT_TOO_SMALL := 'float must not be less than %f, found %s'
const ERR_FLOAT_TOO_BIG := 'float must not be more than %f, found %s'

var _minimum: float
var _maximum: float


func _init(minimum = -INF, maximum = INF) -> void:
    _minimum = minimum
    _maximum = maximum
    

func parse(reader: StringReader) -> Result:
    var start = reader.cursor
    var result = reader.read_float()
    if result.error:
        return result

    if result.value < _minimum:
        reader.cursor = start
        return Result.error(
            StringReader.Error.new(reader, ERR_FLOAT_TOO_SMALL % [_minimum, result.value]))
        
    if result.value > _maximum:
        reader.cursor = start
        return Result.error(
            StringReader.Error.new(reader, ERR_FLOAT_TOO_BIG % [_maximum, result.value]))

    return result


func get_examples() -> Array:
    return ["0", "1.2", "-1", "-1234.56"]


func _to_string() -> String:
    if _minimum == -INF && _maximum == INF:
        return "float()"
    elif _maximum == INF:
        return "float(%.f)" % _minimum
    else:
        return "float(%.f, %.f)" % [_minimum, _maximum]
