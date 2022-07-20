extends './vector.gd'

const Coordinate2 = preload('./coordinates/coordinate2.gd')


func parse(reader: StringReader) -> Result:
    var start = reader.cursor
    var x = _read_coordinate(reader)
    if x.error:
        return x
    
    if not reader.can_read() or reader.peek() != ord(' '):
        reader.cursor = start
        return Result.error(
            StringReader.Error.new(reader, ERR_EXPECTED_N_COMPONENTS % 3))
            
    reader.skip()
    var y = _read_coordinate(reader)
    if y.error:
        return y
    
    return Result.ok(
        Coordinate2.new(x.value, y.value))


func get_examples() -> Array:
    return ["0 0", "^1 ^-2", "0.1 -0.2", "~0.1 ~-2", "^1 ~2", "~1 ^~2"]

func _to_string() -> String:
    return "vector2()"
