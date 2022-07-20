#warning-ignore-all:return_value_discarded

extends WAT.Test

const Command = preload('res://addons/brigadier/main/functions/command.gd')
const CommandDispatcher = preload('res://addons/brigadier/main/command_dispatcher.gd')
const RedirectModifier = preload('res://addons/brigadier/main/functions/redirect_modifier.gd')
const Requirement = preload('res://addons/brigadier/main/functions/requirement.gd')
const Result = preload('res://addons/brigadier/main/result.gd')
const StringReader = preload('res://addons/brigadier/main/string_reader.gd')
const f = preload('./functions.gd')


class FalseRequirement:
    extends 'res://addons/brigadier/main/functions/requirement.gd'

    func test(_source: Object) -> bool:
        return false


var subject: CommandDispatcher
var source: Object
var command: Command
var command_director: Object


func pre() -> void:
    subject = CommandDispatcher.new()
    source = Reference.new()
    command_director = direct.script(Command)
    command_director.method('run').stub(OK)
    command = command_director.double()


func test_create_and_execute_command() -> void:
    subject.register(f.literal("foo").executes(command))
    var error = subject.do("foo", source)

    asserts.is_null(error)
    asserts.was_called_with_arguments(command_director, 'run', [any()])

    
func test_create_and_execute_offset_command() -> void:
    subject.register(f.literal("foo").executes(command))
    var error = subject.do_reader(_input_with_offset("/foo", 1))
    
    asserts.is_null(error)
    asserts.was_called_with_arguments(command_director, 'run', [any()])

    
func test_create_and_merge_commands() -> void:
    subject.register(f.literal("base").then(f.literal("foo").executes(command)))
    subject.register(f.literal("base").then(f.literal("bar").executes(command)))

    var error1 = subject.do("base foo", source)
    var error2 = subject.do("base bar", source)

    asserts.is_null(error1)
    asserts.is_null(error2)
    asserts.was_called_with_arguments(command_director, 'run', [any()])


func test_execute_unknown_command() -> void:
    subject.register(f.literal("bar"))
    subject.register(f.literal("baz"))
    var error = subject.do("foo", source)
    
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 0)

    
func test_execute_impermissible_command() -> void:
    subject.register(f.literal("foo").requires(FalseRequirement.new()))
    var error = subject.do("foo", source)
    
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 0)

    
func test_execute_empty_command() -> void:
    subject.register(f.literal(""))
    var error = subject.do("", source)
    
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 0)

    
func test_execute_unknown_subcommand() -> void:
    subject.register(f.literal("foo"))
    var error = subject.do("foo bar", source)
    
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 4)

    
func test_execute_incorrect_literal() -> void:
    subject.register(f.literal("foo").executes(command).then(f.literal("bar")))
    var error = subject.do("foo baz", source)
    
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 4)

    
func test_execute_ambiguous_incorrect_argument() -> void:
    subject.register(
        f.literal("foo") \
            .executes(command) \
            .then(f.literal("bar")) \
            .then(f.literal("baz")) \
    )
    
    var error = subject.do("foo unknown", source)
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 4)

    
func test_execute_subcommand() -> void:
    var sub_command_director = direct.script(Command)
    sub_command_director.method('run').stub(OK)
    var sub_command = sub_command_director.double()

    subject.register(f.literal("foo").then(
        f.literal("a")
    ).then(
        f.literal("=").executes(sub_command)
    ).then(
        f.literal("c")
    ).executes(command))

    var error = subject.do("foo =", source)
    asserts.is_null(error)
    asserts.was_called_with_arguments(sub_command_director, 'run', [any()])

    
func test_parse_incomplete_literal() -> void:
    subject.register(f.literal("foo").then(f.literal("bar").executes(command)))
    var parse = subject.parse("foo ", source)
    
    asserts.is_equal(parse.reader.remaining, ' ')
    asserts.is_equal(parse.context.nodes.size(), 1)

    
func test_parse_incomplete_argument() -> void:
    subject.register(f.literal("foo").then(f.argument("bar", f.int()).executes(command)))
    var parse = subject.parse("foo ", source)
    
    asserts.is_equal(parse.reader.remaining, ' ')
    asserts.is_equal(parse.context.nodes.size(), 1)

    
func test_execute_ambiguious_parent_subcommand() -> void:
    var sub_command_director = direct.script(Command)
    sub_command_director.method('run').stub(OK)
    var sub_command = sub_command_director.double()
    
    subject.register(
        f.literal("test") \
            .then(
                f.argument("incorrect", f.int()) \
                    .executes(command)
            ) \
            .then(
                f.argument("right", f.float()) \
                    .then(
                        f.argument("sub", f.float()) \
                            .executes(sub_command)
                    )
            )
    )

    var error = subject.do('test 3.14 6.28', source)
    asserts.is_null(error)
    asserts.was_called_with_arguments(sub_command_director, 'run', [any()])
    asserts.was_not_called(command_director, 'run')

    
func test_execute_ambiguious_parent_subcommand_via_redirect() -> void:
    var sub_command_director = direct.script(Command)
    sub_command_director.method('run').stub(OK)
    var sub_command = sub_command_director.double()
    
    var real = subject.register(
        f.literal("test") \
            .then(
                f.argument("incorrect", f.int()) \
                    .executes(command)
            ) \
            .then(
                f.argument("right", f.float()) \
                    .then(
                        f.argument("sub", f.float()) \
                            .executes(sub_command)
                    )
            )
    )
    subject.register(f.literal("redirect").redirect(real))
    
    var error = subject.do("redirect 3.14 6.28", source)
    asserts.is_null(error)
    asserts.was_called_with_arguments(sub_command_director, 'run', [any()])
    asserts.was_not_called(command_director, 'run')


func test_execute_redirected_multiple_times() -> void:
    var concrete_node = subject.register(f.literal("actual").executes(command))
    var redirect_node = subject.register(f.literal("redirected").redirect(subject.root))
    var input = "redirected redirected actual"
    
    var parse = subject.parse(input, source)
    asserts.is_equal(parse.context.ranges.get(input), "redirected")
    asserts.is_equal(parse.context.nodes.size(), 1)
    asserts.is_equal(parse.context.root_node, subject.root)
    asserts.is_equal(str(parse.context.nodes[0].ranges), str(parse.context.ranges))
    asserts.is_equal(parse.context.nodes[0].node, redirect_node)

    var child1 = parse.context.child
    asserts.is_not_null(child1)
    asserts.is_equal(child1.ranges.get(input), "redirected")
    asserts.is_equal(child1.nodes.size(), 1)
    asserts.is_equal(child1.root_node, subject.root)
    asserts.is_equal(str(child1.nodes[0].ranges), str(child1.ranges))
    asserts.is_equal(child1.nodes[0].node, redirect_node)

    var child2 = child1.child
    asserts.is_not_null(child2)
    asserts.is_equal(child2.ranges.get(input), "actual")
    asserts.is_equal(child2.nodes.size(), 1)
    asserts.is_equal(child2.root_node, subject.root)
    asserts.is_equal(str(child2.nodes[0].ranges), str(child2.ranges))
    asserts.is_equal(child2.nodes[0].node, concrete_node)

    var error = subject.execute(parse)
    asserts.is_null(error)
    asserts.was_called_with_arguments(command_director, 'run', [any()])

    
func test_execute_redirected() -> void:
    var source1 = Reference.new()
    var source2 = Reference.new()
    var sources = Result.ok([source1, source2])
    
    var modifier_director = direct.script(RedirectModifier)
    modifier_director.method('apply').stub(sources)
    var modifier = modifier_director.double()

    var concrete_node = subject.register(f.literal("actual").executes(command))
    var redirect_node = subject.register(f.literal("redirected").fork(subject.root, modifier))

    var input = "redirected actual"
    var parse = subject.parse(input, source)
    
    asserts.is_equal(parse.context.ranges.get(input), "redirected")
    asserts.is_equal(parse.context.nodes.size(), 1)
    asserts.is_equal(parse.context.root_node, subject.root)
    asserts.is_equal(str(parse.context.nodes[0].ranges), str(parse.context.ranges))
    asserts.is_equal(parse.context.nodes[0].node, redirect_node)
    asserts.is_equal(parse.context.source, source)

    var parent = parse.context.child
    asserts.is_not_null(parent)
    asserts.is_equal(parent.ranges.get(input), "actual")
    asserts.is_equal(parent.nodes.size(), 1)
    asserts.is_equal(parse.context.root_node, subject.root)
    asserts.is_equal(str(parent.nodes[0].ranges), str(parent.ranges))
    asserts.is_equal(parent.nodes[0].node, concrete_node)
    asserts.is_equal(parent.source, source)

    var error = subject.execute(parse)
    asserts.is_null(error)
    
    asserts.was_called(modifier_director, 'apply')
    asserts.was_called(command_director, 'run') 


func test_execute_orphaned_subcommand() -> void:
    subject.register(
        f.literal("foo") \
            .then(f.argument("bar", f.int())) \
        .executes(command)
    )

    var error = subject.do("foo 5", source)
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 5)

    
func test_execute_invalid_other() -> void:
    var wrong_command_director = direct.script(Command)
    wrong_command_director.method('run')
    var wrong_command = wrong_command_director.double()
    
    subject.register(f.literal("w").executes(wrong_command))
    subject.register(f.literal("world").executes(command))

    var error = subject.do("world", source)
    asserts.is_null(error)
    asserts.was_not_called(wrong_command_director, 'run')
    asserts.was_called_with_arguments(command_director, 'run', [any()])


func test_parse_no_space_separator() -> void:
    subject.register(f.literal("foo").then(f.argument("bar", f.int()).executes(command)))

    var error = subject.do("foo$", source)
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 0)

    
func test_execute_invalid_subcommand() -> void:
    subject.register(f.literal("foo").then(
        f.argument("bar", f.int())
    ).executes(command))

    var error = subject.do("foo bar", source)
    asserts.is_not_null(error)
    asserts.is_not_equal(error.message, '')
    asserts.is_equal(error.cursor, 4)

    
func test_get_path() -> void:
    var bar = f.literal("bar").build()
    subject.register(f.literal('foo').then(bar))
    asserts.is_equal(str(subject.get_path(bar)), str(['foo', 'bar']))


func test_find_node_exists() -> void:
    var bar = f.literal("bar").build()
    subject.register(f.literal('foo').then(bar))
    asserts.is_equal(subject.find_node(['foo', 'bar']), bar)

    
func test_find_node_doesnt_exist() -> void:
    asserts.is_null(subject.find_node(['foo', 'bar']))


func _input_with_offset(input: String, offset: int) -> StringReader:
    var result = StringReader.new(input)
    result.cursor = offset
    return result
