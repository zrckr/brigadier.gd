extends './argument_type.gd'

enum {
    TYPE_SINGLE_WORD,
    TYPE_QUOTABLE_PHRASE,
    TYPE_GREEDY_PHRASE,
}

const EXAMPLES := {
    TYPE_SINGLE_WORD: ["word", "words_with_underscores"],
    TYPE_QUOTABLE_PHRASE: ["\"quoted phrase\"", "word", "\"\""],
    TYPE_GREEDY_PHRASE: ["word", "words with spaces", "\"and symbols\""]
}


var _type: int = -1


func _init(type: int) -> void:
    _type = type


func parse(reader: StringReader) -> Result:
    match _type:
        TYPE_GREEDY_PHRASE:
            var text = reader.remaining
            reader.cursor = reader.string.length()
            return Result.ok(text)

        TYPE_SINGLE_WORD:
            return reader.read_unquoted_string()

        TYPE_QUOTABLE_PHRASE:
            return reader.read_string()

    return Result.empty()


func get_examples() -> Array:
    return EXAMPLES[_type]


func _to_string() -> String:
    return "string()"
