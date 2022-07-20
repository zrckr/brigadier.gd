#warning-ignore-all:shadowed_variable

extends Reference

const Command = preload('../functions/command.gd')
const Coordinate2 = preload('../arguments/coordinates/coordinate2.gd')
const Coordinate3 = preload('../arguments/coordinates/coordinate3.gd')
const RedirectModifier = preload('../functions/redirect_modifier.gd')
const StringRange = preload('./string_range.gd')
const StringType = preload('../string_type.gd')

var arguments: Dictionary
var child: Reference
var command: Command
var forked: bool
var input: String
var nodes: Array
var ranges: StringRange
var redirect_modifier: RedirectModifier
var root_node: Reference
var source: Object

var last_child: Reference setget , _get_last_child


func has_nodes() -> bool:
    return not nodes.empty()


func copy_for(source: Object) -> Reference:
    if self.source == source:
        return self
    
    var copy = get_script().new()
    copy.arguments = arguments
    copy.child = child
    copy.command = command
    copy.forked = forked
    copy.input = input
    copy.redirect_modifier = redirect_modifier
    copy.nodes = nodes
    copy.ranges = ranges
    copy.root_node = root_node
    copy.source = source
    return copy


func bool(name: String) -> bool:
    return get_argument(name, TYPE_BOOL) as bool


func float(name: String) -> float:
    return get_argument(name, TYPE_REAL) as float


func int(name: String) -> int:
    return get_argument(name, TYPE_INT) as int


func string(name: String) -> String:
    return get_argument(name, TYPE_STRING) as String
    
    
func vector3(name: String) -> Coordinate3:
    var result = get_argument(name, TYPE_OBJECT)
    assert(result is Coordinate3, "Argument '%s' must be definied as 'vector3'" % name)
    return result


func vector2(name: String) -> Coordinate2:
    var result = get_argument(name, TYPE_OBJECT)
    assert(result is Coordinate2, "Argument '%s' must be definied as 'vector2'" % name)
    return result


func get_argument(name: String, type: int):
    var argument = arguments.get(name)
    if not argument:
        push_error("No such argument '%s' exists on this command" % name)
        return null

    var result_type = typeof(argument.result.value)
    if result_type != type:
        var wrong = StringType.Variant[result_type]
        var correct = StringType.Variant[type]
        
        push_error("Argument '%s' is defined as '%s', not '%s'" % [name, wrong, correct])
        return null
    
    return argument.result.value


func _get_last_child() -> Reference:
    var result = self
    while result.child:
        result = result.child
    return result
