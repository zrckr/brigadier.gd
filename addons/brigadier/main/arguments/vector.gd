extends './argument_type.gd'

const Coordinate = preload('./coordinates/coordinate.gd')

const ERR_EXPECTED_FLOAT := 'expected float coordinate'
const ERR_EXPECTED_N_COMPONENTS := 'incomplete coordinate (expected %d components)'
const ERR_WRONG_SEQUENCE := "first specify component is global '^', then is relative '~'"

const INVALID_SEQUENCES := [
    [ord('^'), ord('^')],
    [ord('~'), ord('~')],
    [ord('~'), ord('^')],
]


func _read_coordinate(reader: StringReader) -> Result:
    if reader.can_read() and _check_invalid_sequences(reader):
        return Result.error(
            StringReader.Error.new(reader, ERR_WRONG_SEQUENCE))
    
    var global = _read_global(reader)    
    var relative = _read_relative(reader) 
    
    if not reader.can_read():
        return Result.error(
            StringReader.Error.new(reader, ERR_EXPECTED_FLOAT))
            
    var value = 0.0
    if reader.can_read() and reader.peek() != ord(' '):
        var result = reader.read_float()
        if result.error:
            return result
            
        value = result.value as float
        
    return Result.ok(
        Coordinate.new(value, global, relative))
        
        
func _check_invalid_sequences(reader: StringReader) -> bool:
    for sequence in INVALID_SEQUENCES:
        if reader.peek(0) == sequence[0] and reader.peek(1) == sequence[1]:
            return true
    return false
        

func _read_global(reader: StringReader) -> bool:
    if reader.peek() == ord('^'):
        reader.skip()
        return true
    return false
    
    
func _read_relative(reader: StringReader) -> bool:
    if reader.peek() == ord('~'):
        reader.skip()
        return true
    return false
