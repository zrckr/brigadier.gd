#warning-ignore-all:shadowed_variable

extends Reference

const StringRange = preload('../context/string_range.gd')
const Suggestion = preload('./suggestion.gd')

var ranges: StringRange
var suggestions: Array
    

func _init(_ranges: StringRange, _suggestions: Array) -> void:
    ranges = _ranges
    suggestions = _suggestions


func is_empty() -> bool:
    return suggestions.empty()


func _to_string() -> String:
    return 'Suggestions{range=%s, suggestions=%s]' % [ranges, suggestions]


static func _new(ranged: StringRange, suggestions: Array):
    var script = load('res://addons/brigadier/main/suggestion/suggestions.gd')
    return script.new(ranged, suggestions)


static func empty():
    return _new(StringRange.at(0), [])


static func merge(command: String, input: Array):
    if input.size() == 0:
        return empty()
    elif input.size() == 1:
        return input.front()

    var texts = []
    for suggestions in input:
        for suggestion in suggestions.suggestions:
            if not suggestion in texts:
                texts.append(suggestion)
            
    return create(command, texts)


static func create(command: String, suggestions: Array):
    if suggestions.size() == 0:
        return empty()
        
    var start = StringRange.MAX
    var end = StringRange.MIN
    
    for suggestion in suggestions:
        start = min(suggestion.ranges.start, start)
        end = max(suggestion.ranges.end, end)
        
    var ranged = StringRange.new(start, end)
    
    var texts = []
    for suggestion in suggestions:
        if not suggestion in texts:
            texts.append(suggestion.expand(command, ranged))
            
    texts.sort_custom(Suggestion, 'compare')
    return _new(ranged, texts)
