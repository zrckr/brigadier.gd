extends './command_node.gd'

const ArgumentType = preload('../arguments/argument_type.gd')

const USAGE_ARGUMENT_OPEN := "<";
const USAGE_ARGUMENT_CLOSE := ">"

var name: String
var type: ArgumentType
var provider: SuggestionProvider


func _init(_name: String, _type: ArgumentType, _provider: SuggestionProvider).() -> void:
    name = _name
    type = _type
    provider = _provider


func is_valid_input(input: String) -> bool:
    var reader = StringReader.new(input)
    var result = type.parse(reader)
    
    if result.error:
        return false

    return not reader.can_read() or reader.peek() == ord(' ')


func get_name() -> String:
    return name


func get_usage_text() -> String:
    return '<' + name + '>'


func parse(reader: StringReader, context_builder: CommandContextBuilder) -> Result:
    var start = reader.cursor
    var result = type.parse(reader)
    
    if result.error:
        return result

    var parsed = {
        range = StringRange.new(start, reader.cursor),
        result = result
    }
    
    context_builder.with_argument(name, parsed)
    context_builder.with_node(self, parsed.range)
    return Result.empty()


func list_suggestions(context: CommandContext, builder: SuggestionsBuilder) -> Suggestions:
    if provider:
        return provider.get_suggestions(context, builder) as Suggestions
    else:
        return type.list_suggestions(context, builder)  


func create_builder() -> Reference:
    var script = load('res://addons/brigadier/main/builder/required_argument_builder.gd')
    var builder = script.new(name, type)
    
    builder.requires(requirement)
    builder.forward(redirect, redirect_modifier, forked)
    builder.suggests(provider)
    
    if command != null:
        builder.executes(command)

    return builder


func get_sorted_key() -> String:
    return name


func get_examples() -> Array:
    return type.examples()


func _to_string() -> String:
    return '<argument %s: %s>' % [name, type]
