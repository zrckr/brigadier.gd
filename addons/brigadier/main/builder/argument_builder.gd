extends Reference

const Command = preload('../functions/command.gd')
const Requirement = preload('../functions/requirement.gd')
const RedirectModifier = preload('../functions/redirect_modifier.gd')

const CommandNode = preload('../tree/command_node.gd')
const RootCommandNode = preload('../tree/root_command_node.gd')

var command: Command
var requirement: Requirement
var redirect_modifier: RedirectModifier

var root_node: RootCommandNode
var redirect: CommandNode
var forked: bool


func _init() -> void:
    root_node = RootCommandNode.new()


func get_self() -> Reference:
    return null


func build() -> CommandNode:
    return null


func then(argument: Reference):
    if redirect:
        push_error('Cannot add children to a redirected node')
        return get_self()

    var ArgumentBuilder = load('res://addons/brigadier/main/builder/argument_builder.gd')
    
    if argument is ArgumentBuilder:
        root_node.add_child(argument.build())
    elif argument is CommandNode:
        root_node.add_child(argument)
    
    return get_self()


func executes(cmd: Command):
    command = cmd
    return get_self()


func requires(predicate: Requirement):
    requirement = predicate
    return get_self()


func redirect(target: CommandNode, modifier: RedirectModifier = null):
    return forward(target, modifier, false)


func fork(target: CommandNode, modifier: RedirectModifier):
    return forward(target, modifier, true)


func forward(target: CommandNode, modifier: RedirectModifier, fork: bool):
    if not root_node.get_children().empty():
        push_error('Cannot forward a node with children')
        return get_self()
    
    redirect = target
    redirect_modifier = modifier
    forked = fork
    return get_self()
