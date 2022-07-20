#warning-ignore-all:shadowed_variable

extends Reference

const IntegerSuggestion = preload('./integer_suggestion.gd')
const StringRange = preload('../context/string_range.gd')
const Suggestion = preload('./suggestion.gd')
const Suggestions = preload('./suggestions.gd')

var input: String
var input_lower: String
var remaining: String
var remaining_lower: String
var result: Array
var start: int


func _init(_input: String, _input_lower: String, _start: int) -> void:
    result = []
    start = _start
    input = _input
    input_lower = _input_lower
    remaining = _input.substr(_start)
    remaining_lower = _input_lower.substr(_start)


func build() -> Suggestions:
    return Suggestions.create(input, result)


func suggest(value, tooltip: Object = null):
    var ranged = StringRange.between(start, len(input))
    var suggestion = null
    
    match typeof(value):
        TYPE_INT:
            suggestion = IntegerSuggestion.new(ranged, value, tooltip)
        TYPE_STRING:
            if remaining == value:
                return self
            else:
                suggestion = Suggestion.new(ranged, value, tooltip)
            
    result.append(suggestion)
    return self


func add(suggestions: Reference) -> Reference:
    result.append_array(suggestions.result)
    return self


func create_offset(start: int) -> Reference:
    return get_script().new(input, input_lower, start)


func restart() -> Reference:
    return create_offset(start)
