extends Reference

const CommandContextBuilder = preload('./context/command_context_builder.gd')
const StringReader = preload('./string_reader.gd')

var context: CommandContextBuilder setget , _get_context
var reader: StringReader setget , _get_reader
var errors: Dictionary setget , _get_errors


func _init(_context: CommandContextBuilder, _reader = '', _errors: Dictionary = {}) -> void:
    context = _context
    errors = _errors
    reader = StringReader.new(_reader)


func _get_context() -> CommandContextBuilder:
    return context


func _get_reader() -> StringReader:
    return reader


func _get_errors() -> Dictionary:
    return errors


func _to_string():
    return 'ParseResult[context=%s, reader=%s, errors=%s]' % [context, reader, errors]
