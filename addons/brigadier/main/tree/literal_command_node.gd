extends './command_node.gd'

const ERR_EXPECTED_LITERAL := "expected literal '%s'"

var literal: String
var literal_lower: String


func _init(_literal: String).() -> void:
    literal = _literal
    literal_lower = _literal.to_lower()


func is_valid_input(input: String) -> bool:
    return _parse(StringReader.new(input)) > -1


func get_name() -> String:
    return literal


func get_usage_text() -> String:
    return literal


func parse(reader: StringReader, context_builder: CommandContextBuilder) -> Result:
    var start = reader.cursor
    var end = _parse(reader)
    
    if end > -1:
        context_builder.with_node(self, StringRange.between(start, end))
        return Result.empty()

    return Result.error(
        StringReader.Error.new(reader, ERR_EXPECTED_LITERAL % literal))


func list_suggestions(_context: CommandContext, builder: SuggestionsBuilder) -> Suggestions:
    if literal_lower.begins_with(builder.remaining_lower):
        return builder.suggest(literal).build()
    else:
        return Suggestions.empty()


func create_builder() -> Reference:
    var script = load('res://addons/brigadier/main/builder/literal_argument_builder.gd')
    var builder = script.new(literal)
    
    builder.requires(requirement)
    builder.forward(redirect, redirect_modifier, forked)
    
    if command != null:
        builder.executes(command)
    
    return builder


func get_sorted_key() -> String:
    return literal


func get_examples() -> Array:
    return [literal]


func _parse(reader: StringReader) -> int:
    var start = reader.cursor
    var length = len(literal)
    
    if reader.can_read(length):
        var end = start + length
        
        if reader.string.substr(start, end - start) == literal:
            reader.cursor = end
            if not reader.can_read() or reader.peek() == ord(' '):
                return end
            else:
                reader.cursor = start
    
    return -1


func _to_string():
    return '<literal %s>' % literal
