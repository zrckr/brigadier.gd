#warning-ignore-all:return_value_discarded

extends './abstract_command_node.gd'

const RootCommandNode = preload('res://addons/brigadier/main/tree/root_command_node.gd')
const LiteralCommandNode = preload('res://addons/brigadier/main/tree/literal_command_node.gd')

var node: LiteralCommandNode
var context_builder: CommandContextBuilder


func pre() -> void:
    .pre()
    node = f.literal('foo').build()
    context_builder = CommandContextBuilder.new(CommandDispatcher.new(), Reference.new(), RootCommandNode.new(), 0)


func get_command_node() -> CommandNode:
    return node


func test_parse() -> void:
    var reader = StringReader.new('foo bar')
    node.parse(reader, context_builder)
    asserts.is_equal(reader.remaining, ' bar')


func test_parse_exact() -> void:
    var reader = StringReader.new('foo')
    node.parse(reader, context_builder)
    asserts.is_equal(reader.remaining, '')


func test_parse_similar() -> void:
    var reader = StringReader.new('foobar')
    var result = node.parse(reader, context_builder)
    
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_parse_invalid() -> void:
    var reader = StringReader.new('bar')
    var result = node.parse(reader, context_builder)
    
    asserts.is_not_null(result.error)
    asserts.is_not_equal(result.error.message, '')
    asserts.is_equal(result.error.cursor, 0)


func test_usage() -> void:
    asserts.is_equal(node.get_usage_text(), 'foo')


func test_suggestions() -> void:
    var empty = node.list_suggestions(context_builder.build(""), SuggestionsBuilder.new("", "", 0))
    var suggestions = [Suggestion.new(StringRange.at(0), "foo")]
    asserts.is_equal(str(empty.suggestions), str(suggestions))
    
    var foo = node.list_suggestions(context_builder.build("foo"), SuggestionsBuilder.new("foo", "foo", 0))
    asserts.is_true(foo.is_empty())
    
    var food = node.list_suggestions(context_builder.build("food"), SuggestionsBuilder.new("food", "food", 0))
    asserts.is_true(food.is_empty())
    
    node.list_suggestions(context_builder.build("b"), SuggestionsBuilder.new("b", "b", 0))
    asserts.is_true(food.is_empty())


func test_create_builder() -> void:
    var builder = node.create_builder()
    asserts.is_equal(builder.literal, node.literal)
    asserts.is_equal(builder.requirement, node.requirement)
    asserts.is_equal(builder.command, node.command)
