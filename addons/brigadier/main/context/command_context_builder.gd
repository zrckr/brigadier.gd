#warning-ignore-all:shadowed_variable

extends Reference

const Command = preload('../functions/command.gd')
const CommandContext = preload('./command_context.gd')
const RedirectModifier = preload('../functions/redirect_modifier.gd')
const StringRange = preload('./string_range.gd')

var dispatcher: Reference
var source: Object
var root_node: Reference
var ranges: StringRange
var arguments: Dictionary
var nodes: Array
var command: Command
var child: Reference
var redirect_modifier: RedirectModifier
var forked: bool

var last_child: Reference setget , _get_last_child


func _init(_dispatcher: Reference, _source: Object, _root: Reference, _start: int) -> void:
    dispatcher = _dispatcher
    source = _source
    root_node = _root
    ranges = StringRange.at(_start)
    arguments = {}
    nodes = []
    command = null
    child = null
    redirect_modifier = null
    forked = false


func with_source(value: Object):
    source = value
    return self


func with_argument(name: String, parsed_argument: Dictionary):
    arguments[name] = parsed_argument
    return self
    

func with_command(value: Command):
    command = value
    return self


func with_node(node: Reference, ranged: StringRange):
    nodes.append({
        node = node,
        ranges = ranged,
    })
    
    ranges = StringRange.emcompassing(ranges, ranged)
    redirect_modifier = node.redirect_modifier
    forked = node.forked
    return self


func with_child(object: Reference):
    child = object
    return self


func copy() -> Reference:
    var builder = get_script().new(dispatcher, source, root_node, ranges.start)
    builder.arguments.merge(arguments)
    builder.nodes.append_array(nodes)
    builder.command = command
    builder.child = child
    builder.ranges = ranges
    builder.forked = forked
    return builder

 
func build(input: String) -> CommandContext:
    var context = CommandContext.new()
    if child:
        context.child = child.build(input)
    
    context.source = source
    context.input = input
    context.arguments = arguments
    context.command = command
    context.root_node = root_node
    context.nodes = nodes
    context.ranges = ranges
    context.redirect_modifier = redirect_modifier
    context.forked = forked
    return context


func find_suggestion_context(cursor: int) -> Dictionary:
    assert(ranges.start <= cursor, "Can't find node before cursor")
    var suggestion_context = {
        parent = null,
        start_pos = 0
    }

    if ranges.end >= cursor:
        var prev = root_node
        for parsed_node in nodes:
            var node_range = parsed_node.ranges
            
            if node_range.start <= cursor and cursor <= node_range.end:
                return {
                    parent = prev,
                    start_pos = node_range.start
                }
            
            prev = parsed_node.node
        
        assert(prev != null, "Can't find node before cursor")
        return {
            parent = prev,
            start_pos = ranges.start
        }
    if child:
        return child.find_suggestion_context(cursor)
    elif nodes:
        var parsed_last = nodes.back()
        return {
            parent = parsed_last.node,
            start_pos = parsed_last.ranges.end + 1
        }
    else:
        return {
            parent = root_node,
            start_pos = ranges.start
        }


func _get_last_child() -> Reference:
    var result = self
    while result.child:
        result = result.child
    return result
