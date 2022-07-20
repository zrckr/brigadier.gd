extends WAT.Test

const Command = preload('res://addons/brigadier/main/functions/command.gd')
const CommandContext = preload('res://addons/brigadier/main/context/command_context.gd')
const CommandContextBuilder = preload('res://addons/brigadier/main/context/command_context_builder.gd')
const CommandDispatcher = preload('res://addons/brigadier/main/command_dispatcher.gd')
const CommandNode = preload('res://addons/brigadier/main/tree/command_node.gd')
const IntegerArgumentType = preload('res://addons/brigadier/main/arguments/int.gd')
const LiteralArgumentBuilder = preload('res://addons/brigadier/main/builder/literal_argument_builder.gd')
const RequiredArgumentBuilder = preload('res://addons/brigadier/main/builder/required_argument_builder.gd')
const StringRange = preload('res://addons/brigadier/main/context/string_range.gd')
const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const Suggestion = preload('res://addons/brigadier/main/suggestion/suggestion.gd')
const Suggestions = preload('res://addons/brigadier/main/suggestion/suggestions.gd')
const SuggestionsBuilder = preload('res://addons/brigadier/main/suggestion/suggestions_builder.gd')
const f = preload('../functions.gd')

var command: Command


func get_command_node() -> CommandNode:
    return null


func pre() -> void:
    command = Command.new()


func test_add_child() -> void:
    var node = get_command_node()
    if not node:
        asserts.auto_pass('Abstract call')
        return
    
    node.add_child(f.literal('child1').build())
    node.add_child(f.literal('child2').build())
    node.add_child(f.literal('child1').build())
    
    asserts.is_equal(node.get_children().size(), 2)


func test_add_child_merges_grandchildren() -> void:
    var node = get_command_node()
    if not node:
        asserts.auto_pass('Abstract call')
        return

    node.add_child(f.literal('child').then(
        f.literal('grandchild1')
    ).build())

    node.add_child(f.literal('child').then(
        f.literal('grandchild2')
    ).build())

    asserts.is_equal(node.get_children().size(), 1)
    asserts.is_equal(node.get_children()[0].get_children().size(), 2)


func test_add_child_preserves_command() -> void:
    var node = get_command_node()
    if not node:
        asserts.auto_pass('Abstract call')
        return
    
    node.add_child(f.literal('child').executes(command).build())
    node.add_child(f.literal('child').build())
    asserts.is_equal(node.get_children()[0].command, command)


func test_add_child_overwrites_command() -> void:
    var node = get_command_node()
    if not node:
        asserts.auto_pass('Abstract call')
        return
    
    node.add_child(f.literal('child').build())
    node.add_child(f.literal('child').executes(command).build())
    asserts.is_equal(node.get_children()[0].command, command)
