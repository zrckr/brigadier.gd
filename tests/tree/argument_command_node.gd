#warning-ignore-all:return_value_discarded

extends './abstract_command_node.gd'

const RootCommandNode = preload('res://addons/brigadier/main/tree/root_command_node.gd')
const ArgumentCommandNode = preload('res://addons/brigadier/main/tree/argument_command_node.gd')

var node: ArgumentCommandNode
var context_builder: CommandContextBuilder


func pre() -> void:
    .pre()
    node = f.argument('foo', f.int()).build()
    context_builder = CommandContextBuilder.new(CommandDispatcher.new(), Reference.new(), RootCommandNode.new(), 0)


func get_command_node() -> CommandNode:
    return node


func test_parse() -> void:
    var reader = StringReader.new('123 456')
    node.parse(reader, context_builder)

    var arguments = context_builder.arguments
    asserts.is_true(arguments.has('foo'))
    asserts.is_equal(arguments.get('foo').result.value, 123)


func test_usage() -> void:
    asserts.is_equal(node.get_usage_text(), '<foo>')


func test_suggestions() -> void:
    var result = node.list_suggestions(context_builder.build(''), SuggestionsBuilder.new('', '', 0))
    asserts.is_true(result.is_empty())


func test_create_builder() -> void:
    var builder = node.create_builder()
    asserts.is_equal(builder.name, node.name)
    asserts.is_equal(builder.type, node.type)
    asserts.is_equal(builder.requirement, node.requirement)
    asserts.is_equal(builder.command, node.command)
