#warning-ignore-all:shadowed_variable

extends './suggestion.gd'

var value: int


func _init(_ranged: StringRange, _value: int, _tooltip: Object = null).(_ranged, str(_value), _tooltip):
    value = _value


func _to_string():
    return 'IntegerSuggestion{value=%s, range=%s, text="%s", tooltip=%s}' % [
        value, ranges, text, tooltip
    ]
