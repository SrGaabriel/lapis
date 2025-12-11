#!/usr/bin/env python3

import json
from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

LEAN_KEYWORDS = {
    "end",
    "where",
    "type",
    "class",
    "instance",
    "structure",
    "inductive",
    "def",
    "theorem",
    "lemma",
    "example",
    "abbrev",
    "namespace",
    "section",
    "variable",
    "universe",
    "axiom",
    "constant",
    "mutual",
    "protected",
    "private",
    "noncomputable",
    "partial",
    "unsafe",
    "match",
    "with",
    "do",
    "let",
    "have",
    "show",
    "if",
    "then",
    "else",
    "for",
    "in",
    "return",
    "break",
    "continue",
    "try",
    "catch",
    "finally",
    "throw",
    "unless",
    "when",
    "fun",
    "assume",
    "forall",
    "exists",
    "true",
    "false",
    "by",
    "from",
    "import",
    "open",
    "export",
    "set_option",
    "attribute",
    "matches",
}

BASE_TYPE_MAP = {
    "string": "String",
    "integer": "Int",
    "uinteger": "Nat",
    "decimal": "Float",
    "boolean": "Bool",
    "null": "Unit",
    "URI": "String",
    "DocumentUri": "String",
    "RegExp": "String",
}

FORCE_JSON_TYPES = {
    "LSPAny",
    "LSPObject",
    "LSPArray",
    "DocumentSelector",
    # Recursive types
    "FoldingRange",
    "SelectionRange",
    "Moniker",
    "InlayHint",
    "CompletionItem",
    "DocumentHighlight",
    "DocumentSymbol",
    "CodeAction",
    "CreateFile",
    "RenameFile",
    "DeleteFile",
    "Diagnostic",
    "FileOperationPattern",
    "NotebookCell",
    "ClientCapabilities",
    "WorkspaceClientCapabilities",
    # Proposed types that are referenced
    "InlineCompletionItem",
    "TextDocumentContentOptions",
    "InlineCompletionList",
    "InlineCompletionTriggerKind",
    "StringValue",
    "SelectedCompletionInfo",
    "CodeActionKindDocumentation",
    "SnippetTextEdit",
    "FoldingRangeWorkspaceClientCapabilities",
    "InlineCompletionParams",
    "InlineCompletionContext",
    "InlineCompletionClientCapabilities",
    "InlineCompletionOptions",
    "DocumentRangesFormattingParams",
    "TextDocumentContentParams",
    "TextDocumentContentClientCapabilities",
    "TextDocumentContentRegistrationOptions",
    "TextDocumentContentRefreshParams",
    "InlineCompletionRegistrationOptions",
    "TextDocumentContentResult",
    "WorkspaceEditMetadata",
    # Other complex types that cause issues
    "LocationLink",
    "DefinitionLink",
    "DeclarationLink",
    "TypeDefinitionLink",
    "ImplementationLink",
}


def escape_name(name: str) -> str:
    """Escape Lean keywords with French quotes."""
    if name in LEAN_KEYWORDS or (name and name[0].isdigit()):
        return f"«{name}»"
    return name


def to_lean_field_name(name: str) -> str:
    """Convert a field name to Lean style."""
    return escape_name(name)


def to_lean_type_name(name: str) -> str:
    """Convert a type name to Lean style."""
    return name


@dataclass
class GeneratorContext:
    """Context for code generation."""

    structures: dict[str, Any]
    enumerations: dict[str, Any]
    type_aliases: dict[str, Any]
    all_names: set = field(default_factory=set)


def get_type_references(typ: dict) -> set[str]:
    """Extract all type references from a type."""
    refs = set()
    kind = typ.get("kind")

    if kind == "reference":
        refs.add(typ["name"])
    elif kind == "array":
        refs.update(get_type_references(typ["element"]))
    elif kind == "map":
        refs.update(get_type_references(typ["key"]))
        refs.update(get_type_references(typ["value"]))
    elif kind in ("or", "and", "tuple"):
        for item in typ.get("items", []):
            refs.update(get_type_references(item))
    elif kind == "literal":
        for prop in typ.get("value", {}).get("properties", []):
            refs.update(get_type_references(prop["type"]))

    return refs


def type_to_lean(typ: dict, ctx: GeneratorContext, parent_name: str = "") -> str:
    """Convert an LSP type to a Lean type string."""
    kind = typ["kind"]

    if kind == "base":
        return BASE_TYPE_MAP.get(typ["name"], typ["name"])

    elif kind == "reference":
        ref_name = typ["name"]
        if ref_name in FORCE_JSON_TYPES:
            return "Json"
        # Check if it's a known type
        if ref_name not in ctx.all_names:
            return "Json"
        return to_lean_type_name(ref_name)

    elif kind == "array":
        elem_type = type_to_lean(typ["element"], ctx, parent_name)
        if elem_type == "Json":
            return "Json"
        return f"(Array {elem_type})"

    elif kind == "map":
        return "Json"

    elif kind == "or":
        items = typ["items"]
        non_null = [
            i for i in items if not (i["kind"] == "base" and i["name"] == "null")
        ]
        has_null = len(non_null) < len(items)

        if len(non_null) == 0:
            return "Unit"
        elif len(non_null) == 1:
            inner = type_to_lean(non_null[0], ctx, parent_name)
            return f"(Option {inner})" if has_null else inner
        else:
            return "Json"

    elif kind == "and":
        return "Json"

    elif kind == "tuple":
        items = typ["items"]
        if len(items) == 2:
            t1 = type_to_lean(items[0], ctx, parent_name)
            t2 = type_to_lean(items[1], ctx, parent_name)
            if t1 == "Json" or t2 == "Json":
                return "Json"
            return f"({t1} × {t2})"
        else:
            return "Json"

    elif kind == "literal":
        return "Json"

    elif kind == "stringLiteral":
        return "String"

    elif kind == "integerLiteral":
        return "Int"

    elif kind == "booleanLiteral":
        return "Bool"

    else:
        return "Json"


def topological_sort(items: list[dict], ctx: GeneratorContext, get_deps) -> list[dict]:
    """Topologically sort items based on dependencies."""
    name_to_item = {item["name"]: item for item in items}
    in_degree = {item["name"]: 0 for item in items}
    graph = defaultdict(list)

    for item in items:
        deps = get_deps(item)
        for dep in deps:
            if (
                dep in name_to_item
                and dep != item["name"]
                and dep not in FORCE_JSON_TYPES
            ):
                graph[dep].append(item["name"])
                in_degree[item["name"]] += 1

    result = []
    queue = [name for name, degree in in_degree.items() if degree == 0]

    while queue:
        name = queue.pop(0)
        result.append(name_to_item[name])
        for neighbor in graph[name]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    remaining = [
        item for item in items if item["name"] not in {r["name"] for r in result}
    ]
    result.extend(remaining)

    return result


def get_structure_deps(struct: dict) -> set[str]:
    """Get dependencies for a structure."""
    deps = set()

    for ext in struct.get("extends", []):
        deps.update(get_type_references(ext))

    for mixin in struct.get("mixins", []):
        deps.update(get_type_references(mixin))

    for prop in struct.get("properties", []):
        deps.update(get_type_references(prop["type"]))

    return deps


def generate_structure(struct: dict, ctx: GeneratorContext) -> str:
    """Generate a Lean structure from an LSP structure."""
    name = to_lean_type_name(struct["name"])
    props = struct.get("properties", [])
    extends = struct.get("extends", [])
    mixins = struct.get("mixins", [])

    lines = []

    if struct.get("documentation"):
        doc = (
            struct["documentation"]
            .replace("\n", " ")
            .replace('"', "'")
            .replace("--", "- -")
        )
        if len(doc) > 300:
            doc = doc[:300] + "..."
        lines.append(f"/-- {doc} -/")

    lines.append(f"structure {name} where")

    all_props = []

    for ext in extends:
        if ext["kind"] == "reference":
            ext_name = ext["name"]
            if ext_name in ctx.structures and ext_name not in FORCE_JSON_TYPES:
                ext_struct = ctx.structures[ext_name]
                all_props.extend(ext_struct.get("properties", []))

    for mixin in mixins:
        if mixin["kind"] == "reference":
            mixin_name = mixin["name"]
            if mixin_name in ctx.structures and mixin_name not in FORCE_JSON_TYPES:
                mixin_struct = ctx.structures[mixin_name]
                all_props.extend(mixin_struct.get("properties", []))

    all_props.extend(props)

    seen = set()
    unique_props = []
    for p in all_props:
        if p["name"] not in seen:
            seen.add(p["name"])
            unique_props.append(p)

    if not unique_props:
        lines.append("  dummy : Unit := ()")
        lines.append("  deriving Inhabited")
    else:
        for prop in unique_props:
            field_name = to_lean_field_name(prop["name"])
            field_type = type_to_lean(prop["type"], ctx, name)

            if prop.get("optional"):
                if field_type == "Json":
                    # Json fields use Json.null as default
                    default = " := Json.null"
                elif not field_type.startswith("(Option"):
                    field_type = f"(Option {field_type})"
                    default = " := none"
                else:
                    default = " := none"
            else:
                default = ""

            lines.append(f"  {field_name} : {field_type}{default}")

        lines.append("  deriving Inhabited")

    return "\n".join(lines)


def generate_tojson_instance(struct: dict, ctx: GeneratorContext) -> str:
    """Generate ToJson instance for a structure."""
    name = to_lean_type_name(struct["name"])
    extends = struct.get("extends", [])
    mixins = struct.get("mixins", [])

    all_props = []
    for ext in extends:
        if (
            ext["kind"] == "reference"
            and ext["name"] in ctx.structures
            and ext["name"] not in FORCE_JSON_TYPES
        ):
            all_props.extend(ctx.structures[ext["name"]].get("properties", []))
    for mixin in mixins:
        if (
            mixin["kind"] == "reference"
            and mixin["name"] in ctx.structures
            and mixin["name"] not in FORCE_JSON_TYPES
        ):
            all_props.extend(ctx.structures[mixin["name"]].get("properties", []))
    all_props.extend(struct.get("properties", []))

    seen = set()
    unique_props = []
    for p in all_props:
        if p["name"] not in seen:
            seen.add(p["name"])
            unique_props.append(p)

    lines = [f"instance : ToJson {name} where"]

    if not unique_props:
        lines.append("  toJson _ := Json.mkObj []")
    else:
        lines.append("  toJson s := Json.mkObj <|")
        parts = []
        for prop in unique_props:
            field_name = to_lean_field_name(prop["name"])
            json_name = prop["name"]
            field_type = type_to_lean(prop["type"], ctx, name)

            # For optional fields or Json types, handle specially
            if prop.get("optional") and field_type != "Json":
                parts.append(
                    f'    (match s.{field_name} with | some v => [("{json_name}", toJson v)] | none => [])'
                )
            else:
                parts.append(f'    [("{json_name}", toJson s.{field_name})]')

        lines.append(" ++\n".join(parts))

    return "\n".join(lines)


def generate_fromjson_instance(struct: dict, ctx: GeneratorContext) -> str:
    """Generate FromJson instance for a structure."""
    name = to_lean_type_name(struct["name"])
    extends = struct.get("extends", [])
    mixins = struct.get("mixins", [])

    all_props = []
    for ext in extends:
        if (
            ext["kind"] == "reference"
            and ext["name"] in ctx.structures
            and ext["name"] not in FORCE_JSON_TYPES
        ):
            all_props.extend(ctx.structures[ext["name"]].get("properties", []))
    for mixin in mixins:
        if (
            mixin["kind"] == "reference"
            and mixin["name"] in ctx.structures
            and mixin["name"] not in FORCE_JSON_TYPES
        ):
            all_props.extend(ctx.structures[mixin["name"]].get("properties", []))
    all_props.extend(struct.get("properties", []))

    seen = set()
    unique_props = []
    for p in all_props:
        if p["name"] not in seen:
            seen.add(p["name"])
            unique_props.append(p)

    lines = [f"instance : FromJson {name} where"]

    if not unique_props:
        lines.append(f"  fromJson? _ := return {{ dummy := () }}")
    else:
        lines.append("  fromJson? json := do")
        for prop in unique_props:
            field_name = to_lean_field_name(prop["name"])
            json_name = prop["name"]
            field_type = type_to_lean(prop["type"], ctx, name)

            if field_type == "Json":
                # For Json fields, just get the value or use null
                if prop.get("optional"):
                    lines.append(
                        f'    let {field_name} := json.getObjVal? "{json_name}" |>.toOption |>.getD Json.null'
                    )
                else:
                    lines.append(
                        f'    let {field_name} := json.getObjVal? "{json_name}" |>.toOption |>.getD Json.null'
                    )
            elif prop.get("optional"):
                if field_type.startswith("(Option"):
                    inner_type = field_type[8:-1]
                else:
                    inner_type = field_type
                lines.append(
                    f'    let {field_name} := (json.getObjValAs? {inner_type} "{json_name}").toOption'
                )
            else:
                lines.append(
                    f'    let {field_name} ← json.getObjValAs? {field_type} "{json_name}"'
                )

        field_list = ", ".join(to_lean_field_name(p["name"]) for p in unique_props)
        lines.append(f"    return {{ {field_list} }}")

    return "\n".join(lines)


def generate_enumeration(enum: dict, ctx: GeneratorContext) -> str:
    """Generate a Lean inductive type from an LSP enumeration."""
    name = to_lean_type_name(enum["name"])
    values = enum.get("values", [])

    lines = []

    if enum.get("documentation"):
        doc = (
            enum["documentation"]
            .replace("\n", " ")
            .replace('"', "'")
            .replace("--", "- -")
        )
        if len(doc) > 200:
            doc = doc[:200] + "..."
        lines.append(f"/-- {doc} -/")

    lines.append(f"inductive {name} where")

    seen_values = set()
    for val in values:
        val_name = val["name"]
        lean_name = val_name[0].lower() + val_name[1:] if val_name else val_name
        lean_name = escape_name(lean_name)

        if lean_name in seen_values:
            continue
        seen_values.add(lean_name)

        lines.append(f"  | {lean_name}")

    lines.append("  deriving Inhabited, BEq, Repr")

    return "\n".join(lines)


def generate_enum_tojson(enum: dict, ctx: GeneratorContext) -> str:
    """Generate ToJson instance for an enumeration."""
    name = to_lean_type_name(enum["name"])
    values = enum.get("values", [])
    base_type = enum["type"]["name"]

    lines = [f"instance : ToJson {name} where"]
    lines.append("  toJson")

    seen_values = set()
    for val in values:
        val_name = val["name"]
        lean_name = val_name[0].lower() + val_name[1:] if val_name else val_name
        lean_name = escape_name(lean_name)

        if lean_name in seen_values:
            continue
        seen_values.add(lean_name)

        value = val["value"]

        if base_type == "string":
            lines.append(f'    | .{lean_name} => "{value}"')
        else:
            if isinstance(value, int) and value < 0:
                lines.append(f"    | .{lean_name} => Json.num ({value})")
            else:
                lines.append(f"    | .{lean_name} => {value}")

    return "\n".join(lines)


def generate_enum_fromjson(enum: dict, ctx: GeneratorContext) -> str:
    """Generate FromJson instance for an enumeration."""
    name = to_lean_type_name(enum["name"])
    values = enum.get("values", [])
    base_type = enum["type"]["name"]

    lines = [f"instance : FromJson {name} where"]
    lines.append("  fromJson? json := do")

    seen_values = set()
    seen_match_values = set()

    if base_type == "string":
        lines.append("    let s ← json.getStr?")
        lines.append("    match s with")
        for val in values:
            val_name = val["name"]
            lean_name = val_name[0].lower() + val_name[1:] if val_name else val_name
            lean_name = escape_name(lean_name)
            value = val["value"]

            if lean_name in seen_values or value in seen_match_values:
                continue
            seen_values.add(lean_name)
            seen_match_values.add(value)

            lines.append(f'    | "{value}" => return .{lean_name}')
        lines.append(f'    | s => throw s!"Invalid {name}: {{s}}"')
    else:
        lines.append("    let n ← json.getInt?")
        lines.append("    match n with")
        for val in values:
            val_name = val["name"]
            lean_name = val_name[0].lower() + val_name[1:] if val_name else val_name
            lean_name = escape_name(lean_name)
            value = val["value"]

            if lean_name in seen_values or value in seen_match_values:
                continue
            seen_values.add(lean_name)
            seen_match_values.add(value)

            lines.append(f"    | {value} => return .{lean_name}")
        lines.append(f'    | n => throw s!"Invalid {name}: {{n}}"')

    return "\n".join(lines)


def generate_type_alias(alias: dict, ctx: GeneratorContext) -> str:
    """Generate a Lean abbreviation from an LSP type alias."""
    name = to_lean_type_name(alias["name"])

    if name in FORCE_JSON_TYPES:
        typ = "Json"
    else:
        typ = type_to_lean(alias["type"], ctx, name)

    lines = []
    if alias.get("documentation"):
        doc = (
            alias["documentation"]
            .replace("\n", " ")
            .replace('"', "'")
            .replace("--", "- -")
        )
        if len(doc) > 200:
            doc = doc[:200] + "..."
        lines.append(f"/-- {doc} -/")

    lines.append(f"abbrev {name} := {typ}")

    return "\n".join(lines)


def generate_request_method(req: dict, ctx: GeneratorContext) -> str:
    """Generate a method constant for a request."""
    method = req["method"]
    type_name = req.get("typeName", method.replace("/", "_").replace("$", "Dollar"))
    const_name = type_name.replace("/", "_").replace("$", "Dollar")

    return f'/-- Method: `{method}` -/\ndef {const_name}Method : String := "{method}"'


def generate_notification_method(notif: dict, ctx: GeneratorContext) -> str:
    """Generate a method constant for a notification."""
    method = notif["method"]
    type_name = notif.get("typeName", method.replace("/", "_").replace("$", "Dollar"))
    const_name = type_name.replace("/", "_").replace("$", "Dollar")

    return f'/-- Method: `{method}` -/\ndef {const_name}Method : String := "{method}"'


def main():
    metamodel_path = Path(__file__).parent / "metamodel.json"
    with open(metamodel_path) as f:
        metamodel = json.load(f)

    all_names = set()
    for s in metamodel["structures"]:
        if not s.get("proposed"):
            all_names.add(s["name"])
    for e in metamodel["enumerations"]:
        if not e.get("proposed"):
            all_names.add(e["name"])
    for t in metamodel["typeAliases"]:
        if not t.get("proposed"):
            all_names.add(t["name"])

    ctx = GeneratorContext(
        structures={s["name"]: s for s in metamodel["structures"]},
        enumerations={e["name"]: e for e in metamodel["enumerations"]},
        type_aliases={t["name"]: t for t in metamodel["typeAliases"]},
        all_names=all_names,
    )

    output_path = Path(__file__).parent / "Lapis" / "Protocol" / "Generated.lean"

    lines = []
    lines.append("/-")
    lines.append("  Auto-generated LSP 3.17 Protocol Types")
    lines.append("  Generated from metamodel.json - DO NOT EDIT MANUALLY")
    lines.append("-/")
    lines.append("import Lean.Data.Json")
    lines.append("")
    lines.append("namespace Lapis.Protocol.Generated")
    lines.append("")
    lines.append("open Lean Json")
    lines.append("")

    enumerations = [e for e in metamodel["enumerations"] if not e.get("proposed")]
    type_aliases = [t for t in metamodel["typeAliases"] if not t.get("proposed")]
    structures = [s for s in metamodel["structures"] if not s.get("proposed")]
    requests = [r for r in metamodel["requests"] if not r.get("proposed")]
    notifications = [n for n in metamodel["notifications"] if not n.get("proposed")]

    lines.append("/-! ## Enumerations -/")
    lines.append("")
    for enum in enumerations:
        lines.append(generate_enumeration(enum, ctx))
        lines.append("")
        lines.append(generate_enum_tojson(enum, ctx))
        lines.append("")
        lines.append(generate_enum_fromjson(enum, ctx))
        lines.append("")

    lines.append("/-! ## Type Aliases -/")
    lines.append("")
    for alias in type_aliases:
        lines.append(generate_type_alias(alias, ctx))
        lines.append("")

    sorted_structures = topological_sort(structures, ctx, get_structure_deps)

    lines.append("/-! ## Structures -/")
    lines.append("")
    for struct in sorted_structures:
        lines.append(generate_structure(struct, ctx))
        lines.append("")
        lines.append(generate_tojson_instance(struct, ctx))
        lines.append("")
        lines.append(generate_fromjson_instance(struct, ctx))
        lines.append("")

    lines.append("/-! ## Request Methods -/")
    lines.append("")
    for req in requests:
        lines.append(generate_request_method(req, ctx))
        lines.append("")

    lines.append("/-! ## Notification Methods -/")
    lines.append("")
    for notif in notifications:
        lines.append(generate_notification_method(notif, ctx))
        lines.append("")

    lines.append("end Lapis.Protocol.Generated")
    lines.append("")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write("\n".join(lines))

    print(f"Generated {output_path}")
    print(f"  - {len(enumerations)} enumerations")
    print(f"  - {len(type_aliases)} type aliases")
    print(f"  - {len(structures)} structures")
    print(f"  - {len(requests)} request methods")
    print(f"  - {len(notifications)} notification methods")


if __name__ == "__main__":
    main()
