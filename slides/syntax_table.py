"""Canonical syntax reference snippets for TODO / FC slides.

Each entry is a short, generic, reusable code example that shows a GDScript
syntax pattern without referencing the specific solution. The same snippet is
displayed every time that concept appears, regardless of which TODO uses it.

SLIDE_SOURCE.md G13 slides reference these via:
    - Syntax: key1, key2, key3

Entries are joined with a blank line and rendered verbatim on the LHS (SYNTAX)
panel. Add new entries here; reference them by key in SLIDE_SOURCE.md.
"""

SYNTAX = {
    # ── Variable declaration ─────────────────────────────────────────────
    "var":       "var name := value",
    "bool":      "var flag := true",
    "const":     "const NAME := value",

    # ── Control flow ─────────────────────────────────────────────────────
    "if":        "if condition:\n    do_this",
    "if_else":   "if condition:\n    do_this\nelse:\n    do_that",
    "or":        "if a or b:\n    do_this",
    "return":    "return",

    # ── Assignment / arithmetic ───────────────────────────────────────────
    "plus_eq":   "x += amount",
    "minus_eq":  "x -= amount",
    "negate":    "x = -x",

    # ── Object property access ────────────────────────────────────────────
    "dot":       "object.property",
    "dot_eq":    "object.property += amount",

    # ── Built-in functions ────────────────────────────────────────────────
    "print":     'print("message")',
    "str":       "str(number)",
    "str_join":  '"label: " + str(number)',
    "func_call": "function_name()",

    # ── Misc ──────────────────────────────────────────────────────────────
    "comment":   "# this is a comment",
    "input_key": "Input.is_key_pressed(KEY_X)",

    # ── D2: Loops ─────────────────────────────────────────────────────────
    "for_range":   "for i in range(N):\n    do_something(i)",
    "for_in":      "for item in collection:\n    do_something(item)",
    "while_loop":  "var n := 0\nwhile n < limit:\n    do_something()\n    n += 1",

    # ── D2: Functions ─────────────────────────────────────────────────────
    "func_void":   "func name() -> void:\n    do_something()",
    "func_param":  "func name(param):\n    use(param)",
    "func_return": "func name(param) -> ReturnType:\n    return value",

    # ── D3: Lists ─────────────────────────────────────────────────────────
    "list_init":   "var items: Array = []",
    "list_append": "items.append(item)",
    "list_erase":  "items.erase(item)",
    "list_size":   "items.size()",
    "list_index":  "items[i]",

    # ── D3: match (state dispatch) ────────────────────────────────────────
    "match_stmt":  "match value:\n    \"case_a\":\n        do_a()\n    \"case_b\":\n        do_b()",

    # ── D4: Objects / instantiate ─────────────────────────────────────────
    "instantiate": "var node := SCENE.instantiate()\nadd_child(node)\nnode.setup(args)",
}
