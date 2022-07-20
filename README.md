# Brigadier for Godot 3.x

**Brigadier is a command parser & dispatcher, designed and developed
to provide a simple and flexible command framework.**

This is a GDScript port of [Mojang's Brigadier](https://github.com/Mojang/brigadier),
originally developled for Minecraft: Java Edition, which includes all of its features
and unit tests using [WAT](https://github.com/AlexDarigan/WAT) framework.

## Installation

Download the zip from the releases or from the Godot Asset Library.

Extract the zip and place the `addons/brigadier` directory into
root directory `res://` in your project. If you don't have an addons
folder at the root of your project, then make one
and THEN put the `addons/brigadier` directory in there.

Once the project is loaded, the `Brigadier` class will be available
with all the necessary classes from the library.

## Usage

At the heart of Brigadier, you need a `Dispatcher`.

A command dispatcher holds a "command tree", which is a series of `CommandNode`s
that represent the various possible syntax options that form a valid command.

### Registering a new command

Before we can start parsing and dispatching commands, we need to build up our command tree.
Every registration is an append operation, so you can freely extend existing commands in a project
without needing access to the source code that created them.

Command registration also encourages the use of a builder pattern to keep code cruft to a minimum.

A "command" is a fairly loose term, but typically it means an exit point of the command tree.
Every node can have an `executes` function attached to it, which signifies that if the input stops
here then this function will be called with the context so far.

Consider the following example:

```gdscript
# Define command in the pre-"Java 8" style.
class FooCommand:
    extends Brigadier.Command:

    func run(ctx: Brigadier.Context) -> int:
        prints("Called foo with no arguments")
        return OK

# Ditto
class BarCommand:
    extends Brigadier.Command

    func run(ctx: Brigadier.Context) -> int:
        prints("Bar is", ctx.int("bar"))
        return OK

...

var d = Brigadier.Dispatcher.new()
d.register(
    d.literal("foo")
        .then(d.argument("bar", d.int()) \
                .executes(BarCommand.new())) \
        .executes(FooCommand.new()) \
)
```

This snippet registers two "commands": `foo` and `foo <bar>`.
It is also common to refer to the `<bar>` as a "subcommand" of `foo`, as it's a child node.

At the start of the tree is a "root node", and it **must** have `LiteralCommandNode`s as children.
Here, we register one command under the root: `d.literal("foo")`, which means "the user must type the literal string 'foo'".

Under that is two extra definitions: a child node for possible further evaluation, or an `executes` block
if the user input stops here.

The child node works exactly the same way, but is no longer limited to literals.
The other type of node that is now allowed is an `ArgumentCommandNode` (`d.argument("bar")`),
which takes in a name, and an argument type.

Arguments can be anything, and you are encouraged to build your own for seamless integration into your own product.
There are some builtin `ArgumentType`s included, such as `d.int()` or `d.string()`.

Argument types will be asked to parse input as much as they can, and then store the "result" of that argument however
they see fit or throw a relevant error if they can't parse.

For example, an integer argument would parse "123" and store it as `123` (`int`), but throw an error if the input were `onetwothree`.

When a command function runs, it can access these arguments in the context provided to the registered function.

### Parsing user input

So, we've registered some commands, and now we're ready to take in user input.
If you're in a rush, you can just call following code and call it a day:

```gdscript
dispatcher.do("foo 123")
```

### Create context for a command

You can pass custom object via `source` argument to track users/players/etc and
will be provided to the command to give context on what's happening (e.g., who has run the command).

```gdscript
class Source:
    extends Reference

    var number: int = 42

    func add(value: int) -> value:
        number += value


class FooCommand:
    extends Brigadier.Command

    func run(ctx: Brigadier.Context) -> int:
        ctx.source.add(22)
        prints(ctx.source.number)
        return OK

...

var d = Brigadier.Dispatcher.new()
d.register(
    d.literal('foo').executes(FooCommand.new())
)

var source = Source.new()
var error = d.do('foo', source)
```

### Error handling

If the command failed or could not parse, `Error` will be returned.

```gdscript
var error = d.do('foo 123')
print(error)
```

### Parsing and execution control

If you wish to have more control over the parsing & executing of commands,
or wish to cache the parse results, so you can execute it multiple times,
you can split it up into two steps:

```gdscript
var parse = d.parse('foo 123')
var error = d.execute(parse)
```

This is highly recommended as the parse step is the most expensive,
and may be easily cached depending on your application.

You can also use this to do further introspection on a command,
before (or without) actually running it.

### Permission to execute a command

You can specify whether the user has the right to call commands,
such as those used by admins to ban or kick players.

To do this, you need to create an arbitrary class from `Requirement`
and pass it to `CommandNode` via `requires` method.

```gdscript
class DebugOnlyRequirement:
    extends Brigadier.Requirement: 

    func test(_source: Object) -> bool:
        return OS.is_debug_build()

...

var d = Brigadier.Dispatcher.new()
d.register(
    d.literal('foo') \
        .requires(DebugOnlyRequirement.new())
        .executes(...)
)

# Throws error when you call this command in Release build
var error = d.do('foo')
```

### Inspecting a command

If you `d.parse(...)` some input, you can find out what it will perform
(if anything) and provide hints to the user safely and immediately.

The parse will never fail, and the `ParseResult` it returns will contain
a *possible* context that a command may be called with (and from that,
you can inspect which nodes the user entered, complete with start/end positions
in the input string). It also contains a dictionary of parse errors for each
command node it encountered. If it couldn't build a valid context,
then the reason is inside this error dictionary.

### Displaying usage info

There are two forms of "usage strings" provided by this library,
both require a target node.

- `d.get_all_usage(node, source, restricted)`
  will return a list of all possible commands (executable end-points)
  under the target node and their human-readable path. If `restricted`,
  it will ignore commands that `ctx` does not have access to.
  This will look like [`foo`, `foo <bar>`].
  
- `d.get_smart_usage(node, source)`
  will return a map of the child nodes to their "smart usage" human-readable path.
  This tries to squash future-nodes together and show optional & typed information,
  and can look like `foo (<bar>)`.

### Suggest the completion for the input

You can provide suggestions suggestions for a parsed input string on what comes next with
`d.get_completion_suggestions()` method.

```gdscript
var parse = d.parse("foo ", source)
var suggestions = d.get_completion_suggestions(parse)
```

The suggestions provided will be in the context of the end of the parsed input string,
but may suggest new or replacement strings for earlier in the input string.
For example, if the end of the string was `foobar` but an argument preferred it
to be `brigadier:foobar`, it will suggest a replacement for that whole segment of the input.

Alse `SuggestionProvider` provides `Suggestions` and can optionally be implemented
by a `CommandNode` to add suggestions support to an command argument type.
