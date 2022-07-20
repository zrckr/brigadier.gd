extends Reference

const Coordinate = preload('./coordinate.gd')

var x: Coordinate
var y: Coordinate
var value: Vector2


func _init(_x: Coordinate, _y: Coordinate) -> void:
    value = Vector2(_x.value, _y.value)
    x = _x
    y = _y


func apply_transform(transform: Transform2D) -> Transform2D:
    var basis = [transform.x.sign(), transform.y.sign()]
    transform.origin = apply_vector(transform.origin, basis)
    return transform


func apply_vector(vector: Vector2, basis: Array) -> Vector2:
    var coords = [x, y]
    
    for i in range(2):
        if coords[i].global:
             if coords[i].relative:
                vector[i] += coords[i].value
             else:
                vector[i] = coords[i].value
        else:
            var mask = (basis[i] as Vector2).abs()
            var remain = Vector2.ONE - mask
            var value = mask * coords[i].value
            
            if coords[i].relative:
                vector += value
            else:
                vector = remain * vector + value
    
    return vector
    

func _to_string() -> String:
    return '(%s, %s)' % [x, y]


static func from(value: Vector2, global: bool = true):
    var Coordinate = load('res://addons/brigadier/main/arguments/vectors/coordinate.gd')
    var Coordinate2 = load('res://addons/brigadier/main/arguments/vectors/coordinate2.gd')
    
    var x = Coordinate.new(value.x, global, false)
    var y = Coordinate.new(value.y, global, false)
    return Coordinate2.new(x, y)
