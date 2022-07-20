#warning-ignore-all:shadowed_variable

extends Reference

const StringRange = preload('../context/string_range.gd')

var ranges: StringRange
var text: String
var tooltip: Object


func _init(_ranges: StringRange, _text: String, _tooltip: Object = null) -> void:
    ranges = _ranges
    text = _text
    tooltip = _tooltip


func apply(input: String) -> String:
    if ranges.start == 0 and ranges.end == len(input):
        return text
        
    var result = ''
    if ranges.start > 0:
        result += input.substr(0, ranges.start)
        
    result += text
    if ranges.end < input.length():
        result += input.substr(ranges.end)
        
    return result


func expand(command: String, ranges: StringRange) -> Reference:
    if ranges.start == self.ranges.start and ranges.end == self.ranges.end:
        return self
        
    var result = ''
    if ranges.start < self.ranges.start:
        result += command.substr(ranges.start, self.ranges.start - ranges.start)
        
    result += text
    if ranges.end > self.ranges.end:
        result += command.substr(self.ranges.end, ranges.end - self.ranges.end)

    return get_script().new(ranges, result, tooltip)


func _to_string() -> String:
    return 'Suggestion{range=%s, text="%s", tooltip=%s}' % [ranges, text, tooltip]


static func compare(a: Reference, b: Reference) -> bool:
    var a_upper = a.text.to_upper()
    var b_upper = b.text.to_upper()
    return a_upper.naturalnocasecmp_to(b_upper) < 0
