extends WAT.Test

const CommandNode = preload('res://addons/brigadier/main/tree/command_node.gd')
const f = preload('../functions.gd')


class TestableArgumentBuilder:
    extends 'res://addons/brigadier/main/builder/argument_builder.gd'

    func get_self():
        return self

    func build():
        return null


var builder: TestableArgumentBuilder


func pre() -> void:
    builder = TestableArgumentBuilder.new()


func test_arguments() -> void:
    var argument = f.argument('bar', f.int()).build()
    builder.then(argument)
    
    var nodes = builder.root_node.get_children()
    asserts.is_equal(nodes.size(), 1)
    asserts.is_true(argument in nodes)


func test_redirect() -> void:
    var target = CommandNode.new()
    builder.redirect(target)
    asserts.is_equal(builder.redirect, target)


func test_redirect_with_child() -> void:
    var target = CommandNode.new()
    builder.then(f.literal('foo'))
    builder.redirect(target)
    asserts.is_null(builder.redirect)


func test_then_with_redirect() -> void:
    var target = CommandNode.new()
    builder.redirect(target)
    builder.then(f.literal('foo'))
    asserts.is_not_null(builder.redirect)
