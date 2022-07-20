extends Reference

var value: float = 0.0
var global: bool = false
var relative: bool = false


func _init(_value: float, _global: bool, _relative: bool) -> void:
    value = _value
    global = _global
    relative = _relative


func _to_string() -> String:
    var string = '%.f' % value
    if relative:
        string = '~' + string
    if global:
        string = '^' + string
    return string
