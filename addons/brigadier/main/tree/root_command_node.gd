extends './command_node.gd'


func _init().() -> void:
    command = null
    requirement = null
    redirect_modifier = null
    redirect = null
    forked = false


func is_valid_input(_input: String) -> bool:
    return false
    
    
func get_name() -> String:
    return ''


func get_usage_text() -> String:
    return ''


func parse(_reader: StringReader, _context_builder: CommandContextBuilder) -> Result:
    return Result.empty()
    

func list_suggestions(_context: CommandContext, _builder: SuggestionsBuilder) -> Suggestions:
    return Suggestions.empty()


func create_builder() -> Reference:
    push_error('Cannot convert root into a builder')
    return null


func get_sorted_key() -> String:
    return ''


func get_examples() -> Array:
    return []


func _to_string():
    return '<root>'
