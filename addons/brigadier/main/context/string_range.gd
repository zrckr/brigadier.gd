#warning-ignore-all:shadowed_variable

extends Reference

const StringReader = preload('../string_reader.gd')

const MIN := -2147483648
const MAX := 2147483647

var start: int
var end: int


func _init(_start: int, _end: int) -> void:
    start = _start
    end = _end


func get(source) -> String:
    if source is StringReader:
        source = source.string
    return source.substr(start, end - start)


func is_empty() -> bool:
    return start == end


func length() -> int:
    return end - start


func _to_string() -> String:
    return 'StringRange{start=%d, end=%d}' % [start, end]


static func between(start: int, end: int):
    var script = load('res://addons/brigadier/main/context/string_range.gd')
    return script.new(start, end)


static func at(pos: int):
    return between(pos, pos)
    
    
static func emcompassing(a: Reference, b: Reference):
    var start = min(a.start, b.start)
    var end = max(a.end, b.end)
    return between(start, end)
