extends WAT.Test

const Command = preload('res://addons/brigadier/main/functions/command.gd')
const CommandNode = preload('res://addons/brigadier/main/tree/command_node.gd')
const LiteralArgumentBuilder = preload('res://addons/brigadier/main/builder/literal_argument_builder.gd')
const f = preload('../functions.gd')

var builder: LiteralArgumentBuilder


func pre() -> void:
    builder = LiteralArgumentBuilder.new('foo')


func test_build() -> void:
    var node = builder.build()
    asserts.is_equal(node.literal, 'foo')


func test_build_with_executor() -> void:
    var command = Command.new()
    var node = builder.executes(command).build()
    asserts.is_equal(node.literal, 'foo')
    asserts.is_equal(node.command, command)


func test_build_with_children() -> void:
    var node = builder \
        .then(f.argument('bar', f.int())) \
        .then(f.argument('baz', f.int())) \
        .build()
    
    asserts.is_equal(node.get_children().size(), 2)
