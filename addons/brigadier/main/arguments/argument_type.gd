extends Reference

const Error = preload('../error.gd')
const Result = preload('../result.gd')
const StringReader = preload('../string_reader.gd')
const Suggestions = preload('../suggestion/suggestions.gd')


func parse(_reader: StringReader) -> Result:
    return Result.empty()


func list_suggestions(_context, _builder) -> Suggestions:
    return Suggestions.empty()


func get_examples() -> Array:
    return []
