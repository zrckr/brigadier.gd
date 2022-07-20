extends './argument_type.gd'


func parse(reader: StringReader) -> Result:
    return reader.read_bool()


func get_examples() -> Array:
    return ['true', 'false']


func _to_string() -> String:
    return 'bool()'
