const LiteralArgumentBuilder = preload('res://addons/brigadier/main/builder/literal_argument_builder.gd')
const RequiredArgumentBuilder = preload('res://addons/brigadier/main/builder/required_argument_builder.gd')

const ArgumentType = preload('res://addons/brigadier/main/arguments/argument_type.gd')
const BoolArgumentType = preload('res://addons/brigadier/main/arguments/bool.gd')
const FloatArgumentType = preload('res://addons/brigadier/main/arguments/float.gd')
const IntArgumentType = preload('res://addons/brigadier/main/arguments/int.gd')
const StringArgumentType = preload('res://addons/brigadier/main/arguments/string.gd')
const Vector2ArgumentType = preload('res://addons/brigadier/main/arguments/vector2.gd')
const Vector3ArgumentType = preload('res://addons/brigadier/main/arguments/vector3.gd')


static func literal(name: String) -> LiteralArgumentBuilder:
    return LiteralArgumentBuilder.new(name)


static func argument(name: String, type: ArgumentType) -> RequiredArgumentBuilder:
    return RequiredArgumentBuilder.new(name, type)


static func bool() -> BoolArgumentType:
    return BoolArgumentType.new()


static func float(a := -INF, b := INF) -> FloatArgumentType:
    return FloatArgumentType.new(a, b)


static func int(a := IntArgumentType.INT_MIN, b := IntArgumentType.INT_MAX) -> IntArgumentType:
    return IntArgumentType.new(a, b)


static func word() -> StringArgumentType:
    return StringArgumentType.new(StringArgumentType.TYPE_SINGLE_WORD)


static func string() -> StringArgumentType:
    return StringArgumentType.new(StringArgumentType.TYPE_QUOTABLE_PHRASE)


static func greedy_string() -> StringArgumentType:
    return StringArgumentType.new(StringArgumentType.TYPE_GREEDY_PHRASE)


static func vector2() -> Vector2ArgumentType:
    return Vector2ArgumentType.new()


static func vector3() -> Vector3ArgumentType:
    return Vector3ArgumentType.new()
