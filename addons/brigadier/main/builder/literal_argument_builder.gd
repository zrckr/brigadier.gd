extends './argument_builder.gd'

var literal: String


func _init(_literal: String).() -> void:
    literal = _literal


func get_self() -> Reference:
    return self


func build() -> CommandNode:
    var script = load('res://addons/brigadier/main/tree/literal_command_node.gd')
    var result = script.new(literal)
    
    result.command = command
    result.requirement = requirement
    result.redirect_modifier = redirect_modifier
    result.redirect = redirect
    result.forked = forked
    
    for argument in root_node.get_children():
        result.add_child(argument)
    
    return result
