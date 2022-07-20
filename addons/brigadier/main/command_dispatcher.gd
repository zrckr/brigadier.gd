extends Reference

const Error = preload('./error.gd')
const Result = preload('./result.gd')
const StringReader = preload('./string_reader.gd')
const ParseResult = preload('./parse_result.gd')

const ArgumentType = preload('./arguments/argument_type.gd')
const BoolArgumentType = preload('./arguments/bool.gd')
const FloatArgumentType = preload('./arguments/float.gd')
const IntArgumentType = preload('./arguments/int.gd')
const StringArgumentType = preload('./arguments/string.gd')
const Vector2ArgumentType = preload('./arguments/vector2.gd')
const Vector3ArgumentType = preload('./arguments/vector3.gd')

const LiteralArgumentBuilder = preload('./builder/literal_argument_builder.gd')
const RequiredArgumentBuilder = preload('./builder/required_argument_builder.gd')

const CommandContext = preload('./context/command_context.gd')
const CommandContextBuilder = preload('./context/command_context_builder.gd')

const AmbiguityConsumer = preload('./functions/ambiguity_consumer.gd')
const Command = preload('./functions/command.gd')
const RedirectModifier = preload('./functions/redirect_modifier.gd')
const Requirement = preload('./functions/requirement.gd')
const ResultConsumer = preload('./functions/result_consumer.gd')

const CommandNode = preload('./tree/command_node.gd')
const ArgumentCommandNode = preload('./tree/argument_command_node.gd')
const LiteralCommandNode = preload('./tree/literal_command_node.gd')
const RootCommandNode = preload('./tree/root_command_node.gd')

const Suggestions = preload('./suggestion/suggestions.gd')
const SuggestionsBuilder = preload('./suggestion/suggestions_builder.gd')

const ERR_DISPATCHER_FAILED_COMMAND := 'command failed'
const ERR_DISPATCHER_UNKNOWN_COMMAND := 'unknown command'
const ERR_DISPATCHER_UNKNOWN_ARGUMENT := 'incorrect argument for command'
const ERR_DISPATCHER_EXPECTED_ARGUMENT_SEPARATOR := 'expected whitespace to end one argument, but found trailing data'
const ERR_DISPATCHER_PARSE_EXCEPTION := 'could not parse command: %s'

const ARGUMENT_SEPARATOR := " "
const USAGE_OPTIONAL_OPEN := "["
const USAGE_OPTIONAL_CLOSE := "]"
const USAGE_REQUIRED_OPEN  := "("
const USAGE_REQUIRED_CLOSE  := ")"
const USAGE_OR := "|"

var root: RootCommandNode
var consumer: ResultConsumer


func _init(_root: RootCommandNode = null) -> void:
    root = RootCommandNode.new() if _root == null else _root
    consumer = ResultConsumer.new()


func register(command: LiteralArgumentBuilder) -> LiteralCommandNode:
    var build = command.build()
    root.add_child(build)
    return build


func do(command: String, source: Object = null) -> Error:
    return execute(parse(command, source))


func do_reader(reader: StringReader, source: Object = null) -> Error:
    return execute(parse_reader(reader, source))


func execute(parse: ParseResult) -> Error:
    if parse.reader.can_read():
        if parse.errors.size() == 1:
            return parse.errors.values().front().error
        elif parse.context.ranges.is_empty():
            return StringReader.Error.new(parse.reader, ERR_DISPATCHER_UNKNOWN_COMMAND)
        else:
            return StringReader.Error.new(parse.reader, ERR_DISPATCHER_UNKNOWN_ARGUMENT)

    var forked = false
    var found_command = false
    var original = parse.context.build(parse.reader.string)
    var contexts = [original]
    var next = []

    while contexts:
        for context in contexts:
            var child = context.child
            if child:
                forked = forked or context.forked
                if child.has_nodes():
                    found_command = true
                    var modifier = context.redirect_modifier
                    if not modifier:
                        next.append(child.copy_for(context))
                    else:
                        var result = modifier.apply(context)
                        if not result or result.error:
                            consumer.on_command_complete(context, false, 0)
                            if not forked:
                                return result.error
                        else:
                            next.append(child.copy_for(result.value))
            elif context.command:
                found_command = true
                var result = context.command.run(context)
                if result == OK:
                    consumer.on_command_complete(context, true, result)
                else:
                    consumer.on_command_complete(context, false, OK)
                    if not forked:
                        return Error.new(ERR_DISPATCHER_FAILED_COMMAND)

        contexts = next
        next = []
    
    if not found_command:
        consumer.on_command_complete(original, false, 0)
        return StringReader.Error.new(parse.reader, ERR_DISPATCHER_UNKNOWN_COMMAND)

    return null


func parse(command: String, source: Object) -> ParseResult:
    return parse_reader(StringReader.new(command), source)


func parse_reader(command: StringReader, source: Object) -> ParseResult:
    var ctx = CommandContextBuilder.new(self, source, root, command.cursor)
    return parse_nodes(command, root, ctx)


func parse_nodes(original_reader: StringReader, node: CommandNode, context_so_far: CommandContextBuilder) -> ParseResult:
    var source = context_so_far.source
    var cursor = original_reader.cursor
    var errors = {}
    var potentials = []

    for child in node.get_relevant_nodes(original_reader):
        if not child.can_use(source):
            continue
        
        var context = context_so_far.copy()
        var reader = StringReader.new(original_reader)
        var result = child.parse(reader, context)

        if result.error:
            reader.cursor = cursor
            errors[child] = Result.error(
                StringReader.Error.new(reader, ERR_DISPATCHER_PARSE_EXCEPTION % result.error.get_message()))
            continue

        if reader.can_read():
            if reader.peek() != ord(ARGUMENT_SEPARATOR):
                reader.cursor = cursor
                errors[child] = Result.error(
                    StringReader.Error.new(reader, ERR_DISPATCHER_EXPECTED_ARGUMENT_SEPARATOR))
                continue

        context.with_command(child.command)
        var length = 1 if child.redirect else 2

        if reader.can_read(length):
            reader.skip()
            if child.redirect:
                var child_context = CommandContextBuilder.new(self, source, child.redirect, reader.cursor)
                var parse = parse_nodes(reader, child.redirect, child_context)
                context.with_child(parse.context)
                return ParseResult.new(context, parse.reader, parse.errors)
            else:
                var parse = parse_nodes(reader, child, context)
                potentials.append(parse)
        else:
            potentials.append(ParseResult.new(context, reader))

    if potentials:
        potentials.sort_custom(self, '_potentials_cmp')
        return potentials.front()
    
    return ParseResult.new(context_so_far, original_reader, errors)


func _potentials_cmp(a: ParseResult, b: ParseResult) -> bool:
    if not a.reader.can_read() and b.reader.can_read():
        return false
    
    if a.reader.can_read() and not b.reader.can_read():
        return true
    
    if not a.errors and b.errors:
        return false
    
    if a.errors and not b.errors:
        return true
    
    return false

func get_all_usage(node: CommandNode, source: Object, restricted: bool) -> Array:
    var result = []
    _get_all_usage(node, source, result, '', restricted)
    return result


func _get_all_usage(node: CommandNode, source: Object, result: Array, prefix: String, restricted: bool) -> void:
    if restricted and not node.can_use(source):
        return
    
    if node.command and prefix:
        result.append(prefix)
    
    if node.redirect:
        var redirect = (
            "..." if node.redirect == root
            else "-> " + node.redirect.get_usage_text()
        )
        var text = (
            node.get_usage_text() + ARGUMENT_SEPARATOR + redirect if prefix.empty() 
            else prefix + ARGUMENT_SEPARATOR + redirect
        )
        result.append(text)
    
    elif node.get_children():
        for child in node.get_children():
            var text = (
                child.get_usage_text() if prefix.empty()
                else prefix + ARGUMENT_SEPARATOR + child.get_usage_text()
            )
            _get_all_usage(child, source, result, text, restricted)


func get_smart_usage(node: CommandNode, source: Object) -> Dictionary:
    var result = {}
    var optional = node.command != null

    for child in node.get_children():
        var usage = _get_smart_usage(child, source, optional, false)
        if usage:
            result[child] = usage

    return result


func _get_smart_usage(node: CommandNode, source: Object, optional: bool, deep: bool) -> String:
    if not node.can_use(source):
        return ''

    var this = USAGE_OPTIONAL_OPEN + node.get_usage_text() + USAGE_OPTIONAL_CLOSE if optional else node.get_usage_text()
    var child_optional = node.command != null
    var open = USAGE_OPTIONAL_OPEN if child_optional else USAGE_REQUIRED_OPEN
    var close = USAGE_OPTIONAL_CLOSE if child_optional else USAGE_REQUIRED_CLOSE

    if not deep:
        if node.redirect:
            var redirect = "..." if node.redirect == root else "-> " + node.redirect.get_usage_text()
            return this + ARGUMENT_SEPARATOR + redirect
        
        else:
            var children = []
            for child in node.get_children():
                if child.can_use(source):
                    children.append(child)
            
            if len(children) == 1:
                    var usage = _get_smart_usage(children[0], source, child_optional, child_optional)
                    if usage:
                        return this + ARGUMENT_SEPARATOR + usage
            
            elif len(children) > 1:
                var child_usage = {}
                
                for child in children:
                    var usage = _get_smart_usage(child, source, child_optional, true)
                    if usage:
                        child_usage[usage] = null
                
                if len(child_usage) == 1:
                    var usage = child_usage[0]
                    return this + ARGUMENT_SEPARATOR + \
                        (USAGE_OPTIONAL_OPEN + usage + USAGE_OPTIONAL_CLOSE if child_optional else usage)
                
                elif len(child_usage) > 1:
                    var builder = open
                    var count = 0
                    for child in children:
                        if count > 0:
                            builder += USAGE_OR
                        builder += child.get_usage_text()
                        count += 1
                    if count > 0:
                        builder += close
                        return this + ARGUMENT_SEPARATOR + str(builder)

    return this


func get_completion_suggestions(parse: ParseResult, cursor: int = -1) -> Suggestions:
    if cursor == -1:
        cursor = len(parse.reader.string)
    
    var context = parse.context
    var node_before_cursor = context.find_suggestion_context(cursor)
    var parent = node_before_cursor.parent
    var start = min(node_before_cursor.start_pos, cursor)

    var full_input = parse.reader.string
    var truncated_input = full_input.substr(0, cursor)
    var truncated_input_lower = truncated_input.to_lower()
    
    var suggestions = []
    for node in parent.get_children():
        var builder = SuggestionsBuilder.new(truncated_input, truncated_input_lower, start)
        var suggestion = node.list_suggestions(context.build(truncated_input), builder)
        suggestions.append(suggestion)

    return Suggestions.merge(full_input, suggestions)


func get_path(target: CommandNode) -> Array:
    var nodes = []
    _add_paths(root, nodes, [])

    for list in nodes:
        if list.back() == target:
            var result = []
            for node in list:
                if node != root:
                    result.append(node.get_name())
            return result
    
    return []


func find_node(path: Array) -> CommandNode:
    var node = root
    for name in path:
        node = node.get_child(name)
        if not node:
            return null
    return node


func find_ambiguities(ambiguity_consumer: AmbiguityConsumer) -> void:
    root.find_ambiguities(ambiguity_consumer)


func _add_paths(node: CommandNode, result: Array, parents: Array) -> void:
    var current = parents.duplicate()
    current.append(node)
    result.append(current)
    
    for child in node.get_children():
        _add_paths(child, result, current)


func literal(name: String) -> LiteralArgumentBuilder:
    return LiteralArgumentBuilder.new(name)


func argument(name: String, type: ArgumentType) -> RequiredArgumentBuilder:
    return RequiredArgumentBuilder.new(name, type)


func int(minimum = IntArgumentType.INT_MIN, maximum = IntArgumentType.INT_MAX) -> IntArgumentType:
    return IntArgumentType.new(minimum, maximum)


func float(minimum = -INF, maximum = INF) -> FloatArgumentType:
    return FloatArgumentType.new(minimum, maximum)


func bool() -> BoolArgumentType:
    return BoolArgumentType.new()


func word() -> StringArgumentType:
    return StringArgumentType.new(StringArgumentType.TYPE_SINGLE_WORD)


func string() -> StringArgumentType:
    return StringArgumentType.new(StringArgumentType.TYPE_QUOTABLE_PHRASE)


func greedy_string() -> StringArgumentType:
    return StringArgumentType.new(StringArgumentType.TYPE_GREEDY_PHRASE)


func vector3() -> Vector3ArgumentType:
    return Vector3ArgumentType.new()


func vector2() -> Vector2ArgumentType:
    return Vector2ArgumentType.new()
