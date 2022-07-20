#warning-ignore-all:return_value_discarded

extends './abstract_command_node.gd'

const RootCommandNode = preload('res://addons/brigadier/main/tree/root_command_node.gd')

var node: RootCommandNode


func pre() -> void:
    .pre()
    node = RootCommandNode.new()


func get_command_node() -> CommandNode:
    return node


func test_parse() -> void:
    var reader = StringReader.new('hello world')
    var context = CommandContextBuilder.new(CommandDispatcher.new(), Reference.new(), RootCommandNode.new(), 0)
    node.parse(reader, context)
    asserts.is_equal(reader.cursor, 0)


func test_add_child_no_root() -> void:
    node.add_child(RootCommandNode.new())
    asserts.is_equal(node.get_children().size(), 0)


func test_usage() -> void:
    asserts.is_equal(node.get_usage_text(), '')


func test_suggestions() -> void:
    var context = CommandContext.new()
    var result = node.list_suggestions(context, SuggestionsBuilder.new('', '', 0))
    asserts.is_true(result.is_empty())


func test_create_builder() -> void:
    asserts.is_null(node.create_builder())
