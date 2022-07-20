extends WAT.Test

const Command = preload('res://addons/brigadier/main/functions/command.gd')
const ArgumentType = preload('res://addons/brigadier/main/arguments/argument_type.gd')
const RequiredArgumentBuilder = preload('res://addons/brigadier/main/builder/required_argument_builder.gd')
const f = preload('../functions.gd')

var type: ArgumentType
var builder: RequiredArgumentBuilder


func pre() -> void:
    type = ArgumentType.new()
    builder = RequiredArgumentBuilder.new('foo', type)


func test_build() -> void:
    var node = builder.build()
    asserts.is_equal(node.name, 'foo')
    asserts.is_equal(node.type, type)


func test_build_with_executor() -> void:
    var command = Command.new()
    var node = builder.executes(command).build()
    
    asserts.is_equal(node.name, 'foo')
    asserts.is_equal(node.type, type)
    asserts.is_equal(node.command, command)


func test_build_with_children() -> void:
    var node = builder \
        .then(f.argument('bar', f.int())) \
        .then(f.argument('baz', f.int())) \
        .build()
    
    asserts.is_equal(node.get_children().size(), 2)
