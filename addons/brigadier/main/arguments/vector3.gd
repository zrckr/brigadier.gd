extends './vector.gd'

const Coordinate3 = preload('./coordinates/coordinate3.gd')


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
    
    if not reader.can_read() or reader.peek() != ord(' '):
        reader.cursor = start
        return Result.error(
            StringReader.Error.new(reader, ERR_EXPECTED_N_COMPONENTS % 3))
            
    reader.skip()
    var z = _read_coordinate(reader)
    if z.error:
        return z
    
    return Result.ok(
        Coordinate3.new(x.value, y.value, z.value))


func get_examples() -> Array:
    return ["0 0 0", "^1 ^2 ^-3", "0.1 -0.2 0.3", "~0.1 ~2 ~-3", "1 ^2 ~3", "~1 ^~3 3"]


func _to_string() -> String:
    return "vector3()"
