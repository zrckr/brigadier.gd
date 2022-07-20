extends Reference

var message: String setget , _get_message
var code: int setget , _get_code


func _init(message: String, code: int = FAILED) -> void:
    self.message = message
    self.code = code
    

func _get_message() -> String:
    return message


func _get_code() -> int:
    return code


func _to_string() -> String:
    return message
