#warning-ignore-all:shadowed_variable

extends Reference

var value setget , _get_value
var error setget , _get_error


func _init(value, error = null) -> void:
    self.value = value
    self.error = error


func _get_value():
    return value


func _get_error():
    return error 


func _to_string() -> String:
    if error:
        return 'Error{%s}' % str(error)
    else:
        return 'Result{%s}' % str(value)


static func _new(value, error):
    var script = load('res://addons/brigadier/main/result.gd')
    return script.new(value, error)


static func ok(value):
    return _new(value, null)
    
    
static func empty():
    return _new(null, null)
    
    
static func error(error):
    return _new(null, error)
