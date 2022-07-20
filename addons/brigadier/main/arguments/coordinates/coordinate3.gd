extends Reference

const Coordinate = preload('./coordinate.gd')

var x: Coordinate
var y: Coordinate
var z: Coordinate
var value: Vector3

func _init(_x: Coordinate, _y: Coordinate, _z: Coordinate) -> void:
    value = Vector3(_x.value, _y.value, _z.value)
    x = _x
    y = _y
    z = _z
    
    
func apply_transform(transform: Transform) -> Transform:
    var quat = transform.basis.get_rotation_quat()
    transform.origin = apply_vector(transform.origin, quat)
    return transform
    
    
func apply_vector(vector: Vector3, quat: Quat) -> Vector3:
    var basis = Basis(quat.normalized())  # remove scale
    var coords = [x, y, z]
    
    for i in range(3):
        if coords[i].global:
             if coords[i].relative:
                vector[i] += coords[i].value
             else:
                vector[i] = coords[i].value
        else:
            var mask = basis[i].abs()
            var remain = Vector3.ONE - mask
            var value = mask * coords[i].value
            
            if coords[i].relative:
                vector += value
            else:
                vector = remain * vector + value
    
    return vector
    
    
func _to_string() -> String:
    return '(%s, %s, %s)' % [x, y, z]
    

static func from(value: Vector3, global: bool = true):
    var Coordinate = load('res://addons/brigadier/main/arguments/vectors/coordinate.gd')
    var Coordinate3 = load('res://addons/brigadier/main/arguments/vectors/coordinate3.gd')
    
    var x = Coordinate.new(value.x, global, false)
    var y = Coordinate.new(value.y, global, false)
    var z = Coordinate.new(value.z, global, false)
    return Coordinate3.new(x, y, z)
