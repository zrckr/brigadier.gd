extends Reference

const AmbiguityConsumer = preload('../functions/ambiguity_consumer.gd')
const Command = preload('../functions/command.gd')
const Requirement = preload('../functions/requirement.gd')
const RedirectModifier = preload('../functions/redirect_modifier.gd')
const SuggestionProvider = preload('../functions/suggestion_provider.gd')

const CommandContext = preload('../context/command_context.gd')
const CommandContextBuilder = preload('../context/command_context_builder.gd')
const Error = preload('../error.gd')
const Result = preload('../result.gd')
const StringRange = preload('../context/string_range.gd')
const StringReader = preload('../string_reader.gd')
const Suggestions = preload('../suggestion/suggestions.gd')
const SuggestionsBuilder = preload('../suggestion/suggestions_builder.gd')

var command: Command
var requirement: Requirement
var redirect_modifier: RedirectModifier

var redirect: Reference
var forked: bool

var _arguments: Dictionary
var _children: Dictionary
var _literals: Dictionary


func _init() -> void:
    _arguments = {}
    _children = {}
    _literals = {}


func get_child(name: String) -> Reference:
    return _children.get(name)


func get_children() -> Array:
    return _children.values()


func can_use(source: Reference) -> bool:
    if requirement:
        return requirement.test(source)
    return true


func is_valid_input(_input: String) -> bool:
    assert(false, 'Not implemented')
    return false
    
    
func get_name() -> String:
    assert(false, 'Not implemented')
    return ''
    

func get_usage_text() -> String:
    assert(false, 'Not implemented')
    return ''


func parse(_reader: StringReader, _context_builder: CommandContextBuilder) -> Result:
    assert(false, 'Not implemented')
    return Result.empty()
    

func list_suggestions(_context: CommandContext, _builder: SuggestionsBuilder) -> Suggestions:
    assert(false, 'Not implemented')
    return Suggestions.empty()
    

func create_builder() -> Reference:
    assert(false, 'Not implemented')
    return null
    
    
func get_sorted_key() -> String:
    assert(false, 'Not implemented')
    return ''


func get_examples() -> Array:
    assert(false, 'Not implemented')
    return []


func add_child(node: Reference) -> void:
    var ArgumentCommandNode = load('res://addons/brigadier/main/tree/argument_command_node.gd')
    var LiteralCommandNode = load('res://addons/brigadier/main/tree/literal_command_node.gd')
    var RootCommandNode = load('res://addons/brigadier/main/tree/root_command_node.gd')
    
    if node is RootCommandNode:
        push_error('Cannot add a RootCommandNode as a child to any other CommandNode')
        return
    
    var child = _children.get(node.get_name())
    if child:
        # We've found something to merge onto
        if node.command:
            child.command = node.command
        
        for grandchild in node.get_children():
            child.add_child(grandchild)
    else:
        _children[node.get_name()] = node
        if node is LiteralCommandNode:
            _literals[node.get_name()] = node
        elif node is ArgumentCommandNode:
            _arguments[node.get_name()] = node


func find_ambiguities(consumer: AmbiguityConsumer):
    var matches = []
    
    for child in _children.values():
        for sibling in _children.values():
            if child == sibling:
                continue
            
            for input in child.get_examples():
                if sibling.is_valid_input(input) and not input in matches:
                    matches.add(input)
                    
                if matches.size() > 0:
                    consumer.ambiguous(self, child, sibling, matches)
                    matches.clear()
        
        child.find_ambiguities(consumer)


func get_relevant_nodes(input: StringReader) -> Array:
    if _literals.size() <= 0:
        return _arguments.values()
        
    var cursor = input.cursor
    while input.can_read() and input.peek() != ord(' '):
        input.skip()
        
    var text = input.string.substr(cursor, input.cursor - cursor)
    input.cursor = cursor
    
    var literal = _literals.get(text)
    if literal:
        return [literal]
    else:
        return _arguments.values()
