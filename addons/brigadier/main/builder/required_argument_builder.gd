extends './argument_builder.gd'

const ArgumentType = preload('../arguments/argument_type.gd')
const SuggestionProvider = preload('../functions/suggestion_provider.gd')

var name: String
var type: ArgumentType
var provider: SuggestionProvider


func _init(_name: String, _type: ArgumentType).() -> void:
    name = _name
    type = _type


func get_self() -> Reference:
    return self


func build() -> CommandNode:
    var script = load('res://addons/brigadier/main/tree/argument_command_node.gd')
    var result = script.new(name, type, provider)
    
    result.command = command
    result.requirement = requirement
    result.redirect_modifier = redirect_modifier
    result.redirect = redirect
    result.forked = forked

    for argument in root_node.get_children():
        result.add_child(argument)
    
    return result


func suggests(value: SuggestionProvider):
    provider = value
    return get_self()
