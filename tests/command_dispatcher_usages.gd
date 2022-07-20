#warning-ignore-all:return_value_discarded

extends WAT.Test

const Command = preload('res://addons/brigadier/main/functions/command.gd')
const Requirement = preload('res://addons/brigadier/main/functions/requirement.gd')
const CommandDispatcher = preload('res://addons/brigadier/main/command_dispatcher.gd')
const CommandNode = preload('res://addons/brigadier/main/tree/command_node.gd')
const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('./functions.gd')


class FalseRequirement:
    extends 'res://addons/brigadier/main/functions/requirement.gd'

    func test(_source: Object) -> bool:
        return false


var subject: CommandDispatcher
var command: Command
var source: Object
var requirement: FalseRequirement


func pre() -> void:
    subject = CommandDispatcher.new()
    command = Command.new()
    source = Reference.new()
    requirement = FalseRequirement.new()

    subject.register(
        f.literal("a") \
            .then(
                f.literal("1") \
                    .then(f.literal("i").executes(command)) \
                    .then(f.literal("ii").executes(command)) \
            ) \
            .then(
                f.literal("2") \
                    .then(f.literal("i").executes(command)) \
                    .then(f.literal("ii").executes(command)) \
            )
    )
    subject.register(f.literal("b").then(f.literal("1").executes(command)))
    subject.register(f.literal("c").executes(command))
    subject.register(f.literal("d").requires(requirement).executes(command))
    subject.register(
        f.literal("e") \
            .executes(command) \
            .then(
                f.literal("1") \
                    .executes(command) \
                    .then(f.literal("i").executes(command)) \
                    .then(f.literal("ii").executes(command)) \
            )
    )
    subject.register(
        f.literal("f") \
            .then(
                f.literal("1") \
                    .then(f.literal("i").executes(command)) \
                    .then(f.literal("ii").executes(command).requires(requirement)) \
            ) \
            .then(
                f.literal("2") \
                    .then(f.literal("i").executes(command).requires(requirement)) \
                    .then(f.literal("ii").executes(command)) \
            )
    )
    subject.register(
        f.literal("g") \
            .executes(command) \
            .then(f.literal("1").then(f.literal("i").executes(command))) \
    )
    subject.register(
        f.literal("h") \
            .executes(command) \
            .then(f.literal("1").then(f.literal("i").executes(command))) \
            .then(f.literal("2").then(f.literal("i").then(f.literal("ii").executes(command)))) \
            .then(f.literal("3").executes(command)) \
    )
    subject.register(
        f.literal("i") \
            .executes(command) \
            .then(f.literal("1").executes(command)) \
            .then(f.literal("2").executes(command)) \
    )
    subject.register(
        f.literal("j") \
            .redirect(subject.root) \
    )
    subject.register(
        f.literal("k") \
            .redirect(_get_command("h")) \
    )


func test_all_usage_no_commands() -> void:
    subject = CommandDispatcher.new()
    var results = subject.get_all_usage(subject.root, source, true)
    asserts.is_true(results.empty())


func test_smart_usage_no_commands() -> void:
    subject = CommandDispatcher.new()
    var results = subject.get_smart_usage(subject.root, source)
    asserts.is_true(results.empty())


func test_all_usage_root() -> void:
    var results = subject.get_all_usage(subject.root, source, true)
    var array = [
        "a 1 i",
        "a 1 ii",
        "a 2 i",
        "a 2 ii",
        "b 1",
        "c",
        "e",
        "e 1",
        "e 1 i",
        "e 1 ii",
        "f 1 i",
        "f 2 ii",
        "g",
        "g 1 i",
        "h",
        "h 1 i",
        "h 2 i ii",
        "h 3",
        "i",
        "i 1",
        "i 2",
        "j ...",
        "k -> h"
    ]
    asserts.is_equal(str(results), str(array))


func test_smart_usage_root() -> void:
    var results = subject.get_smart_usage(subject.root, source)
    var dict = {
        _get_command("a"): "a (1|2)",
        _get_command("b"): "b 1",
        _get_command("c"): "c",
        _get_command("e"): "e [1]",
        _get_command("f"): "f (1|2)",
        _get_command("g"): "g [1]",
        _get_command("h"): "h [1|2|3]",
        _get_command("i"): "i [1|2]",
        _get_command("j"): "j ...",
        _get_command("k"): "k -> h",
    }
    asserts.is_equal(str(results), str(dict))


func test_smart_usage_h() -> void:
    var results = subject.get_smart_usage(_get_command("h"), source);
    var dict = {
        _get_command("h 1"): "[1] i",
        _get_command("h 2"): "[2] i ii",
        _get_command("h 3"): "[3]",
    }
    asserts.is_equal(str(results), str(dict))


func test_smart_usage_offset_h() -> void:
    var offset_h = StringReader.new("/|/|/h")
    offset_h.cursor = 5
    
    var results = subject.get_smart_usage(_get_command_reader(offset_h), source)
    var dict = {
        _get_command("h 1"): "[1] i",
        _get_command("h 2"): "[2] i ii",
        _get_command("h 3"): "[3]",
    }
    asserts.is_equal(str(results), str(dict))


func _get_command(string: String) -> CommandNode:
    return subject.parse(string, source).context.nodes.back().node


func _get_command_reader(reader: StringReader) -> CommandNode:
    return subject.parse_reader(reader, source).context.nodes.back().node
