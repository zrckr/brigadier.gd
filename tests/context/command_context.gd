extends WAT.Test

const CommandContextBuilder = preload('res://addons/brigadier/main/context/command_context_builder.gd')
const CommandDispatcher = preload('res://addons/brigadier/main/command_dispatcher.gd')
const CommandNode = preload('res://addons/brigadier/main/tree/command_node.gd')
const StringRange = preload('res://addons/brigadier/main/context/string_range.gd')
const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const Result = preload('res://addons/brigadier/main/result.gd')

var source: Object
var dispatcher: CommandDispatcher
var root_node: CommandNode
var builder: CommandContextBuilder


func pre() -> void:
    source = Reference.new()
    dispatcher = CommandDispatcher.new()
    root_node = CommandNode.new()
    builder = CommandContextBuilder.new(dispatcher, source, root_node, 0)


func test_get_argument_nonexistent() -> void:
    var value = builder.build('').get_argument('foo', TYPE_OBJECT)
    asserts.is_null(value)


func test_get_argument_wrong_type() -> void:
    var parsed = {
        range = StringRange.between(0, 1), 
        result = Result.ok(123)
    }
    var context = builder.with_argument('foo', parsed).build('123')
    var value = context.get_argument('foo', TYPE_STRING)
    asserts.is_null(value)


func test_get_argument() -> void:
    var parsed = {
        range = StringRange.between(0, 1), 
        result = Result.ok(123)
    }
    var context = builder.with_argument('foo', parsed).build('123')
    var value = context.get_argument('foo', TYPE_INT)
    asserts.is_equal(value, 123)


func test_source() -> void:
    asserts.is_equal(builder.build('').source, source)


func test_root_node() -> void:
    asserts.is_equal(builder.build('').root_node, root_node)


func test_get_raw() -> void:
    var reader = StringReader.new('0123456789')
    var ranged = StringRange.between(2, 5)
    asserts.is_equal(ranged.get(reader), "234")
