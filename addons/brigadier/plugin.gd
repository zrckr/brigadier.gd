tool
class_name Brigadier
extends EditorPlugin

const Dispatcher = preload('./main/command_dispatcher.gd')
const Error = preload('./main/error.gd')
const ParseResult = preload('./main/parse_result.gd')
const Result = preload('./main/result.gd')
const StringReader = preload('./main/string_reader.gd')

const ArgumentType = preload('./main/arguments/argument_type.gd')
const Coordinate = preload('./main/arguments/coordinates/coordinate.gd')
const Coordinate2 = preload('./main/arguments/coordinates/coordinate2.gd')
const Coordinate3 = preload('./main/arguments/coordinates/coordinate3.gd')

const ArgumentBuilder = preload('./main/builder/argument_builder.gd')

const Context = preload('./main/context/command_context.gd')
const ContextBuilder = preload('./main/context/command_context_builder.gd')
const StringRange = preload('./main/context/string_range.gd')

const AmbiguityConsumer = preload('./main/functions/ambiguity_consumer.gd')
const Command = preload('./main/functions/command.gd')
const RedirectModifier = preload('./main/functions/redirect_modifier.gd')
const Requirement = preload('./main/functions/requirement.gd')
const ResultConsumer = preload('./main/functions/result_consumer.gd')
const SuggestionProvider = preload('./main/functions/suggestion_provider.gd')

const Suggestion = preload('./main/suggestion/suggestion.gd')
const Suggestions = preload('./main/suggestion/suggestions.gd')

const CommandNode = preload('./main/tree/command_node.gd')
