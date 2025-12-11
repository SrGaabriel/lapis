/-
  Auto-generated LSP 3.17 Protocol Types
  Generated from metamodel.json - DO NOT EDIT MANUALLY
-/
import Lean.Data.Json

namespace Lapis.Protocol.Generated

open Lean Json

/-! ## Enumerations -/

/-- A set of predefined token types. This set is not fixed an clients can specify additional token types via the corresponding client capabilities.  @since 3.16.0 -/
inductive SemanticTokenTypes where
  | «namespace»
  | «type»
  | «class»
  | enum
  | interface
  | struct
  | typeParameter
  | parameter
  | «variable»
  | property
  | enumMember
  | event
  | function
  | method
  | macro
  | keyword
  | modifier
  | comment
  | string
  | number
  | regexp
  | operator
  | decorator
  | label
  deriving Inhabited, BEq, Repr

instance : ToJson SemanticTokenTypes where
  toJson
    | .«namespace» => "namespace"
    | .«type» => "type"
    | .«class» => "class"
    | .enum => "enum"
    | .interface => "interface"
    | .struct => "struct"
    | .typeParameter => "typeParameter"
    | .parameter => "parameter"
    | .«variable» => "variable"
    | .property => "property"
    | .enumMember => "enumMember"
    | .event => "event"
    | .function => "function"
    | .method => "method"
    | .macro => "macro"
    | .keyword => "keyword"
    | .modifier => "modifier"
    | .comment => "comment"
    | .string => "string"
    | .number => "number"
    | .regexp => "regexp"
    | .operator => "operator"
    | .decorator => "decorator"
    | .label => "label"

instance : FromJson SemanticTokenTypes where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "namespace" => return .«namespace»
    | "type" => return .«type»
    | "class" => return .«class»
    | "enum" => return .enum
    | "interface" => return .interface
    | "struct" => return .struct
    | "typeParameter" => return .typeParameter
    | "parameter" => return .parameter
    | "variable" => return .«variable»
    | "property" => return .property
    | "enumMember" => return .enumMember
    | "event" => return .event
    | "function" => return .function
    | "method" => return .method
    | "macro" => return .macro
    | "keyword" => return .keyword
    | "modifier" => return .modifier
    | "comment" => return .comment
    | "string" => return .string
    | "number" => return .number
    | "regexp" => return .regexp
    | "operator" => return .operator
    | "decorator" => return .decorator
    | "label" => return .label
    | s => throw s!"Invalid SemanticTokenTypes: {s}"

/-- A set of predefined token modifiers. This set is not fixed an clients can specify additional token types via the corresponding client capabilities.  @since 3.16.0 -/
inductive SemanticTokenModifiers where
  | declaration
  | definition
  | readonly
  | static
  | deprecated
  | abstract
  | async
  | modification
  | documentation
  | defaultLibrary
  deriving Inhabited, BEq, Repr

instance : ToJson SemanticTokenModifiers where
  toJson
    | .declaration => "declaration"
    | .definition => "definition"
    | .readonly => "readonly"
    | .static => "static"
    | .deprecated => "deprecated"
    | .abstract => "abstract"
    | .async => "async"
    | .modification => "modification"
    | .documentation => "documentation"
    | .defaultLibrary => "defaultLibrary"

instance : FromJson SemanticTokenModifiers where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "declaration" => return .declaration
    | "definition" => return .definition
    | "readonly" => return .readonly
    | "static" => return .static
    | "deprecated" => return .deprecated
    | "abstract" => return .abstract
    | "async" => return .async
    | "modification" => return .modification
    | "documentation" => return .documentation
    | "defaultLibrary" => return .defaultLibrary
    | s => throw s!"Invalid SemanticTokenModifiers: {s}"

/-- The document diagnostic report kinds.  @since 3.17.0 -/
inductive DocumentDiagnosticReportKind where
  | full
  | unchanged
  deriving Inhabited, BEq, Repr

instance : ToJson DocumentDiagnosticReportKind where
  toJson
    | .full => "full"
    | .unchanged => "unchanged"

instance : FromJson DocumentDiagnosticReportKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "full" => return .full
    | "unchanged" => return .unchanged
    | s => throw s!"Invalid DocumentDiagnosticReportKind: {s}"

/-- Predefined error codes. -/
inductive ErrorCodes where
  | parseError
  | invalidRequest
  | methodNotFound
  | invalidParams
  | internalError
  | serverNotInitialized
  | unknownErrorCode
  deriving Inhabited, BEq, Repr

instance : ToJson ErrorCodes where
  toJson
    | .parseError => Json.num (-32700)
    | .invalidRequest => Json.num (-32600)
    | .methodNotFound => Json.num (-32601)
    | .invalidParams => Json.num (-32602)
    | .internalError => Json.num (-32603)
    | .serverNotInitialized => Json.num (-32002)
    | .unknownErrorCode => Json.num (-32001)

instance : FromJson ErrorCodes where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | -32700 => return .parseError
    | -32600 => return .invalidRequest
    | -32601 => return .methodNotFound
    | -32602 => return .invalidParams
    | -32603 => return .internalError
    | -32002 => return .serverNotInitialized
    | -32001 => return .unknownErrorCode
    | n => throw s!"Invalid ErrorCodes: {n}"

inductive LSPErrorCodes where
  | requestFailed
  | serverCancelled
  | contentModified
  | requestCancelled
  deriving Inhabited, BEq, Repr

instance : ToJson LSPErrorCodes where
  toJson
    | .requestFailed => Json.num (-32803)
    | .serverCancelled => Json.num (-32802)
    | .contentModified => Json.num (-32801)
    | .requestCancelled => Json.num (-32800)

instance : FromJson LSPErrorCodes where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | -32803 => return .requestFailed
    | -32802 => return .serverCancelled
    | -32801 => return .contentModified
    | -32800 => return .requestCancelled
    | n => throw s!"Invalid LSPErrorCodes: {n}"

/-- A set of predefined range kinds. -/
inductive FoldingRangeKind where
  | comment
  | imports
  | region
  deriving Inhabited, BEq, Repr

instance : ToJson FoldingRangeKind where
  toJson
    | .comment => "comment"
    | .imports => "imports"
    | .region => "region"

instance : FromJson FoldingRangeKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "comment" => return .comment
    | "imports" => return .imports
    | "region" => return .region
    | s => throw s!"Invalid FoldingRangeKind: {s}"

/-- A symbol kind. -/
inductive SymbolKind where
  | file
  | module
  | «namespace»
  | package
  | «class»
  | method
  | property
  | field
  | constructor
  | enum
  | interface
  | function
  | «variable»
  | «constant»
  | string
  | number
  | boolean
  | array
  | object
  | key
  | null
  | enumMember
  | struct
  | event
  | operator
  | typeParameter
  deriving Inhabited, BEq, Repr

instance : ToJson SymbolKind where
  toJson
    | .file => 1
    | .module => 2
    | .«namespace» => 3
    | .package => 4
    | .«class» => 5
    | .method => 6
    | .property => 7
    | .field => 8
    | .constructor => 9
    | .enum => 10
    | .interface => 11
    | .function => 12
    | .«variable» => 13
    | .«constant» => 14
    | .string => 15
    | .number => 16
    | .boolean => 17
    | .array => 18
    | .object => 19
    | .key => 20
    | .null => 21
    | .enumMember => 22
    | .struct => 23
    | .event => 24
    | .operator => 25
    | .typeParameter => 26

instance : FromJson SymbolKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .file
    | 2 => return .module
    | 3 => return .«namespace»
    | 4 => return .package
    | 5 => return .«class»
    | 6 => return .method
    | 7 => return .property
    | 8 => return .field
    | 9 => return .constructor
    | 10 => return .enum
    | 11 => return .interface
    | 12 => return .function
    | 13 => return .«variable»
    | 14 => return .«constant»
    | 15 => return .string
    | 16 => return .number
    | 17 => return .boolean
    | 18 => return .array
    | 19 => return .object
    | 20 => return .key
    | 21 => return .null
    | 22 => return .enumMember
    | 23 => return .struct
    | 24 => return .event
    | 25 => return .operator
    | 26 => return .typeParameter
    | n => throw s!"Invalid SymbolKind: {n}"

/-- Symbol tags are extra annotations that tweak the rendering of a symbol.  @since 3.16 -/
inductive SymbolTag where
  | deprecated
  deriving Inhabited, BEq, Repr

instance : ToJson SymbolTag where
  toJson
    | .deprecated => 1

instance : FromJson SymbolTag where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .deprecated
    | n => throw s!"Invalid SymbolTag: {n}"

/-- Moniker uniqueness level to define scope of the moniker.  @since 3.16.0 -/
inductive UniquenessLevel where
  | document
  | project
  | group
  | scheme
  | global
  deriving Inhabited, BEq, Repr

instance : ToJson UniquenessLevel where
  toJson
    | .document => "document"
    | .project => "project"
    | .group => "group"
    | .scheme => "scheme"
    | .global => "global"

instance : FromJson UniquenessLevel where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "document" => return .document
    | "project" => return .project
    | "group" => return .group
    | "scheme" => return .scheme
    | "global" => return .global
    | s => throw s!"Invalid UniquenessLevel: {s}"

/-- The moniker kind.  @since 3.16.0 -/
inductive MonikerKind where
  | «import»
  | «export»
  | local
  deriving Inhabited, BEq, Repr

instance : ToJson MonikerKind where
  toJson
    | .«import» => "import"
    | .«export» => "export"
    | .local => "local"

instance : FromJson MonikerKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "import" => return .«import»
    | "export" => return .«export»
    | "local" => return .local
    | s => throw s!"Invalid MonikerKind: {s}"

/-- Inlay hint kinds.  @since 3.17.0 -/
inductive InlayHintKind where
  | «type»
  | parameter
  deriving Inhabited, BEq, Repr

instance : ToJson InlayHintKind where
  toJson
    | .«type» => 1
    | .parameter => 2

instance : FromJson InlayHintKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .«type»
    | 2 => return .parameter
    | n => throw s!"Invalid InlayHintKind: {n}"

/-- The message type -/
inductive MessageType where
  | error
  | warning
  | info
  | log
  | debug
  deriving Inhabited, BEq, Repr

instance : ToJson MessageType where
  toJson
    | .error => 1
    | .warning => 2
    | .info => 3
    | .log => 4
    | .debug => 5

instance : FromJson MessageType where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .error
    | 2 => return .warning
    | 3 => return .info
    | 4 => return .log
    | 5 => return .debug
    | n => throw s!"Invalid MessageType: {n}"

/-- Defines how the host (editor) should sync document changes to the language server. -/
inductive TextDocumentSyncKind where
  | none
  | full
  | incremental
  deriving Inhabited, BEq, Repr

instance : ToJson TextDocumentSyncKind where
  toJson
    | .none => 0
    | .full => 1
    | .incremental => 2

instance : FromJson TextDocumentSyncKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 0 => return .none
    | 1 => return .full
    | 2 => return .incremental
    | n => throw s!"Invalid TextDocumentSyncKind: {n}"

/-- Represents reasons why a text document is saved. -/
inductive TextDocumentSaveReason where
  | manual
  | afterDelay
  | focusOut
  deriving Inhabited, BEq, Repr

instance : ToJson TextDocumentSaveReason where
  toJson
    | .manual => 1
    | .afterDelay => 2
    | .focusOut => 3

instance : FromJson TextDocumentSaveReason where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .manual
    | 2 => return .afterDelay
    | 3 => return .focusOut
    | n => throw s!"Invalid TextDocumentSaveReason: {n}"

/-- The kind of a completion entry. -/
inductive CompletionItemKind where
  | text
  | method
  | function
  | constructor
  | field
  | «variable»
  | «class»
  | interface
  | module
  | property
  | unit
  | value
  | enum
  | keyword
  | snippet
  | color
  | file
  | reference
  | folder
  | enumMember
  | «constant»
  | struct
  | event
  | operator
  | typeParameter
  deriving Inhabited, BEq, Repr

instance : ToJson CompletionItemKind where
  toJson
    | .text => 1
    | .method => 2
    | .function => 3
    | .constructor => 4
    | .field => 5
    | .«variable» => 6
    | .«class» => 7
    | .interface => 8
    | .module => 9
    | .property => 10
    | .unit => 11
    | .value => 12
    | .enum => 13
    | .keyword => 14
    | .snippet => 15
    | .color => 16
    | .file => 17
    | .reference => 18
    | .folder => 19
    | .enumMember => 20
    | .«constant» => 21
    | .struct => 22
    | .event => 23
    | .operator => 24
    | .typeParameter => 25

instance : FromJson CompletionItemKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .text
    | 2 => return .method
    | 3 => return .function
    | 4 => return .constructor
    | 5 => return .field
    | 6 => return .«variable»
    | 7 => return .«class»
    | 8 => return .interface
    | 9 => return .module
    | 10 => return .property
    | 11 => return .unit
    | 12 => return .value
    | 13 => return .enum
    | 14 => return .keyword
    | 15 => return .snippet
    | 16 => return .color
    | 17 => return .file
    | 18 => return .reference
    | 19 => return .folder
    | 20 => return .enumMember
    | 21 => return .«constant»
    | 22 => return .struct
    | 23 => return .event
    | 24 => return .operator
    | 25 => return .typeParameter
    | n => throw s!"Invalid CompletionItemKind: {n}"

/-- Completion item tags are extra annotations that tweak the rendering of a completion item.  @since 3.15.0 -/
inductive CompletionItemTag where
  | deprecated
  deriving Inhabited, BEq, Repr

instance : ToJson CompletionItemTag where
  toJson
    | .deprecated => 1

instance : FromJson CompletionItemTag where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .deprecated
    | n => throw s!"Invalid CompletionItemTag: {n}"

/-- Defines whether the insert text in a completion item should be interpreted as plain text or a snippet. -/
inductive InsertTextFormat where
  | plainText
  | snippet
  deriving Inhabited, BEq, Repr

instance : ToJson InsertTextFormat where
  toJson
    | .plainText => 1
    | .snippet => 2

instance : FromJson InsertTextFormat where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .plainText
    | 2 => return .snippet
    | n => throw s!"Invalid InsertTextFormat: {n}"

/-- How whitespace and indentation is handled during completion item insertion.  @since 3.16.0 -/
inductive InsertTextMode where
  | asIs
  | adjustIndentation
  deriving Inhabited, BEq, Repr

instance : ToJson InsertTextMode where
  toJson
    | .asIs => 1
    | .adjustIndentation => 2

instance : FromJson InsertTextMode where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .asIs
    | 2 => return .adjustIndentation
    | n => throw s!"Invalid InsertTextMode: {n}"

/-- A document highlight kind. -/
inductive DocumentHighlightKind where
  | text
  | read
  | write
  deriving Inhabited, BEq, Repr

instance : ToJson DocumentHighlightKind where
  toJson
    | .text => 1
    | .read => 2
    | .write => 3

instance : FromJson DocumentHighlightKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .text
    | 2 => return .read
    | 3 => return .write
    | n => throw s!"Invalid DocumentHighlightKind: {n}"

/-- A set of predefined code action kinds -/
inductive CodeActionKind where
  | empty
  | quickFix
  | refactor
  | refactorExtract
  | refactorInline
  | refactorMove
  | refactorRewrite
  | source
  | sourceOrganizeImports
  | sourceFixAll
  | notebook
  deriving Inhabited, BEq, Repr

instance : ToJson CodeActionKind where
  toJson
    | .empty => ""
    | .quickFix => "quickfix"
    | .refactor => "refactor"
    | .refactorExtract => "refactor.extract"
    | .refactorInline => "refactor.inline"
    | .refactorMove => "refactor.move"
    | .refactorRewrite => "refactor.rewrite"
    | .source => "source"
    | .sourceOrganizeImports => "source.organizeImports"
    | .sourceFixAll => "source.fixAll"
    | .notebook => "notebook"

instance : FromJson CodeActionKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "" => return .empty
    | "quickfix" => return .quickFix
    | "refactor" => return .refactor
    | "refactor.extract" => return .refactorExtract
    | "refactor.inline" => return .refactorInline
    | "refactor.move" => return .refactorMove
    | "refactor.rewrite" => return .refactorRewrite
    | "source" => return .source
    | "source.organizeImports" => return .sourceOrganizeImports
    | "source.fixAll" => return .sourceFixAll
    | "notebook" => return .notebook
    | s => throw s!"Invalid CodeActionKind: {s}"

/-- Code action tags are extra annotations that tweak the behavior of a code action.  @since 3.18.0 - proposed -/
inductive CodeActionTag where
  | lLMGenerated
  deriving Inhabited, BEq, Repr

instance : ToJson CodeActionTag where
  toJson
    | .lLMGenerated => 1

instance : FromJson CodeActionTag where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .lLMGenerated
    | n => throw s!"Invalid CodeActionTag: {n}"

inductive TraceValue where
  | off
  | messages
  | verbose
  deriving Inhabited, BEq, Repr

instance : ToJson TraceValue where
  toJson
    | .off => "off"
    | .messages => "messages"
    | .verbose => "verbose"

instance : FromJson TraceValue where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "off" => return .off
    | "messages" => return .messages
    | "verbose" => return .verbose
    | s => throw s!"Invalid TraceValue: {s}"

/-- Describes the content type that a client supports in various result literals like `Hover`, `ParameterInfo` or `CompletionItem`.  Please note that `MarkupKinds` must not start with a `$`. This kinds ar... -/
inductive MarkupKind where
  | plainText
  | markdown
  deriving Inhabited, BEq, Repr

instance : ToJson MarkupKind where
  toJson
    | .plainText => "plaintext"
    | .markdown => "markdown"

instance : FromJson MarkupKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "plaintext" => return .plainText
    | "markdown" => return .markdown
    | s => throw s!"Invalid MarkupKind: {s}"

/-- Predefined Language kinds @since 3.18.0 -/
inductive LanguageKind where
  | aBAP
  | windowsBat
  | bibTeX
  | clojure
  | coffeescript
  | c
  | cPP
  | cSharp
  | cSS
  | d
  | delphi
  | diff
  | dart
  | dockerfile
  | elixir
  | erlang
  | fSharp
  | gitCommit
  | gitRebase
  | go
  | groovy
  | handlebars
  | haskell
  | hTML
  | ini
  | java
  | javaScript
  | javaScriptReact
  | jSON
  | laTeX
  | less
  | lua
  | makefile
  | markdown
  | objectiveC
  | objectiveCPP
  | pascal
  | perl
  | perl6
  | pHP
  | powershell
  | pug
  | python
  | r
  | razor
  | ruby
  | rust
  | sCSS
  | sASS
  | scala
  | shaderLab
  | shellScript
  | sQL
  | swift
  | typeScript
  | typeScriptReact
  | teX
  | visualBasic
  | xML
  | xSL
  | yAML
  deriving Inhabited, BEq, Repr

instance : ToJson LanguageKind where
  toJson
    | .aBAP => "abap"
    | .windowsBat => "bat"
    | .bibTeX => "bibtex"
    | .clojure => "clojure"
    | .coffeescript => "coffeescript"
    | .c => "c"
    | .cPP => "cpp"
    | .cSharp => "csharp"
    | .cSS => "css"
    | .d => "d"
    | .delphi => "pascal"
    | .diff => "diff"
    | .dart => "dart"
    | .dockerfile => "dockerfile"
    | .elixir => "elixir"
    | .erlang => "erlang"
    | .fSharp => "fsharp"
    | .gitCommit => "git-commit"
    | .gitRebase => "rebase"
    | .go => "go"
    | .groovy => "groovy"
    | .handlebars => "handlebars"
    | .haskell => "haskell"
    | .hTML => "html"
    | .ini => "ini"
    | .java => "java"
    | .javaScript => "javascript"
    | .javaScriptReact => "javascriptreact"
    | .jSON => "json"
    | .laTeX => "latex"
    | .less => "less"
    | .lua => "lua"
    | .makefile => "makefile"
    | .markdown => "markdown"
    | .objectiveC => "objective-c"
    | .objectiveCPP => "objective-cpp"
    | .pascal => "pascal"
    | .perl => "perl"
    | .perl6 => "perl6"
    | .pHP => "php"
    | .powershell => "powershell"
    | .pug => "jade"
    | .python => "python"
    | .r => "r"
    | .razor => "razor"
    | .ruby => "ruby"
    | .rust => "rust"
    | .sCSS => "scss"
    | .sASS => "sass"
    | .scala => "scala"
    | .shaderLab => "shaderlab"
    | .shellScript => "shellscript"
    | .sQL => "sql"
    | .swift => "swift"
    | .typeScript => "typescript"
    | .typeScriptReact => "typescriptreact"
    | .teX => "tex"
    | .visualBasic => "vb"
    | .xML => "xml"
    | .xSL => "xsl"
    | .yAML => "yaml"

instance : FromJson LanguageKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "abap" => return .aBAP
    | "bat" => return .windowsBat
    | "bibtex" => return .bibTeX
    | "clojure" => return .clojure
    | "coffeescript" => return .coffeescript
    | "c" => return .c
    | "cpp" => return .cPP
    | "csharp" => return .cSharp
    | "css" => return .cSS
    | "d" => return .d
    | "pascal" => return .delphi
    | "diff" => return .diff
    | "dart" => return .dart
    | "dockerfile" => return .dockerfile
    | "elixir" => return .elixir
    | "erlang" => return .erlang
    | "fsharp" => return .fSharp
    | "git-commit" => return .gitCommit
    | "rebase" => return .gitRebase
    | "go" => return .go
    | "groovy" => return .groovy
    | "handlebars" => return .handlebars
    | "haskell" => return .haskell
    | "html" => return .hTML
    | "ini" => return .ini
    | "java" => return .java
    | "javascript" => return .javaScript
    | "javascriptreact" => return .javaScriptReact
    | "json" => return .jSON
    | "latex" => return .laTeX
    | "less" => return .less
    | "lua" => return .lua
    | "makefile" => return .makefile
    | "markdown" => return .markdown
    | "objective-c" => return .objectiveC
    | "objective-cpp" => return .objectiveCPP
    | "perl" => return .perl
    | "perl6" => return .perl6
    | "php" => return .pHP
    | "powershell" => return .powershell
    | "jade" => return .pug
    | "python" => return .python
    | "r" => return .r
    | "razor" => return .razor
    | "ruby" => return .ruby
    | "rust" => return .rust
    | "scss" => return .sCSS
    | "sass" => return .sASS
    | "scala" => return .scala
    | "shaderlab" => return .shaderLab
    | "shellscript" => return .shellScript
    | "sql" => return .sQL
    | "swift" => return .swift
    | "typescript" => return .typeScript
    | "typescriptreact" => return .typeScriptReact
    | "tex" => return .teX
    | "vb" => return .visualBasic
    | "xml" => return .xML
    | "xsl" => return .xSL
    | "yaml" => return .yAML
    | s => throw s!"Invalid LanguageKind: {s}"

/-- A set of predefined position encoding kinds.  @since 3.17.0 -/
inductive PositionEncodingKind where
  | uTF8
  | uTF16
  | uTF32
  deriving Inhabited, BEq, Repr

instance : ToJson PositionEncodingKind where
  toJson
    | .uTF8 => "utf-8"
    | .uTF16 => "utf-16"
    | .uTF32 => "utf-32"

instance : FromJson PositionEncodingKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "utf-8" => return .uTF8
    | "utf-16" => return .uTF16
    | "utf-32" => return .uTF32
    | s => throw s!"Invalid PositionEncodingKind: {s}"

/-- The file event type -/
inductive FileChangeType where
  | created
  | changed
  | deleted
  deriving Inhabited, BEq, Repr

instance : ToJson FileChangeType where
  toJson
    | .created => 1
    | .changed => 2
    | .deleted => 3

instance : FromJson FileChangeType where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .created
    | 2 => return .changed
    | 3 => return .deleted
    | n => throw s!"Invalid FileChangeType: {n}"

inductive WatchKind where
  | create
  | change
  | delete
  deriving Inhabited, BEq, Repr

instance : ToJson WatchKind where
  toJson
    | .create => 1
    | .change => 2
    | .delete => 4

instance : FromJson WatchKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .create
    | 2 => return .change
    | 4 => return .delete
    | n => throw s!"Invalid WatchKind: {n}"

/-- The diagnostic's severity. -/
inductive DiagnosticSeverity where
  | error
  | warning
  | information
  | hint
  deriving Inhabited, BEq, Repr

instance : ToJson DiagnosticSeverity where
  toJson
    | .error => 1
    | .warning => 2
    | .information => 3
    | .hint => 4

instance : FromJson DiagnosticSeverity where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .error
    | 2 => return .warning
    | 3 => return .information
    | 4 => return .hint
    | n => throw s!"Invalid DiagnosticSeverity: {n}"

/-- The diagnostic tags.  @since 3.15.0 -/
inductive DiagnosticTag where
  | unnecessary
  | deprecated
  deriving Inhabited, BEq, Repr

instance : ToJson DiagnosticTag where
  toJson
    | .unnecessary => 1
    | .deprecated => 2

instance : FromJson DiagnosticTag where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .unnecessary
    | 2 => return .deprecated
    | n => throw s!"Invalid DiagnosticTag: {n}"

/-- How a completion was triggered -/
inductive CompletionTriggerKind where
  | invoked
  | triggerCharacter
  | triggerForIncompleteCompletions
  deriving Inhabited, BEq, Repr

instance : ToJson CompletionTriggerKind where
  toJson
    | .invoked => 1
    | .triggerCharacter => 2
    | .triggerForIncompleteCompletions => 3

instance : FromJson CompletionTriggerKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .invoked
    | 2 => return .triggerCharacter
    | 3 => return .triggerForIncompleteCompletions
    | n => throw s!"Invalid CompletionTriggerKind: {n}"

/-- Defines how values from a set of defaults and an individual item will be merged.  @since 3.18.0 -/
inductive ApplyKind where
  | replace
  | merge
  deriving Inhabited, BEq, Repr

instance : ToJson ApplyKind where
  toJson
    | .replace => 1
    | .merge => 2

instance : FromJson ApplyKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .replace
    | 2 => return .merge
    | n => throw s!"Invalid ApplyKind: {n}"

/-- How a signature help was triggered.  @since 3.15.0 -/
inductive SignatureHelpTriggerKind where
  | invoked
  | triggerCharacter
  | contentChange
  deriving Inhabited, BEq, Repr

instance : ToJson SignatureHelpTriggerKind where
  toJson
    | .invoked => 1
    | .triggerCharacter => 2
    | .contentChange => 3

instance : FromJson SignatureHelpTriggerKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .invoked
    | 2 => return .triggerCharacter
    | 3 => return .contentChange
    | n => throw s!"Invalid SignatureHelpTriggerKind: {n}"

/-- The reason why code actions were requested.  @since 3.17.0 -/
inductive CodeActionTriggerKind where
  | invoked
  | automatic
  deriving Inhabited, BEq, Repr

instance : ToJson CodeActionTriggerKind where
  toJson
    | .invoked => 1
    | .automatic => 2

instance : FromJson CodeActionTriggerKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .invoked
    | 2 => return .automatic
    | n => throw s!"Invalid CodeActionTriggerKind: {n}"

/-- A pattern kind describing if a glob pattern matches a file a folder or both.  @since 3.16.0 -/
inductive FileOperationPatternKind where
  | file
  | folder
  deriving Inhabited, BEq, Repr

instance : ToJson FileOperationPatternKind where
  toJson
    | .file => "file"
    | .folder => "folder"

instance : FromJson FileOperationPatternKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "file" => return .file
    | "folder" => return .folder
    | s => throw s!"Invalid FileOperationPatternKind: {s}"

/-- A notebook cell kind.  @since 3.17.0 -/
inductive NotebookCellKind where
  | markup
  | code
  deriving Inhabited, BEq, Repr

instance : ToJson NotebookCellKind where
  toJson
    | .markup => 1
    | .code => 2

instance : FromJson NotebookCellKind where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .markup
    | 2 => return .code
    | n => throw s!"Invalid NotebookCellKind: {n}"

inductive ResourceOperationKind where
  | create
  | rename
  | delete
  deriving Inhabited, BEq, Repr

instance : ToJson ResourceOperationKind where
  toJson
    | .create => "create"
    | .rename => "rename"
    | .delete => "delete"

instance : FromJson ResourceOperationKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "create" => return .create
    | "rename" => return .rename
    | "delete" => return .delete
    | s => throw s!"Invalid ResourceOperationKind: {s}"

inductive FailureHandlingKind where
  | abort
  | transactional
  | textOnlyTransactional
  | undo
  deriving Inhabited, BEq, Repr

instance : ToJson FailureHandlingKind where
  toJson
    | .abort => "abort"
    | .transactional => "transactional"
    | .textOnlyTransactional => "textOnlyTransactional"
    | .undo => "undo"

instance : FromJson FailureHandlingKind where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "abort" => return .abort
    | "transactional" => return .transactional
    | "textOnlyTransactional" => return .textOnlyTransactional
    | "undo" => return .undo
    | s => throw s!"Invalid FailureHandlingKind: {s}"

inductive PrepareSupportDefaultBehavior where
  | identifier
  deriving Inhabited, BEq, Repr

instance : ToJson PrepareSupportDefaultBehavior where
  toJson
    | .identifier => 1

instance : FromJson PrepareSupportDefaultBehavior where
  fromJson? json := do
    let n ← json.getInt?
    match n with
    | 1 => return .identifier
    | n => throw s!"Invalid PrepareSupportDefaultBehavior: {n}"

inductive TokenFormat where
  | relative
  deriving Inhabited, BEq, Repr

instance : ToJson TokenFormat where
  toJson
    | .relative => "relative"

instance : FromJson TokenFormat where
  fromJson? json := do
    let s ← json.getStr?
    match s with
    | "relative" => return .relative
    | s => throw s!"Invalid TokenFormat: {s}"

/-! ## Type Aliases -/

/-- The definition of a symbol represented as one or many {@link Location locations}. For most programming languages there is only one location at which a symbol is defined.  Servers should prefer returni... -/
abbrev Definition := Json

/-- Information about where a symbol is defined.  Provides additional metadata over normal {@link Location location} definitions, including the range of the defining symbol -/
abbrev DefinitionLink := Json

/-- LSP arrays. @since 3.17.0 -/
abbrev LSPArray := Json

/-- The LSP any type. Please note that strictly speaking a property with the value `undefined` can't be converted into JSON preserving the property name. However for convenience it is allowed and assumed ... -/
abbrev LSPAny := Json

/-- The declaration of a symbol representation as one or many {@link Location locations}. -/
abbrev Declaration := Json

/-- Information about where a symbol is declared.  Provides additional metadata over normal {@link Location location} declarations, including the range of the declaring symbol.  Servers should prefer retu... -/
abbrev DeclarationLink := Json

/-- Inline value information can be provided by different means: - directly as a text value (class InlineValueText). - as a name to use for a variable lookup (class InlineValueVariableLookup) - as an eval... -/
abbrev InlineValue := Json

/-- The result of a document diagnostic pull request. A report can either be a full report containing all diagnostics for the requested document or an unchanged report indicating that nothing has changed ... -/
abbrev DocumentDiagnosticReport := Json

abbrev PrepareRenameResult := Json

/-- A document selector is the combination of one or many document filters.  @sample `let sel:DocumentSelector = [{ language: 'typescript' }, { language: 'json', pattern: '**∕tsconfig.json' }]`;  The use ... -/
abbrev DocumentSelector := Json

abbrev ProgressToken := Json

/-- An identifier to refer to a change annotation stored with a workspace edit. -/
abbrev ChangeAnnotationIdentifier := String

/-- A workspace diagnostic document report.  @since 3.17.0 -/
abbrev WorkspaceDocumentDiagnosticReport := Json

/-- An event describing a change to a text document. If only a text is provided it is considered to be the full content of the document. -/
abbrev TextDocumentContentChangeEvent := Json

/-- MarkedString can be used to render human readable text. It is either a markdown string or a code-block that provides a language and a code snippet. The language identifier is semantically equal to the... -/
abbrev MarkedString := Json

/-- A document filter describes a top level text document or a notebook cell document.  @since 3.17.0 - support for NotebookCellTextDocumentFilter. -/
abbrev DocumentFilter := Json

/-- LSP object definition. @since 3.17.0 -/
abbrev LSPObject := Json

/-- The glob pattern. Either a string pattern or a relative pattern.  @since 3.17.0 -/
abbrev GlobPattern := Json

/-- A document filter denotes a document by different properties like the {@link TextDocument.languageId language}, the {@link Uri.scheme scheme} of its resource, or a glob-pattern that is applied to the ... -/
abbrev TextDocumentFilter := Json

/-- A notebook document filter denotes a notebook document by different properties. The properties will be match against the notebook's URI (same as with documents)  @since 3.17.0 -/
abbrev NotebookDocumentFilter := Json

/-- The glob pattern to watch relative to the base path. Glob patterns can have the following syntax: - `*` to match one or more characters in a path segment - `?` to match on one character in a path segm... -/
abbrev Pattern := String

abbrev RegularExpressionEngineKind := String

/-! ## Structures -/

/-- A workspace folder inside a client. -/
structure WorkspaceFolder where
  uri : String
  name : String
  deriving Inhabited

instance : ToJson WorkspaceFolder where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("name", toJson s.name)]

instance : FromJson WorkspaceFolder where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let name ← json.getObjValAs? String "name"
    return { uri, name }

structure WorkDoneProgressOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson WorkDoneProgressOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson WorkDoneProgressOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- General text document registration options. -/
structure TextDocumentRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson TextDocumentRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson TextDocumentRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Represents a folding range. To be valid, start and end line must be bigger than zero and smaller than the number of lines in the document. Clients are free to ignore invalid ranges. -/
structure FoldingRange where
  startLine : Nat
  startCharacter : (Option Nat) := none
  endLine : Nat
  endCharacter : (Option Nat) := none
  kind : (Option FoldingRangeKind) := none
  collapsedText : (Option String) := none
  deriving Inhabited

instance : ToJson FoldingRange where
  toJson s := Json.mkObj <|
    [("startLine", toJson s.startLine)] ++
    (match s.startCharacter with | some v => [("startCharacter", toJson v)] | none => []) ++
    [("endLine", toJson s.endLine)] ++
    (match s.endCharacter with | some v => [("endCharacter", toJson v)] | none => []) ++
    (match s.kind with | some v => [("kind", toJson v)] | none => []) ++
    (match s.collapsedText with | some v => [("collapsedText", toJson v)] | none => [])

instance : FromJson FoldingRange where
  fromJson? json := do
    let startLine ← json.getObjValAs? Nat "startLine"
    let startCharacter := (json.getObjValAs? Nat "startCharacter").toOption
    let endLine ← json.getObjValAs? Nat "endLine"
    let endCharacter := (json.getObjValAs? Nat "endCharacter").toOption
    let kind := (json.getObjValAs? FoldingRangeKind "kind").toOption
    let collapsedText := (json.getObjValAs? String "collapsedText").toOption
    return { startLine, startCharacter, endLine, endCharacter, kind, collapsedText }

structure WorkDoneProgressCreateParams where
  token : ProgressToken
  deriving Inhabited

instance : ToJson WorkDoneProgressCreateParams where
  toJson s := Json.mkObj <|
    [("token", toJson s.token)]

instance : FromJson WorkDoneProgressCreateParams where
  fromJson? json := do
    let token ← json.getObjValAs? ProgressToken "token"
    return { token }

structure WorkDoneProgressCancelParams where
  token : ProgressToken
  deriving Inhabited

instance : ToJson WorkDoneProgressCancelParams where
  toJson s := Json.mkObj <|
    [("token", toJson s.token)]

instance : FromJson WorkDoneProgressCancelParams where
  fromJson? json := do
    let token ← json.getObjValAs? ProgressToken "token"
    return { token }

/-- @since 3.16.0 -/
structure SemanticTokens where
  resultId : (Option String) := none
  data : (Array Nat)
  deriving Inhabited

instance : ToJson SemanticTokens where
  toJson s := Json.mkObj <|
    (match s.resultId with | some v => [("resultId", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson SemanticTokens where
  fromJson? json := do
    let resultId := (json.getObjValAs? String "resultId").toOption
    let data ← json.getObjValAs? (Array Nat) "data"
    return { resultId, data }

/-- @since 3.16.0 -/
structure SemanticTokensPartialResult where
  data : (Array Nat)
  deriving Inhabited

instance : ToJson SemanticTokensPartialResult where
  toJson s := Json.mkObj <|
    [("data", toJson s.data)]

instance : FromJson SemanticTokensPartialResult where
  fromJson? json := do
    let data ← json.getObjValAs? (Array Nat) "data"
    return { data }

/-- The result of a showDocument request.  @since 3.16.0 -/
structure ShowDocumentResult where
  success : Bool
  deriving Inhabited

instance : ToJson ShowDocumentResult where
  toJson s := Json.mkObj <|
    [("success", toJson s.success)]

instance : FromJson ShowDocumentResult where
  fromJson? json := do
    let success ← json.getObjValAs? Bool "success"
    return { success }

/-- Moniker definition to match LSIF 0.5 moniker definition.  @since 3.16.0 -/
structure Moniker where
  scheme : String
  identifier : String
  unique : UniquenessLevel
  kind : (Option MonikerKind) := none
  deriving Inhabited

instance : ToJson Moniker where
  toJson s := Json.mkObj <|
    [("scheme", toJson s.scheme)] ++
    [("identifier", toJson s.identifier)] ++
    [("unique", toJson s.unique)] ++
    (match s.kind with | some v => [("kind", toJson v)] | none => [])

instance : FromJson Moniker where
  fromJson? json := do
    let scheme ← json.getObjValAs? String "scheme"
    let identifier ← json.getObjValAs? String "identifier"
    let unique ← json.getObjValAs? UniquenessLevel "unique"
    let kind := (json.getObjValAs? MonikerKind "kind").toOption
    return { scheme, identifier, unique, kind }

/-- Cancellation data returned from a diagnostic request.  @since 3.17.0 -/
structure DiagnosticServerCancellationData where
  retriggerRequest : Bool
  deriving Inhabited

instance : ToJson DiagnosticServerCancellationData where
  toJson s := Json.mkObj <|
    [("retriggerRequest", toJson s.retriggerRequest)]

instance : FromJson DiagnosticServerCancellationData where
  fromJson? json := do
    let retriggerRequest ← json.getObjValAs? Bool "retriggerRequest"
    return { retriggerRequest }

/-- A workspace diagnostic report.  @since 3.17.0 -/
structure WorkspaceDiagnosticReport where
  items : (Array WorkspaceDocumentDiagnosticReport)
  deriving Inhabited

instance : ToJson WorkspaceDiagnosticReport where
  toJson s := Json.mkObj <|
    [("items", toJson s.items)]

instance : FromJson WorkspaceDiagnosticReport where
  fromJson? json := do
    let items ← json.getObjValAs? (Array WorkspaceDocumentDiagnosticReport) "items"
    return { items }

/-- A partial result for a workspace diagnostic report.  @since 3.17.0 -/
structure WorkspaceDiagnosticReportPartialResult where
  items : (Array WorkspaceDocumentDiagnosticReport)
  deriving Inhabited

instance : ToJson WorkspaceDiagnosticReportPartialResult where
  toJson s := Json.mkObj <|
    [("items", toJson s.items)]

instance : FromJson WorkspaceDiagnosticReportPartialResult where
  fromJson? json := do
    let items ← json.getObjValAs? (Array WorkspaceDocumentDiagnosticReport) "items"
    return { items }

/-- The data type of the ResponseError if the initialize request fails. -/
structure InitializeError where
  retry : Bool
  deriving Inhabited

instance : ToJson InitializeError where
  toJson s := Json.mkObj <|
    [("retry", toJson s.retry)]

instance : FromJson InitializeError where
  fromJson? json := do
    let retry ← json.getObjValAs? Bool "retry"
    return { retry }

structure InitializedParams where
  dummy : Unit := ()
  deriving Inhabited

instance : ToJson InitializedParams where
  toJson _ := Json.mkObj []

instance : FromJson InitializedParams where
  fromJson? _ := return { dummy := () }

/-- The parameters of a change configuration notification. -/
structure DidChangeConfigurationParams where
  settings : Json
  deriving Inhabited

instance : ToJson DidChangeConfigurationParams where
  toJson s := Json.mkObj <|
    [("settings", toJson s.settings)]

instance : FromJson DidChangeConfigurationParams where
  fromJson? json := do
    let settings := json.getObjVal? "settings" |>.toOption |>.getD Json.null
    return { settings }

structure DidChangeConfigurationRegistrationOptions where
  «section» : Json := Json.null
  deriving Inhabited

instance : ToJson DidChangeConfigurationRegistrationOptions where
  toJson s := Json.mkObj <|
    [("section", toJson s.«section»)]

instance : FromJson DidChangeConfigurationRegistrationOptions where
  fromJson? json := do
    let «section» := json.getObjVal? "section" |>.toOption |>.getD Json.null
    return { «section» }

/-- The parameters of a notification message. -/
structure ShowMessageParams where
  «type» : MessageType
  message : String
  deriving Inhabited

instance : ToJson ShowMessageParams where
  toJson s := Json.mkObj <|
    [("type", toJson s.«type»)] ++
    [("message", toJson s.message)]

instance : FromJson ShowMessageParams where
  fromJson? json := do
    let «type» ← json.getObjValAs? MessageType "type"
    let message ← json.getObjValAs? String "message"
    return { «type», message }

structure MessageActionItem where
  title : String
  deriving Inhabited

instance : ToJson MessageActionItem where
  toJson s := Json.mkObj <|
    [("title", toJson s.title)]

instance : FromJson MessageActionItem where
  fromJson? json := do
    let title ← json.getObjValAs? String "title"
    return { title }

/-- The log message parameters. -/
structure LogMessageParams where
  «type» : MessageType
  message : String
  deriving Inhabited

instance : ToJson LogMessageParams where
  toJson s := Json.mkObj <|
    [("type", toJson s.«type»)] ++
    [("message", toJson s.message)]

instance : FromJson LogMessageParams where
  fromJson? json := do
    let «type» ← json.getObjValAs? MessageType "type"
    let message ← json.getObjValAs? String "message"
    return { «type», message }

/-- The publish diagnostic notification's parameters. -/
structure PublishDiagnosticsParams where
  uri : String
  version : (Option Int) := none
  diagnostics : Json
  deriving Inhabited

instance : ToJson PublishDiagnosticsParams where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    (match s.version with | some v => [("version", toJson v)] | none => []) ++
    [("diagnostics", toJson s.diagnostics)]

instance : FromJson PublishDiagnosticsParams where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let version := (json.getObjValAs? Int "version").toOption
    let diagnostics := json.getObjVal? "diagnostics" |>.toOption |>.getD Json.null
    return { uri, version, diagnostics }

/-- Represents a reference to a command. Provides a title which will be used to represent a command in the UI and, optionally, an array of arguments which will be passed to the command handler function when invoked. -/
structure Command where
  title : String
  tooltip : (Option String) := none
  command : String
  arguments : Json := Json.null
  deriving Inhabited

instance : ToJson Command where
  toJson s := Json.mkObj <|
    [("title", toJson s.title)] ++
    (match s.tooltip with | some v => [("tooltip", toJson v)] | none => []) ++
    [("command", toJson s.command)] ++
    [("arguments", toJson s.arguments)]

instance : FromJson Command where
  fromJson? json := do
    let title ← json.getObjValAs? String "title"
    let tooltip := (json.getObjValAs? String "tooltip").toOption
    let command ← json.getObjValAs? String "command"
    let arguments := json.getObjVal? "arguments" |>.toOption |>.getD Json.null
    return { title, tooltip, command, arguments }

/-- The result returned from the apply workspace edit request.  @since 3.17 renamed from ApplyWorkspaceEditResponse -/
structure ApplyWorkspaceEditResult where
  applied : Bool
  failureReason : (Option String) := none
  failedChange : (Option Nat) := none
  deriving Inhabited

instance : ToJson ApplyWorkspaceEditResult where
  toJson s := Json.mkObj <|
    [("applied", toJson s.applied)] ++
    (match s.failureReason with | some v => [("failureReason", toJson v)] | none => []) ++
    (match s.failedChange with | some v => [("failedChange", toJson v)] | none => [])

instance : FromJson ApplyWorkspaceEditResult where
  fromJson? json := do
    let applied ← json.getObjValAs? Bool "applied"
    let failureReason := (json.getObjValAs? String "failureReason").toOption
    let failedChange := (json.getObjValAs? Nat "failedChange").toOption
    return { applied, failureReason, failedChange }

structure WorkDoneProgressBegin where
  kind : String
  title : String
  cancellable : (Option Bool) := none
  message : (Option String) := none
  percentage : (Option Nat) := none
  deriving Inhabited

instance : ToJson WorkDoneProgressBegin where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    [("title", toJson s.title)] ++
    (match s.cancellable with | some v => [("cancellable", toJson v)] | none => []) ++
    (match s.message with | some v => [("message", toJson v)] | none => []) ++
    (match s.percentage with | some v => [("percentage", toJson v)] | none => [])

instance : FromJson WorkDoneProgressBegin where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let title ← json.getObjValAs? String "title"
    let cancellable := (json.getObjValAs? Bool "cancellable").toOption
    let message := (json.getObjValAs? String "message").toOption
    let percentage := (json.getObjValAs? Nat "percentage").toOption
    return { kind, title, cancellable, message, percentage }

structure WorkDoneProgressReport where
  kind : String
  cancellable : (Option Bool) := none
  message : (Option String) := none
  percentage : (Option Nat) := none
  deriving Inhabited

instance : ToJson WorkDoneProgressReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.cancellable with | some v => [("cancellable", toJson v)] | none => []) ++
    (match s.message with | some v => [("message", toJson v)] | none => []) ++
    (match s.percentage with | some v => [("percentage", toJson v)] | none => [])

instance : FromJson WorkDoneProgressReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let cancellable := (json.getObjValAs? Bool "cancellable").toOption
    let message := (json.getObjValAs? String "message").toOption
    let percentage := (json.getObjValAs? Nat "percentage").toOption
    return { kind, cancellable, message, percentage }

structure WorkDoneProgressEnd where
  kind : String
  message : (Option String) := none
  deriving Inhabited

instance : ToJson WorkDoneProgressEnd where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.message with | some v => [("message", toJson v)] | none => [])

instance : FromJson WorkDoneProgressEnd where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let message := (json.getObjValAs? String "message").toOption
    return { kind, message }

structure SetTraceParams where
  value : TraceValue
  deriving Inhabited

instance : ToJson SetTraceParams where
  toJson s := Json.mkObj <|
    [("value", toJson s.value)]

instance : FromJson SetTraceParams where
  fromJson? json := do
    let value ← json.getObjValAs? TraceValue "value"
    return { value }

structure LogTraceParams where
  message : String
  verbose : (Option String) := none
  deriving Inhabited

instance : ToJson LogTraceParams where
  toJson s := Json.mkObj <|
    [("message", toJson s.message)] ++
    (match s.verbose with | some v => [("verbose", toJson v)] | none => [])

instance : FromJson LogTraceParams where
  fromJson? json := do
    let message ← json.getObjValAs? String "message"
    let verbose := (json.getObjValAs? String "verbose").toOption
    return { message, verbose }

structure CancelParams where
  id : Json
  deriving Inhabited

instance : ToJson CancelParams where
  toJson s := Json.mkObj <|
    [("id", toJson s.id)]

instance : FromJson CancelParams where
  fromJson? json := do
    let id := json.getObjVal? "id" |>.toOption |>.getD Json.null
    return { id }

structure ProgressParams where
  token : ProgressToken
  value : Json
  deriving Inhabited

instance : ToJson ProgressParams where
  toJson s := Json.mkObj <|
    [("token", toJson s.token)] ++
    [("value", toJson s.value)]

instance : FromJson ProgressParams where
  fromJson? json := do
    let token ← json.getObjValAs? ProgressToken "token"
    let value := json.getObjVal? "value" |>.toOption |>.getD Json.null
    return { token, value }

structure WorkDoneProgressParams where
  workDoneToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson WorkDoneProgressParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => [])

instance : FromJson WorkDoneProgressParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    return { workDoneToken }

structure PartialResultParams where
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson PartialResultParams where
  toJson s := Json.mkObj <|
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson PartialResultParams where
  fromJson? json := do
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { partialResultToken }

/-- Static registration options to be returned in the initialize request. -/
structure StaticRegistrationOptions where
  id : (Option String) := none
  deriving Inhabited

instance : ToJson StaticRegistrationOptions where
  toJson s := Json.mkObj <|
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson StaticRegistrationOptions where
  fromJson? json := do
    let id := (json.getObjValAs? String "id").toOption
    return { id }

structure ConfigurationItem where
  scopeUri : (Option String) := none
  «section» : (Option String) := none
  deriving Inhabited

instance : ToJson ConfigurationItem where
  toJson s := Json.mkObj <|
    (match s.scopeUri with | some v => [("scopeUri", toJson v)] | none => []) ++
    (match s.«section» with | some v => [("section", toJson v)] | none => [])

instance : FromJson ConfigurationItem where
  fromJson? json := do
    let scopeUri := (json.getObjValAs? String "scopeUri").toOption
    let «section» := (json.getObjValAs? String "section").toOption
    return { scopeUri, «section» }

/-- A literal to identify a text document in the client. -/
structure TextDocumentIdentifier where
  uri : String
  deriving Inhabited

instance : ToJson TextDocumentIdentifier where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)]

instance : FromJson TextDocumentIdentifier where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    return { uri }

/-- Represents a color in RGBA space. -/
structure Color where
  red : Float
  green : Float
  blue : Float
  alpha : Float
  deriving Inhabited

instance : ToJson Color where
  toJson s := Json.mkObj <|
    [("red", toJson s.red)] ++
    [("green", toJson s.green)] ++
    [("blue", toJson s.blue)] ++
    [("alpha", toJson s.alpha)]

instance : FromJson Color where
  fromJson? json := do
    let red ← json.getObjValAs? Float "red"
    let green ← json.getObjValAs? Float "green"
    let blue ← json.getObjValAs? Float "blue"
    let alpha ← json.getObjValAs? Float "alpha"
    return { red, green, blue, alpha }

/-- Position in a text document expressed as zero-based line and character offset. Prior to 3.17 the offsets were always based on a UTF-16 string representation. So a string of the form `a𐐀b` the character offset of the character `a` is 0, the character offset of `𐐀` is 1 and the character offset of b i... -/
structure Position where
  line : Nat
  character : Nat
  deriving Inhabited

instance : ToJson Position where
  toJson s := Json.mkObj <|
    [("line", toJson s.line)] ++
    [("character", toJson s.character)]

instance : FromJson Position where
  fromJson? json := do
    let line ← json.getObjValAs? Nat "line"
    let character ← json.getObjValAs? Nat "character"
    return { line, character }

/-- @since 3.16.0 -/
structure SemanticTokensEdit where
  start : Nat
  deleteCount : Nat
  data : (Option (Array Nat)) := none
  deriving Inhabited

instance : ToJson SemanticTokensEdit where
  toJson s := Json.mkObj <|
    [("start", toJson s.start)] ++
    [("deleteCount", toJson s.deleteCount)] ++
    (match s.data with | some v => [("data", toJson v)] | none => [])

instance : FromJson SemanticTokensEdit where
  fromJson? json := do
    let start ← json.getObjValAs? Nat "start"
    let deleteCount ← json.getObjValAs? Nat "deleteCount"
    let data := (json.getObjValAs? (Array Nat) "data").toOption
    return { start, deleteCount, data }

/-- Represents information on a file/folder create.  @since 3.16.0 -/
structure FileCreate where
  uri : String
  deriving Inhabited

instance : ToJson FileCreate where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)]

instance : FromJson FileCreate where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    return { uri }

/-- Additional information that describes document changes.  @since 3.16.0 -/
structure ChangeAnnotation where
  label : String
  needsConfirmation : (Option Bool) := none
  description : (Option String) := none
  deriving Inhabited

instance : ToJson ChangeAnnotation where
  toJson s := Json.mkObj <|
    [("label", toJson s.label)] ++
    (match s.needsConfirmation with | some v => [("needsConfirmation", toJson v)] | none => []) ++
    (match s.description with | some v => [("description", toJson v)] | none => [])

instance : FromJson ChangeAnnotation where
  fromJson? json := do
    let label ← json.getObjValAs? String "label"
    let needsConfirmation := (json.getObjValAs? Bool "needsConfirmation").toOption
    let description := (json.getObjValAs? String "description").toOption
    return { label, needsConfirmation, description }

/-- A filter to describe in which file operation requests or notifications the server is interested in receiving.  @since 3.16.0 -/
structure FileOperationFilter where
  scheme : (Option String) := none
  pattern : Json
  deriving Inhabited

instance : ToJson FileOperationFilter where
  toJson s := Json.mkObj <|
    (match s.scheme with | some v => [("scheme", toJson v)] | none => []) ++
    [("pattern", toJson s.pattern)]

instance : FromJson FileOperationFilter where
  fromJson? json := do
    let scheme := (json.getObjValAs? String "scheme").toOption
    let pattern := json.getObjVal? "pattern" |>.toOption |>.getD Json.null
    return { scheme, pattern }

/-- Represents information on a file/folder rename.  @since 3.16.0 -/
structure FileRename where
  oldUri : String
  newUri : String
  deriving Inhabited

instance : ToJson FileRename where
  toJson s := Json.mkObj <|
    [("oldUri", toJson s.oldUri)] ++
    [("newUri", toJson s.newUri)]

instance : FromJson FileRename where
  fromJson? json := do
    let oldUri ← json.getObjValAs? String "oldUri"
    let newUri ← json.getObjValAs? String "newUri"
    return { oldUri, newUri }

/-- Represents information on a file/folder delete.  @since 3.16.0 -/
structure FileDelete where
  uri : String
  deriving Inhabited

instance : ToJson FileDelete where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)]

instance : FromJson FileDelete where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    return { uri }

/-- A `MarkupContent` literal represents a string value which content is interpreted base on its kind flag. Currently the protocol supports `plaintext` and `markdown` as markup kinds.  If the kind is `markdown` then the value can contain fenced code blocks like in GitHub issues. See https://help.github.... -/
structure MarkupContent where
  kind : MarkupKind
  value : String
  deriving Inhabited

instance : ToJson MarkupContent where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    [("value", toJson s.value)]

instance : FromJson MarkupContent where
  fromJson? json := do
    let kind ← json.getObjValAs? MarkupKind "kind"
    let value ← json.getObjValAs? String "value"
    return { kind, value }

/-- A diagnostic report with a full set of problems.  @since 3.17.0 -/
structure FullDocumentDiagnosticReport where
  kind : String
  resultId : (Option String) := none
  items : Json
  deriving Inhabited

instance : ToJson FullDocumentDiagnosticReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.resultId with | some v => [("resultId", toJson v)] | none => []) ++
    [("items", toJson s.items)]

instance : FromJson FullDocumentDiagnosticReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let resultId := (json.getObjValAs? String "resultId").toOption
    let items := json.getObjVal? "items" |>.toOption |>.getD Json.null
    return { kind, resultId, items }

/-- A diagnostic report indicating that the last returned report is still accurate.  @since 3.17.0 -/
structure UnchangedDocumentDiagnosticReport where
  kind : String
  resultId : String
  deriving Inhabited

instance : ToJson UnchangedDocumentDiagnosticReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    [("resultId", toJson s.resultId)]

instance : FromJson UnchangedDocumentDiagnosticReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let resultId ← json.getObjValAs? String "resultId"
    return { kind, resultId }

/-- A previous result id in a workspace pull request.  @since 3.17.0 -/
structure PreviousResultId where
  uri : String
  value : String
  deriving Inhabited

instance : ToJson PreviousResultId where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("value", toJson s.value)]

instance : FromJson PreviousResultId where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let value ← json.getObjValAs? String "value"
    return { uri, value }

/-- A notebook document.  @since 3.17.0 -/
structure NotebookDocument where
  uri : String
  notebookType : String
  version : Int
  metadata : Json := Json.null
  cells : Json
  deriving Inhabited

instance : ToJson NotebookDocument where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("notebookType", toJson s.notebookType)] ++
    [("version", toJson s.version)] ++
    [("metadata", toJson s.metadata)] ++
    [("cells", toJson s.cells)]

instance : FromJson NotebookDocument where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let notebookType ← json.getObjValAs? String "notebookType"
    let version ← json.getObjValAs? Int "version"
    let metadata := json.getObjVal? "metadata" |>.toOption |>.getD Json.null
    let cells := json.getObjVal? "cells" |>.toOption |>.getD Json.null
    return { uri, notebookType, version, metadata, cells }

/-- An item to transfer a text document from the client to the server. -/
structure TextDocumentItem where
  uri : String
  languageId : LanguageKind
  version : Int
  text : String
  deriving Inhabited

instance : ToJson TextDocumentItem where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("languageId", toJson s.languageId)] ++
    [("version", toJson s.version)] ++
    [("text", toJson s.text)]

instance : FromJson TextDocumentItem where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let languageId ← json.getObjValAs? LanguageKind "languageId"
    let version ← json.getObjValAs? Int "version"
    let text ← json.getObjValAs? String "text"
    return { uri, languageId, version, text }

/-- A versioned notebook document identifier.  @since 3.17.0 -/
structure VersionedNotebookDocumentIdentifier where
  version : Int
  uri : String
  deriving Inhabited

instance : ToJson VersionedNotebookDocumentIdentifier where
  toJson s := Json.mkObj <|
    [("version", toJson s.version)] ++
    [("uri", toJson s.uri)]

instance : FromJson VersionedNotebookDocumentIdentifier where
  fromJson? json := do
    let version ← json.getObjValAs? Int "version"
    let uri ← json.getObjValAs? String "uri"
    return { version, uri }

/-- A literal to identify a notebook document in the client.  @since 3.17.0 -/
structure NotebookDocumentIdentifier where
  uri : String
  deriving Inhabited

instance : ToJson NotebookDocumentIdentifier where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)]

instance : FromJson NotebookDocumentIdentifier where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    return { uri }

/-- General parameters to register for a notification or to register a provider. -/
structure Registration where
  id : String
  method : String
  registerOptions : Json := Json.null
  deriving Inhabited

instance : ToJson Registration where
  toJson s := Json.mkObj <|
    [("id", toJson s.id)] ++
    [("method", toJson s.method)] ++
    [("registerOptions", toJson s.registerOptions)]

instance : FromJson Registration where
  fromJson? json := do
    let id ← json.getObjValAs? String "id"
    let method ← json.getObjValAs? String "method"
    let registerOptions := json.getObjVal? "registerOptions" |>.toOption |>.getD Json.null
    return { id, method, registerOptions }

/-- General parameters to unregister a request or notification. -/
structure Unregistration where
  id : String
  method : String
  deriving Inhabited

instance : ToJson Unregistration where
  toJson s := Json.mkObj <|
    [("id", toJson s.id)] ++
    [("method", toJson s.method)]

instance : FromJson Unregistration where
  fromJson? json := do
    let id ← json.getObjValAs? String "id"
    let method ← json.getObjValAs? String "method"
    return { id, method }

/-- Information about the server  @since 3.15.0 @since 3.18.0 ServerInfo type name added. -/
structure ServerInfo where
  name : String
  version : (Option String) := none
  deriving Inhabited

instance : ToJson ServerInfo where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    (match s.version with | some v => [("version", toJson v)] | none => [])

instance : FromJson ServerInfo where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let version := (json.getObjValAs? String "version").toOption
    return { name, version }

/-- Save options. -/
structure SaveOptions where
  includeText : (Option Bool) := none
  deriving Inhabited

instance : ToJson SaveOptions where
  toJson s := Json.mkObj <|
    (match s.includeText with | some v => [("includeText", toJson v)] | none => [])

instance : FromJson SaveOptions where
  fromJson? json := do
    let includeText := (json.getObjValAs? Bool "includeText").toOption
    return { includeText }

/-- An event describing a file change. -/
structure FileEvent where
  uri : String
  «type» : FileChangeType
  deriving Inhabited

instance : ToJson FileEvent where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("type", toJson s.«type»)]

instance : FromJson FileEvent where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let «type» ← json.getObjValAs? FileChangeType "type"
    return { uri, «type» }

structure FileSystemWatcher where
  globPattern : GlobPattern
  kind : (Option WatchKind) := none
  deriving Inhabited

instance : ToJson FileSystemWatcher where
  toJson s := Json.mkObj <|
    [("globPattern", toJson s.globPattern)] ++
    (match s.kind with | some v => [("kind", toJson v)] | none => [])

instance : FromJson FileSystemWatcher where
  fromJson? json := do
    let globPattern ← json.getObjValAs? GlobPattern "globPattern"
    let kind := (json.getObjValAs? WatchKind "kind").toOption
    return { globPattern, kind }

/-- Contains additional information about the context in which a completion request is triggered. -/
structure CompletionContext where
  triggerKind : CompletionTriggerKind
  triggerCharacter : (Option String) := none
  deriving Inhabited

instance : ToJson CompletionContext where
  toJson s := Json.mkObj <|
    [("triggerKind", toJson s.triggerKind)] ++
    (match s.triggerCharacter with | some v => [("triggerCharacter", toJson v)] | none => [])

instance : FromJson CompletionContext where
  fromJson? json := do
    let triggerKind ← json.getObjValAs? CompletionTriggerKind "triggerKind"
    let triggerCharacter := (json.getObjValAs? String "triggerCharacter").toOption
    return { triggerKind, triggerCharacter }

/-- Additional details for a completion item label.  @since 3.17.0 -/
structure CompletionItemLabelDetails where
  detail : (Option String) := none
  description : (Option String) := none
  deriving Inhabited

instance : ToJson CompletionItemLabelDetails where
  toJson s := Json.mkObj <|
    (match s.detail with | some v => [("detail", toJson v)] | none => []) ++
    (match s.description with | some v => [("description", toJson v)] | none => [])

instance : FromJson CompletionItemLabelDetails where
  fromJson? json := do
    let detail := (json.getObjValAs? String "detail").toOption
    let description := (json.getObjValAs? String "description").toOption
    return { detail, description }

/-- Specifies how fields from a completion item should be combined with those from `completionList.itemDefaults`.  If unspecified, all fields will be treated as ApplyKind.Replace.  If a field's value is ApplyKind.Replace, the value from a completion item (if provided and not `null`) will always be used ... -/
structure CompletionItemApplyKinds where
  commitCharacters : (Option ApplyKind) := none
  data : (Option ApplyKind) := none
  deriving Inhabited

instance : ToJson CompletionItemApplyKinds where
  toJson s := Json.mkObj <|
    (match s.commitCharacters with | some v => [("commitCharacters", toJson v)] | none => []) ++
    (match s.data with | some v => [("data", toJson v)] | none => [])

instance : FromJson CompletionItemApplyKinds where
  fromJson? json := do
    let commitCharacters := (json.getObjValAs? ApplyKind "commitCharacters").toOption
    let data := (json.getObjValAs? ApplyKind "data").toOption
    return { commitCharacters, data }

/-- Value-object that contains additional information when requesting references. -/
structure ReferenceContext where
  includeDeclaration : Bool
  deriving Inhabited

instance : ToJson ReferenceContext where
  toJson s := Json.mkObj <|
    [("includeDeclaration", toJson s.includeDeclaration)]

instance : FromJson ReferenceContext where
  fromJson? json := do
    let includeDeclaration ← json.getObjValAs? Bool "includeDeclaration"
    return { includeDeclaration }

/-- A base for all symbol information. -/
structure BaseSymbolInformation where
  name : String
  kind : SymbolKind
  tags : (Option (Array SymbolTag)) := none
  containerName : (Option String) := none
  deriving Inhabited

instance : ToJson BaseSymbolInformation where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    [("kind", toJson s.kind)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.containerName with | some v => [("containerName", toJson v)] | none => [])

instance : FromJson BaseSymbolInformation where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let kind ← json.getObjValAs? SymbolKind "kind"
    let tags := (json.getObjValAs? (Array SymbolTag) "tags").toOption
    let containerName := (json.getObjValAs? String "containerName").toOption
    return { name, kind, tags, containerName }

/-- Contains additional diagnostic information about the context in which a {@link CodeActionProvider.provideCodeActions code action} is run. -/
structure CodeActionContext where
  diagnostics : Json
  only : (Option (Array CodeActionKind)) := none
  triggerKind : (Option CodeActionTriggerKind) := none
  deriving Inhabited

instance : ToJson CodeActionContext where
  toJson s := Json.mkObj <|
    [("diagnostics", toJson s.diagnostics)] ++
    (match s.only with | some v => [("only", toJson v)] | none => []) ++
    (match s.triggerKind with | some v => [("triggerKind", toJson v)] | none => [])

instance : FromJson CodeActionContext where
  fromJson? json := do
    let diagnostics := json.getObjVal? "diagnostics" |>.toOption |>.getD Json.null
    let only := (json.getObjValAs? (Array CodeActionKind) "only").toOption
    let triggerKind := (json.getObjValAs? CodeActionTriggerKind "triggerKind").toOption
    return { diagnostics, only, triggerKind }

/-- Captures why the code action is currently disabled.  @since 3.18.0 -/
structure CodeActionDisabled where
  reason : String
  deriving Inhabited

instance : ToJson CodeActionDisabled where
  toJson s := Json.mkObj <|
    [("reason", toJson s.reason)]

instance : FromJson CodeActionDisabled where
  fromJson? json := do
    let reason ← json.getObjValAs? String "reason"
    return { reason }

/-- Location with only uri and does not include range.  @since 3.18.0 -/
structure LocationUriOnly where
  uri : String
  deriving Inhabited

instance : ToJson LocationUriOnly where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)]

instance : FromJson LocationUriOnly where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    return { uri }

/-- Value-object describing what options formatting should use. -/
structure FormattingOptions where
  tabSize : Nat
  insertSpaces : Bool
  trimTrailingWhitespace : (Option Bool) := none
  insertFinalNewline : (Option Bool) := none
  trimFinalNewlines : (Option Bool) := none
  deriving Inhabited

instance : ToJson FormattingOptions where
  toJson s := Json.mkObj <|
    [("tabSize", toJson s.tabSize)] ++
    [("insertSpaces", toJson s.insertSpaces)] ++
    (match s.trimTrailingWhitespace with | some v => [("trimTrailingWhitespace", toJson v)] | none => []) ++
    (match s.insertFinalNewline with | some v => [("insertFinalNewline", toJson v)] | none => []) ++
    (match s.trimFinalNewlines with | some v => [("trimFinalNewlines", toJson v)] | none => [])

instance : FromJson FormattingOptions where
  fromJson? json := do
    let tabSize ← json.getObjValAs? Nat "tabSize"
    let insertSpaces ← json.getObjValAs? Bool "insertSpaces"
    let trimTrailingWhitespace := (json.getObjValAs? Bool "trimTrailingWhitespace").toOption
    let insertFinalNewline := (json.getObjValAs? Bool "insertFinalNewline").toOption
    let trimFinalNewlines := (json.getObjValAs? Bool "trimFinalNewlines").toOption
    return { tabSize, insertSpaces, trimTrailingWhitespace, insertFinalNewline, trimFinalNewlines }

/-- Provider options for a {@link DocumentOnTypeFormattingRequest}. -/
structure DocumentOnTypeFormattingOptions where
  firstTriggerCharacter : String
  moreTriggerCharacter : (Option (Array String)) := none
  deriving Inhabited

instance : ToJson DocumentOnTypeFormattingOptions where
  toJson s := Json.mkObj <|
    [("firstTriggerCharacter", toJson s.firstTriggerCharacter)] ++
    (match s.moreTriggerCharacter with | some v => [("moreTriggerCharacter", toJson v)] | none => [])

instance : FromJson DocumentOnTypeFormattingOptions where
  fromJson? json := do
    let firstTriggerCharacter ← json.getObjValAs? String "firstTriggerCharacter"
    let moreTriggerCharacter := (json.getObjValAs? (Array String) "moreTriggerCharacter").toOption
    return { firstTriggerCharacter, moreTriggerCharacter }

/-- @since 3.18.0 -/
structure PrepareRenameDefaultBehavior where
  defaultBehavior : Bool
  deriving Inhabited

instance : ToJson PrepareRenameDefaultBehavior where
  toJson s := Json.mkObj <|
    [("defaultBehavior", toJson s.defaultBehavior)]

instance : FromJson PrepareRenameDefaultBehavior where
  fromJson? json := do
    let defaultBehavior ← json.getObjValAs? Bool "defaultBehavior"
    return { defaultBehavior }

/-- @since 3.16.0 -/
structure SemanticTokensLegend where
  tokenTypes : (Array String)
  tokenModifiers : (Array String)
  deriving Inhabited

instance : ToJson SemanticTokensLegend where
  toJson s := Json.mkObj <|
    [("tokenTypes", toJson s.tokenTypes)] ++
    [("tokenModifiers", toJson s.tokenModifiers)]

instance : FromJson SemanticTokensLegend where
  fromJson? json := do
    let tokenTypes ← json.getObjValAs? (Array String) "tokenTypes"
    let tokenModifiers ← json.getObjValAs? (Array String) "tokenModifiers"
    return { tokenTypes, tokenModifiers }

/-- Semantic tokens options to support deltas for full documents  @since 3.18.0 -/
structure SemanticTokensFullDelta where
  delta : (Option Bool) := none
  deriving Inhabited

instance : ToJson SemanticTokensFullDelta where
  toJson s := Json.mkObj <|
    (match s.delta with | some v => [("delta", toJson v)] | none => [])

instance : FromJson SemanticTokensFullDelta where
  fromJson? json := do
    let delta := (json.getObjValAs? Bool "delta").toOption
    return { delta }

/-- A generic resource operation. -/
structure ResourceOperation where
  kind : String
  annotationId : (Option ChangeAnnotationIdentifier) := none
  deriving Inhabited

instance : ToJson ResourceOperation where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.annotationId with | some v => [("annotationId", toJson v)] | none => [])

instance : FromJson ResourceOperation where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let annotationId := (json.getObjValAs? ChangeAnnotationIdentifier "annotationId").toOption
    return { kind, annotationId }

/-- Options to create a file. -/
structure CreateFileOptions where
  overwrite : (Option Bool) := none
  ignoreIfExists : (Option Bool) := none
  deriving Inhabited

instance : ToJson CreateFileOptions where
  toJson s := Json.mkObj <|
    (match s.overwrite with | some v => [("overwrite", toJson v)] | none => []) ++
    (match s.ignoreIfExists with | some v => [("ignoreIfExists", toJson v)] | none => [])

instance : FromJson CreateFileOptions where
  fromJson? json := do
    let overwrite := (json.getObjValAs? Bool "overwrite").toOption
    let ignoreIfExists := (json.getObjValAs? Bool "ignoreIfExists").toOption
    return { overwrite, ignoreIfExists }

/-- Rename file options -/
structure RenameFileOptions where
  overwrite : (Option Bool) := none
  ignoreIfExists : (Option Bool) := none
  deriving Inhabited

instance : ToJson RenameFileOptions where
  toJson s := Json.mkObj <|
    (match s.overwrite with | some v => [("overwrite", toJson v)] | none => []) ++
    (match s.ignoreIfExists with | some v => [("ignoreIfExists", toJson v)] | none => [])

instance : FromJson RenameFileOptions where
  fromJson? json := do
    let overwrite := (json.getObjValAs? Bool "overwrite").toOption
    let ignoreIfExists := (json.getObjValAs? Bool "ignoreIfExists").toOption
    return { overwrite, ignoreIfExists }

/-- Delete file options -/
structure DeleteFileOptions where
  recursive : (Option Bool) := none
  ignoreIfNotExists : (Option Bool) := none
  deriving Inhabited

instance : ToJson DeleteFileOptions where
  toJson s := Json.mkObj <|
    (match s.recursive with | some v => [("recursive", toJson v)] | none => []) ++
    (match s.ignoreIfNotExists with | some v => [("ignoreIfNotExists", toJson v)] | none => [])

instance : FromJson DeleteFileOptions where
  fromJson? json := do
    let recursive := (json.getObjValAs? Bool "recursive").toOption
    let ignoreIfNotExists := (json.getObjValAs? Bool "ignoreIfNotExists").toOption
    return { recursive, ignoreIfNotExists }

/-- Information about the client  @since 3.15.0 @since 3.18.0 ClientInfo type name added. -/
structure ClientInfo where
  name : String
  version : (Option String) := none
  deriving Inhabited

instance : ToJson ClientInfo where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    (match s.version with | some v => [("version", toJson v)] | none => [])

instance : FromJson ClientInfo where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let version := (json.getObjValAs? String "version").toOption
    return { name, version }

/-- @since 3.18.0 -/
structure TextDocumentContentChangeWholeDocument where
  text : String
  deriving Inhabited

instance : ToJson TextDocumentContentChangeWholeDocument where
  toJson s := Json.mkObj <|
    [("text", toJson s.text)]

instance : FromJson TextDocumentContentChangeWholeDocument where
  fromJson? json := do
    let text ← json.getObjValAs? String "text"
    return { text }

/-- Structure to capture a description for an error code.  @since 3.16.0 -/
structure CodeDescription where
  href : String
  deriving Inhabited

instance : ToJson CodeDescription where
  toJson s := Json.mkObj <|
    [("href", toJson s.href)]

instance : FromJson CodeDescription where
  fromJson? json := do
    let href ← json.getObjValAs? String "href"
    return { href }

/-- @since 3.18.0 -/
structure ServerCompletionItemOptions where
  labelDetailsSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson ServerCompletionItemOptions where
  toJson s := Json.mkObj <|
    (match s.labelDetailsSupport with | some v => [("labelDetailsSupport", toJson v)] | none => [])

instance : FromJson ServerCompletionItemOptions where
  fromJson? json := do
    let labelDetailsSupport := (json.getObjValAs? Bool "labelDetailsSupport").toOption
    return { labelDetailsSupport }

/-- @since 3.18.0 @deprecated use MarkupContent instead. -/
structure MarkedStringWithLanguage where
  language : String
  value : String
  deriving Inhabited

instance : ToJson MarkedStringWithLanguage where
  toJson s := Json.mkObj <|
    [("language", toJson s.language)] ++
    [("value", toJson s.value)]

instance : FromJson MarkedStringWithLanguage where
  fromJson? json := do
    let language ← json.getObjValAs? String "language"
    let value ← json.getObjValAs? String "value"
    return { language, value }

/-- A notebook cell text document filter denotes a cell text document by different properties.  @since 3.17.0 -/
structure NotebookCellTextDocumentFilter where
  notebook : Json
  language : (Option String) := none
  deriving Inhabited

instance : ToJson NotebookCellTextDocumentFilter where
  toJson s := Json.mkObj <|
    [("notebook", toJson s.notebook)] ++
    (match s.language with | some v => [("language", toJson v)] | none => [])

instance : FromJson NotebookCellTextDocumentFilter where
  fromJson? json := do
    let notebook := json.getObjVal? "notebook" |>.toOption |>.getD Json.null
    let language := (json.getObjValAs? String "language").toOption
    return { notebook, language }

/-- Matching options for the file operation pattern.  @since 3.16.0 -/
structure FileOperationPatternOptions where
  ignoreCase : (Option Bool) := none
  deriving Inhabited

instance : ToJson FileOperationPatternOptions where
  toJson s := Json.mkObj <|
    (match s.ignoreCase with | some v => [("ignoreCase", toJson v)] | none => [])

instance : FromJson FileOperationPatternOptions where
  fromJson? json := do
    let ignoreCase := (json.getObjValAs? Bool "ignoreCase").toOption
    return { ignoreCase }

structure ExecutionSummary where
  executionOrder : Nat
  success : (Option Bool) := none
  deriving Inhabited

instance : ToJson ExecutionSummary where
  toJson s := Json.mkObj <|
    [("executionOrder", toJson s.executionOrder)] ++
    (match s.success with | some v => [("success", toJson v)] | none => [])

instance : FromJson ExecutionSummary where
  fromJson? json := do
    let executionOrder ← json.getObjValAs? Nat "executionOrder"
    let success := (json.getObjValAs? Bool "success").toOption
    return { executionOrder, success }

/-- @since 3.18.0 -/
structure NotebookCellLanguage where
  language : String
  deriving Inhabited

instance : ToJson NotebookCellLanguage where
  toJson s := Json.mkObj <|
    [("language", toJson s.language)]

instance : FromJson NotebookCellLanguage where
  fromJson? json := do
    let language ← json.getObjValAs? String "language"
    return { language }

structure WorkspaceFoldersServerCapabilities where
  supported : (Option Bool) := none
  changeNotifications : Json := Json.null
  deriving Inhabited

instance : ToJson WorkspaceFoldersServerCapabilities where
  toJson s := Json.mkObj <|
    (match s.supported with | some v => [("supported", toJson v)] | none => []) ++
    [("changeNotifications", toJson s.changeNotifications)]

instance : FromJson WorkspaceFoldersServerCapabilities where
  fromJson? json := do
    let supported := (json.getObjValAs? Bool "supported").toOption
    let changeNotifications := json.getObjVal? "changeNotifications" |>.toOption |>.getD Json.null
    return { supported, changeNotifications }

/-- A document filter where `language` is required field.  @since 3.18.0 -/
structure TextDocumentFilterLanguage where
  language : String
  scheme : (Option String) := none
  pattern : (Option GlobPattern) := none
  deriving Inhabited

instance : ToJson TextDocumentFilterLanguage where
  toJson s := Json.mkObj <|
    [("language", toJson s.language)] ++
    (match s.scheme with | some v => [("scheme", toJson v)] | none => []) ++
    (match s.pattern with | some v => [("pattern", toJson v)] | none => [])

instance : FromJson TextDocumentFilterLanguage where
  fromJson? json := do
    let language ← json.getObjValAs? String "language"
    let scheme := (json.getObjValAs? String "scheme").toOption
    let pattern := (json.getObjValAs? GlobPattern "pattern").toOption
    return { language, scheme, pattern }

/-- A document filter where `scheme` is required field.  @since 3.18.0 -/
structure TextDocumentFilterScheme where
  language : (Option String) := none
  scheme : String
  pattern : (Option GlobPattern) := none
  deriving Inhabited

instance : ToJson TextDocumentFilterScheme where
  toJson s := Json.mkObj <|
    (match s.language with | some v => [("language", toJson v)] | none => []) ++
    [("scheme", toJson s.scheme)] ++
    (match s.pattern with | some v => [("pattern", toJson v)] | none => [])

instance : FromJson TextDocumentFilterScheme where
  fromJson? json := do
    let language := (json.getObjValAs? String "language").toOption
    let scheme ← json.getObjValAs? String "scheme"
    let pattern := (json.getObjValAs? GlobPattern "pattern").toOption
    return { language, scheme, pattern }

/-- A document filter where `pattern` is required field.  @since 3.18.0 -/
structure TextDocumentFilterPattern where
  language : (Option String) := none
  scheme : (Option String) := none
  pattern : GlobPattern
  deriving Inhabited

instance : ToJson TextDocumentFilterPattern where
  toJson s := Json.mkObj <|
    (match s.language with | some v => [("language", toJson v)] | none => []) ++
    (match s.scheme with | some v => [("scheme", toJson v)] | none => []) ++
    [("pattern", toJson s.pattern)]

instance : FromJson TextDocumentFilterPattern where
  fromJson? json := do
    let language := (json.getObjValAs? String "language").toOption
    let scheme := (json.getObjValAs? String "scheme").toOption
    let pattern ← json.getObjValAs? GlobPattern "pattern"
    return { language, scheme, pattern }

/-- A notebook document filter where `notebookType` is required field.  @since 3.18.0 -/
structure NotebookDocumentFilterNotebookType where
  notebookType : String
  scheme : (Option String) := none
  pattern : (Option GlobPattern) := none
  deriving Inhabited

instance : ToJson NotebookDocumentFilterNotebookType where
  toJson s := Json.mkObj <|
    [("notebookType", toJson s.notebookType)] ++
    (match s.scheme with | some v => [("scheme", toJson v)] | none => []) ++
    (match s.pattern with | some v => [("pattern", toJson v)] | none => [])

instance : FromJson NotebookDocumentFilterNotebookType where
  fromJson? json := do
    let notebookType ← json.getObjValAs? String "notebookType"
    let scheme := (json.getObjValAs? String "scheme").toOption
    let pattern := (json.getObjValAs? GlobPattern "pattern").toOption
    return { notebookType, scheme, pattern }

/-- A notebook document filter where `scheme` is required field.  @since 3.18.0 -/
structure NotebookDocumentFilterScheme where
  notebookType : (Option String) := none
  scheme : String
  pattern : (Option GlobPattern) := none
  deriving Inhabited

instance : ToJson NotebookDocumentFilterScheme where
  toJson s := Json.mkObj <|
    (match s.notebookType with | some v => [("notebookType", toJson v)] | none => []) ++
    [("scheme", toJson s.scheme)] ++
    (match s.pattern with | some v => [("pattern", toJson v)] | none => [])

instance : FromJson NotebookDocumentFilterScheme where
  fromJson? json := do
    let notebookType := (json.getObjValAs? String "notebookType").toOption
    let scheme ← json.getObjValAs? String "scheme"
    let pattern := (json.getObjValAs? GlobPattern "pattern").toOption
    return { notebookType, scheme, pattern }

/-- A notebook document filter where `pattern` is required field.  @since 3.18.0 -/
structure NotebookDocumentFilterPattern where
  notebookType : (Option String) := none
  scheme : (Option String) := none
  pattern : GlobPattern
  deriving Inhabited

instance : ToJson NotebookDocumentFilterPattern where
  toJson s := Json.mkObj <|
    (match s.notebookType with | some v => [("notebookType", toJson v)] | none => []) ++
    (match s.scheme with | some v => [("scheme", toJson v)] | none => []) ++
    [("pattern", toJson s.pattern)]

instance : FromJson NotebookDocumentFilterPattern where
  fromJson? json := do
    let notebookType := (json.getObjValAs? String "notebookType").toOption
    let scheme := (json.getObjValAs? String "scheme").toOption
    let pattern ← json.getObjValAs? GlobPattern "pattern"
    return { notebookType, scheme, pattern }

/-- A change describing how to move a `NotebookCell` array from state S to S'.  @since 3.17.0 -/
structure NotebookCellArrayChange where
  start : Nat
  deleteCount : Nat
  cells : Json := Json.null
  deriving Inhabited

instance : ToJson NotebookCellArrayChange where
  toJson s := Json.mkObj <|
    [("start", toJson s.start)] ++
    [("deleteCount", toJson s.deleteCount)] ++
    [("cells", toJson s.cells)]

instance : FromJson NotebookCellArrayChange where
  fromJson? json := do
    let start ← json.getObjValAs? Nat "start"
    let deleteCount ← json.getObjValAs? Nat "deleteCount"
    let cells := json.getObjVal? "cells" |>.toOption |>.getD Json.null
    return { start, deleteCount, cells }

structure DidChangeConfigurationClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson DidChangeConfigurationClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson DidChangeConfigurationClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

structure DidChangeWatchedFilesClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  relativePatternSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DidChangeWatchedFilesClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.relativePatternSupport with | some v => [("relativePatternSupport", toJson v)] | none => [])

instance : FromJson DidChangeWatchedFilesClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let relativePatternSupport := (json.getObjValAs? Bool "relativePatternSupport").toOption
    return { dynamicRegistration, relativePatternSupport }

/-- The client capabilities of a {@link ExecuteCommandRequest}. -/
structure ExecuteCommandClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson ExecuteCommandClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson ExecuteCommandClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- @since 3.16.0 -/
structure SemanticTokensWorkspaceClientCapabilities where
  refreshSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson SemanticTokensWorkspaceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.refreshSupport with | some v => [("refreshSupport", toJson v)] | none => [])

instance : FromJson SemanticTokensWorkspaceClientCapabilities where
  fromJson? json := do
    let refreshSupport := (json.getObjValAs? Bool "refreshSupport").toOption
    return { refreshSupport }

/-- @since 3.16.0 -/
structure CodeLensWorkspaceClientCapabilities where
  refreshSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson CodeLensWorkspaceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.refreshSupport with | some v => [("refreshSupport", toJson v)] | none => [])

instance : FromJson CodeLensWorkspaceClientCapabilities where
  fromJson? json := do
    let refreshSupport := (json.getObjValAs? Bool "refreshSupport").toOption
    return { refreshSupport }

/-- Capabilities relating to events from file operations by the user in the client.  These events do not come from the file system, they come from user operations like renaming a file in the UI.  @since 3.16.0 -/
structure FileOperationClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  didCreate : (Option Bool) := none
  willCreate : (Option Bool) := none
  didRename : (Option Bool) := none
  willRename : (Option Bool) := none
  didDelete : (Option Bool) := none
  willDelete : (Option Bool) := none
  deriving Inhabited

instance : ToJson FileOperationClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.didCreate with | some v => [("didCreate", toJson v)] | none => []) ++
    (match s.willCreate with | some v => [("willCreate", toJson v)] | none => []) ++
    (match s.didRename with | some v => [("didRename", toJson v)] | none => []) ++
    (match s.willRename with | some v => [("willRename", toJson v)] | none => []) ++
    (match s.didDelete with | some v => [("didDelete", toJson v)] | none => []) ++
    (match s.willDelete with | some v => [("willDelete", toJson v)] | none => [])

instance : FromJson FileOperationClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let didCreate := (json.getObjValAs? Bool "didCreate").toOption
    let willCreate := (json.getObjValAs? Bool "willCreate").toOption
    let didRename := (json.getObjValAs? Bool "didRename").toOption
    let willRename := (json.getObjValAs? Bool "willRename").toOption
    let didDelete := (json.getObjValAs? Bool "didDelete").toOption
    let willDelete := (json.getObjValAs? Bool "willDelete").toOption
    return { dynamicRegistration, didCreate, willCreate, didRename, willRename, didDelete, willDelete }

/-- Client workspace capabilities specific to inline values.  @since 3.17.0 -/
structure InlineValueWorkspaceClientCapabilities where
  refreshSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson InlineValueWorkspaceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.refreshSupport with | some v => [("refreshSupport", toJson v)] | none => [])

instance : FromJson InlineValueWorkspaceClientCapabilities where
  fromJson? json := do
    let refreshSupport := (json.getObjValAs? Bool "refreshSupport").toOption
    return { refreshSupport }

/-- Client workspace capabilities specific to inlay hints.  @since 3.17.0 -/
structure InlayHintWorkspaceClientCapabilities where
  refreshSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson InlayHintWorkspaceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.refreshSupport with | some v => [("refreshSupport", toJson v)] | none => [])

instance : FromJson InlayHintWorkspaceClientCapabilities where
  fromJson? json := do
    let refreshSupport := (json.getObjValAs? Bool "refreshSupport").toOption
    return { refreshSupport }

/-- Workspace client capabilities specific to diagnostic pull requests.  @since 3.17.0 -/
structure DiagnosticWorkspaceClientCapabilities where
  refreshSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DiagnosticWorkspaceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.refreshSupport with | some v => [("refreshSupport", toJson v)] | none => [])

instance : FromJson DiagnosticWorkspaceClientCapabilities where
  fromJson? json := do
    let refreshSupport := (json.getObjValAs? Bool "refreshSupport").toOption
    return { refreshSupport }

structure TextDocumentSyncClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  willSave : (Option Bool) := none
  willSaveWaitUntil : (Option Bool) := none
  didSave : (Option Bool) := none
  deriving Inhabited

instance : ToJson TextDocumentSyncClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.willSave with | some v => [("willSave", toJson v)] | none => []) ++
    (match s.willSaveWaitUntil with | some v => [("willSaveWaitUntil", toJson v)] | none => []) ++
    (match s.didSave with | some v => [("didSave", toJson v)] | none => [])

instance : FromJson TextDocumentSyncClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let willSave := (json.getObjValAs? Bool "willSave").toOption
    let willSaveWaitUntil := (json.getObjValAs? Bool "willSaveWaitUntil").toOption
    let didSave := (json.getObjValAs? Bool "didSave").toOption
    return { dynamicRegistration, willSave, willSaveWaitUntil, didSave }

structure TextDocumentFilterClientCapabilities where
  relativePatternSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson TextDocumentFilterClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.relativePatternSupport with | some v => [("relativePatternSupport", toJson v)] | none => [])

instance : FromJson TextDocumentFilterClientCapabilities where
  fromJson? json := do
    let relativePatternSupport := (json.getObjValAs? Bool "relativePatternSupport").toOption
    return { relativePatternSupport }

structure HoverClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  contentFormat : (Option (Array MarkupKind)) := none
  deriving Inhabited

instance : ToJson HoverClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.contentFormat with | some v => [("contentFormat", toJson v)] | none => [])

instance : FromJson HoverClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let contentFormat := (json.getObjValAs? (Array MarkupKind) "contentFormat").toOption
    return { dynamicRegistration, contentFormat }

/-- @since 3.14.0 -/
structure DeclarationClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  linkSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DeclarationClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.linkSupport with | some v => [("linkSupport", toJson v)] | none => [])

instance : FromJson DeclarationClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let linkSupport := (json.getObjValAs? Bool "linkSupport").toOption
    return { dynamicRegistration, linkSupport }

/-- Client Capabilities for a {@link DefinitionRequest}. -/
structure DefinitionClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  linkSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DefinitionClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.linkSupport with | some v => [("linkSupport", toJson v)] | none => [])

instance : FromJson DefinitionClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let linkSupport := (json.getObjValAs? Bool "linkSupport").toOption
    return { dynamicRegistration, linkSupport }

/-- Since 3.6.0 -/
structure TypeDefinitionClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  linkSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson TypeDefinitionClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.linkSupport with | some v => [("linkSupport", toJson v)] | none => [])

instance : FromJson TypeDefinitionClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let linkSupport := (json.getObjValAs? Bool "linkSupport").toOption
    return { dynamicRegistration, linkSupport }

/-- @since 3.6.0 -/
structure ImplementationClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  linkSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson ImplementationClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.linkSupport with | some v => [("linkSupport", toJson v)] | none => [])

instance : FromJson ImplementationClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let linkSupport := (json.getObjValAs? Bool "linkSupport").toOption
    return { dynamicRegistration, linkSupport }

/-- Client Capabilities for a {@link ReferencesRequest}. -/
structure ReferenceClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson ReferenceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson ReferenceClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Client Capabilities for a {@link DocumentHighlightRequest}. -/
structure DocumentHighlightClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentHighlightClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson DocumentHighlightClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- The client capabilities of a {@link DocumentLinkRequest}. -/
structure DocumentLinkClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  tooltipSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentLinkClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.tooltipSupport with | some v => [("tooltipSupport", toJson v)] | none => [])

instance : FromJson DocumentLinkClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let tooltipSupport := (json.getObjValAs? Bool "tooltipSupport").toOption
    return { dynamicRegistration, tooltipSupport }

structure DocumentColorClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentColorClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson DocumentColorClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Client capabilities of a {@link DocumentFormattingRequest}. -/
structure DocumentFormattingClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentFormattingClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson DocumentFormattingClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Client capabilities of a {@link DocumentRangeFormattingRequest}. -/
structure DocumentRangeFormattingClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  rangesSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentRangeFormattingClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.rangesSupport with | some v => [("rangesSupport", toJson v)] | none => [])

instance : FromJson DocumentRangeFormattingClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let rangesSupport := (json.getObjValAs? Bool "rangesSupport").toOption
    return { dynamicRegistration, rangesSupport }

/-- Client capabilities of a {@link DocumentOnTypeFormattingRequest}. -/
structure DocumentOnTypeFormattingClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentOnTypeFormattingClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson DocumentOnTypeFormattingClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

structure RenameClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  prepareSupport : (Option Bool) := none
  prepareSupportDefaultBehavior : (Option PrepareSupportDefaultBehavior) := none
  honorsChangeAnnotations : (Option Bool) := none
  deriving Inhabited

instance : ToJson RenameClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.prepareSupport with | some v => [("prepareSupport", toJson v)] | none => []) ++
    (match s.prepareSupportDefaultBehavior with | some v => [("prepareSupportDefaultBehavior", toJson v)] | none => []) ++
    (match s.honorsChangeAnnotations with | some v => [("honorsChangeAnnotations", toJson v)] | none => [])

instance : FromJson RenameClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let prepareSupport := (json.getObjValAs? Bool "prepareSupport").toOption
    let prepareSupportDefaultBehavior := (json.getObjValAs? PrepareSupportDefaultBehavior "prepareSupportDefaultBehavior").toOption
    let honorsChangeAnnotations := (json.getObjValAs? Bool "honorsChangeAnnotations").toOption
    return { dynamicRegistration, prepareSupport, prepareSupportDefaultBehavior, honorsChangeAnnotations }

structure SelectionRangeClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson SelectionRangeClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson SelectionRangeClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- @since 3.16.0 -/
structure CallHierarchyClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson CallHierarchyClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson CallHierarchyClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Client capabilities for the linked editing range request.  @since 3.16.0 -/
structure LinkedEditingRangeClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson LinkedEditingRangeClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson LinkedEditingRangeClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Client capabilities specific to the moniker request.  @since 3.16.0 -/
structure MonikerClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson MonikerClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson MonikerClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- @since 3.17.0 -/
structure TypeHierarchyClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson TypeHierarchyClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson TypeHierarchyClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Client capabilities specific to inline values.  @since 3.17.0 -/
structure InlineValueClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  deriving Inhabited

instance : ToJson InlineValueClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => [])

instance : FromJson InlineValueClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    return { dynamicRegistration }

/-- Notebook specific client capabilities.  @since 3.17.0 -/
structure NotebookDocumentSyncClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  executionSummarySupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson NotebookDocumentSyncClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.executionSummarySupport with | some v => [("executionSummarySupport", toJson v)] | none => [])

instance : FromJson NotebookDocumentSyncClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let executionSummarySupport := (json.getObjValAs? Bool "executionSummarySupport").toOption
    return { dynamicRegistration, executionSummarySupport }

/-- Client capabilities for the showDocument request.  @since 3.16.0 -/
structure ShowDocumentClientCapabilities where
  support : Bool
  deriving Inhabited

instance : ToJson ShowDocumentClientCapabilities where
  toJson s := Json.mkObj <|
    [("support", toJson s.support)]

instance : FromJson ShowDocumentClientCapabilities where
  fromJson? json := do
    let support ← json.getObjValAs? Bool "support"
    return { support }

/-- @since 3.18.0 -/
structure StaleRequestSupportOptions where
  cancel : Bool
  retryOnContentModified : (Array String)
  deriving Inhabited

instance : ToJson StaleRequestSupportOptions where
  toJson s := Json.mkObj <|
    [("cancel", toJson s.cancel)] ++
    [("retryOnContentModified", toJson s.retryOnContentModified)]

instance : FromJson StaleRequestSupportOptions where
  fromJson? json := do
    let cancel ← json.getObjValAs? Bool "cancel"
    let retryOnContentModified ← json.getObjValAs? (Array String) "retryOnContentModified"
    return { cancel, retryOnContentModified }

/-- Client capabilities specific to regular expressions.  @since 3.16.0 -/
structure RegularExpressionsClientCapabilities where
  engine : RegularExpressionEngineKind
  version : (Option String) := none
  deriving Inhabited

instance : ToJson RegularExpressionsClientCapabilities where
  toJson s := Json.mkObj <|
    [("engine", toJson s.engine)] ++
    (match s.version with | some v => [("version", toJson v)] | none => [])

instance : FromJson RegularExpressionsClientCapabilities where
  fromJson? json := do
    let engine ← json.getObjValAs? RegularExpressionEngineKind "engine"
    let version := (json.getObjValAs? String "version").toOption
    return { engine, version }

/-- Client capabilities specific to the used markdown parser.  @since 3.16.0 -/
structure MarkdownClientCapabilities where
  parser : String
  version : (Option String) := none
  allowedTags : (Option (Array String)) := none
  deriving Inhabited

instance : ToJson MarkdownClientCapabilities where
  toJson s := Json.mkObj <|
    [("parser", toJson s.parser)] ++
    (match s.version with | some v => [("version", toJson v)] | none => []) ++
    (match s.allowedTags with | some v => [("allowedTags", toJson v)] | none => [])

instance : FromJson MarkdownClientCapabilities where
  fromJson? json := do
    let parser ← json.getObjValAs? String "parser"
    let version := (json.getObjValAs? String "version").toOption
    let allowedTags := (json.getObjValAs? (Array String) "allowedTags").toOption
    return { parser, version, allowedTags }

/-- @since 3.18.0 -/
structure ChangeAnnotationsSupportOptions where
  groupsOnLabel : (Option Bool) := none
  deriving Inhabited

instance : ToJson ChangeAnnotationsSupportOptions where
  toJson s := Json.mkObj <|
    (match s.groupsOnLabel with | some v => [("groupsOnLabel", toJson v)] | none => [])

instance : FromJson ChangeAnnotationsSupportOptions where
  fromJson? json := do
    let groupsOnLabel := (json.getObjValAs? Bool "groupsOnLabel").toOption
    return { groupsOnLabel }

/-- @since 3.18.0 -/
structure ClientSymbolKindOptions where
  valueSet : (Option (Array SymbolKind)) := none
  deriving Inhabited

instance : ToJson ClientSymbolKindOptions where
  toJson s := Json.mkObj <|
    (match s.valueSet with | some v => [("valueSet", toJson v)] | none => [])

instance : FromJson ClientSymbolKindOptions where
  fromJson? json := do
    let valueSet := (json.getObjValAs? (Array SymbolKind) "valueSet").toOption
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientSymbolTagOptions where
  valueSet : (Array SymbolTag)
  deriving Inhabited

instance : ToJson ClientSymbolTagOptions where
  toJson s := Json.mkObj <|
    [("valueSet", toJson s.valueSet)]

instance : FromJson ClientSymbolTagOptions where
  fromJson? json := do
    let valueSet ← json.getObjValAs? (Array SymbolTag) "valueSet"
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientSymbolResolveOptions where
  properties : (Array String)
  deriving Inhabited

instance : ToJson ClientSymbolResolveOptions where
  toJson s := Json.mkObj <|
    [("properties", toJson s.properties)]

instance : FromJson ClientSymbolResolveOptions where
  fromJson? json := do
    let properties ← json.getObjValAs? (Array String) "properties"
    return { properties }

/-- @since 3.18.0 -/
structure ClientCompletionItemOptionsKind where
  valueSet : (Option (Array CompletionItemKind)) := none
  deriving Inhabited

instance : ToJson ClientCompletionItemOptionsKind where
  toJson s := Json.mkObj <|
    (match s.valueSet with | some v => [("valueSet", toJson v)] | none => [])

instance : FromJson ClientCompletionItemOptionsKind where
  fromJson? json := do
    let valueSet := (json.getObjValAs? (Array CompletionItemKind) "valueSet").toOption
    return { valueSet }

/-- The client supports the following `CompletionList` specific capabilities.  @since 3.17.0 -/
structure CompletionListCapabilities where
  itemDefaults : (Option (Array String)) := none
  applyKindSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson CompletionListCapabilities where
  toJson s := Json.mkObj <|
    (match s.itemDefaults with | some v => [("itemDefaults", toJson v)] | none => []) ++
    (match s.applyKindSupport with | some v => [("applyKindSupport", toJson v)] | none => [])

instance : FromJson CompletionListCapabilities where
  fromJson? json := do
    let itemDefaults := (json.getObjValAs? (Array String) "itemDefaults").toOption
    let applyKindSupport := (json.getObjValAs? Bool "applyKindSupport").toOption
    return { itemDefaults, applyKindSupport }

/-- @since 3.18.0 -/
structure ClientCodeActionResolveOptions where
  properties : (Array String)
  deriving Inhabited

instance : ToJson ClientCodeActionResolveOptions where
  toJson s := Json.mkObj <|
    [("properties", toJson s.properties)]

instance : FromJson ClientCodeActionResolveOptions where
  fromJson? json := do
    let properties ← json.getObjValAs? (Array String) "properties"
    return { properties }

/-- @since 3.18.0 - proposed -/
structure CodeActionTagOptions where
  valueSet : (Array CodeActionTag)
  deriving Inhabited

instance : ToJson CodeActionTagOptions where
  toJson s := Json.mkObj <|
    [("valueSet", toJson s.valueSet)]

instance : FromJson CodeActionTagOptions where
  fromJson? json := do
    let valueSet ← json.getObjValAs? (Array CodeActionTag) "valueSet"
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientCodeLensResolveOptions where
  properties : (Array String)
  deriving Inhabited

instance : ToJson ClientCodeLensResolveOptions where
  toJson s := Json.mkObj <|
    [("properties", toJson s.properties)]

instance : FromJson ClientCodeLensResolveOptions where
  fromJson? json := do
    let properties ← json.getObjValAs? (Array String) "properties"
    return { properties }

/-- @since 3.18.0 -/
structure ClientFoldingRangeKindOptions where
  valueSet : (Option (Array FoldingRangeKind)) := none
  deriving Inhabited

instance : ToJson ClientFoldingRangeKindOptions where
  toJson s := Json.mkObj <|
    (match s.valueSet with | some v => [("valueSet", toJson v)] | none => [])

instance : FromJson ClientFoldingRangeKindOptions where
  fromJson? json := do
    let valueSet := (json.getObjValAs? (Array FoldingRangeKind) "valueSet").toOption
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientFoldingRangeOptions where
  collapsedText : (Option Bool) := none
  deriving Inhabited

instance : ToJson ClientFoldingRangeOptions where
  toJson s := Json.mkObj <|
    (match s.collapsedText with | some v => [("collapsedText", toJson v)] | none => [])

instance : FromJson ClientFoldingRangeOptions where
  fromJson? json := do
    let collapsedText := (json.getObjValAs? Bool "collapsedText").toOption
    return { collapsedText }

/-- @since 3.18.0 -/
structure ClientInlayHintResolveOptions where
  properties : (Array String)
  deriving Inhabited

instance : ToJson ClientInlayHintResolveOptions where
  toJson s := Json.mkObj <|
    [("properties", toJson s.properties)]

instance : FromJson ClientInlayHintResolveOptions where
  fromJson? json := do
    let properties ← json.getObjValAs? (Array String) "properties"
    return { properties }

/-- @since 3.18.0 -/
structure ClientShowMessageActionItemOptions where
  additionalPropertiesSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson ClientShowMessageActionItemOptions where
  toJson s := Json.mkObj <|
    (match s.additionalPropertiesSupport with | some v => [("additionalPropertiesSupport", toJson v)] | none => [])

instance : FromJson ClientShowMessageActionItemOptions where
  fromJson? json := do
    let additionalPropertiesSupport := (json.getObjValAs? Bool "additionalPropertiesSupport").toOption
    return { additionalPropertiesSupport }

/-- @since 3.18.0 -/
structure CompletionItemTagOptions where
  valueSet : (Array CompletionItemTag)
  deriving Inhabited

instance : ToJson CompletionItemTagOptions where
  toJson s := Json.mkObj <|
    [("valueSet", toJson s.valueSet)]

instance : FromJson CompletionItemTagOptions where
  fromJson? json := do
    let valueSet ← json.getObjValAs? (Array CompletionItemTag) "valueSet"
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientCompletionItemResolveOptions where
  properties : (Array String)
  deriving Inhabited

instance : ToJson ClientCompletionItemResolveOptions where
  toJson s := Json.mkObj <|
    [("properties", toJson s.properties)]

instance : FromJson ClientCompletionItemResolveOptions where
  fromJson? json := do
    let properties ← json.getObjValAs? (Array String) "properties"
    return { properties }

/-- @since 3.18.0 -/
structure ClientCompletionItemInsertTextModeOptions where
  valueSet : (Array InsertTextMode)
  deriving Inhabited

instance : ToJson ClientCompletionItemInsertTextModeOptions where
  toJson s := Json.mkObj <|
    [("valueSet", toJson s.valueSet)]

instance : FromJson ClientCompletionItemInsertTextModeOptions where
  fromJson? json := do
    let valueSet ← json.getObjValAs? (Array InsertTextMode) "valueSet"
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientSignatureParameterInformationOptions where
  labelOffsetSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson ClientSignatureParameterInformationOptions where
  toJson s := Json.mkObj <|
    (match s.labelOffsetSupport with | some v => [("labelOffsetSupport", toJson v)] | none => [])

instance : FromJson ClientSignatureParameterInformationOptions where
  fromJson? json := do
    let labelOffsetSupport := (json.getObjValAs? Bool "labelOffsetSupport").toOption
    return { labelOffsetSupport }

/-- @since 3.18.0 -/
structure ClientCodeActionKindOptions where
  valueSet : (Array CodeActionKind)
  deriving Inhabited

instance : ToJson ClientCodeActionKindOptions where
  toJson s := Json.mkObj <|
    [("valueSet", toJson s.valueSet)]

instance : FromJson ClientCodeActionKindOptions where
  fromJson? json := do
    let valueSet ← json.getObjValAs? (Array CodeActionKind) "valueSet"
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientDiagnosticsTagOptions where
  valueSet : (Array DiagnosticTag)
  deriving Inhabited

instance : ToJson ClientDiagnosticsTagOptions where
  toJson s := Json.mkObj <|
    [("valueSet", toJson s.valueSet)]

instance : FromJson ClientDiagnosticsTagOptions where
  fromJson? json := do
    let valueSet ← json.getObjValAs? (Array DiagnosticTag) "valueSet"
    return { valueSet }

/-- @since 3.18.0 -/
structure ClientSemanticTokensRequestFullDelta where
  delta : (Option Bool) := none
  deriving Inhabited

instance : ToJson ClientSemanticTokensRequestFullDelta where
  toJson s := Json.mkObj <|
    (match s.delta with | some v => [("delta", toJson v)] | none => [])

instance : FromJson ClientSemanticTokensRequestFullDelta where
  fromJson? json := do
    let delta := (json.getObjValAs? Bool "delta").toOption
    return { delta }

/-- The workspace folder change event. -/
structure WorkspaceFoldersChangeEvent where
  added : (Array WorkspaceFolder)
  removed : (Array WorkspaceFolder)
  deriving Inhabited

instance : ToJson WorkspaceFoldersChangeEvent where
  toJson s := Json.mkObj <|
    [("added", toJson s.added)] ++
    [("removed", toJson s.removed)]

instance : FromJson WorkspaceFoldersChangeEvent where
  fromJson? json := do
    let added ← json.getObjValAs? (Array WorkspaceFolder) "added"
    let removed ← json.getObjValAs? (Array WorkspaceFolder) "removed"
    return { added, removed }

structure WorkspaceFoldersInitializeParams where
  workspaceFolders : (Option (Array WorkspaceFolder)) := none
  deriving Inhabited

instance : ToJson WorkspaceFoldersInitializeParams where
  toJson s := Json.mkObj <|
    (match s.workspaceFolders with | some v => [("workspaceFolders", toJson v)] | none => [])

instance : FromJson WorkspaceFoldersInitializeParams where
  fromJson? json := do
    let workspaceFolders := (json.getObjValAs? (Array WorkspaceFolder) "workspaceFolders").toOption
    return { workspaceFolders }

/-- A relative pattern is a helper to construct glob patterns that are matched relatively to a base URI. The common value for a `baseUri` is a workspace folder root, but it can be another absolute URI as well.  @since 3.17.0 -/
structure RelativePattern where
  baseUri : Json
  pattern : Pattern
  deriving Inhabited

instance : ToJson RelativePattern where
  toJson s := Json.mkObj <|
    [("baseUri", toJson s.baseUri)] ++
    [("pattern", toJson s.pattern)]

instance : FromJson RelativePattern where
  fromJson? json := do
    let baseUri := json.getObjVal? "baseUri" |>.toOption |>.getD Json.null
    let pattern ← json.getObjValAs? Pattern "pattern"
    return { baseUri, pattern }

structure ImplementationOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson ImplementationOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson ImplementationOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure TypeDefinitionOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson TypeDefinitionOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson TypeDefinitionOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure DocumentColorOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentColorOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson DocumentColorOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure FoldingRangeOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson FoldingRangeOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson FoldingRangeOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure DeclarationOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson DeclarationOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson DeclarationOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure SelectionRangeOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson SelectionRangeOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson SelectionRangeOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Call hierarchy options used during static registration.  @since 3.16.0 -/
structure CallHierarchyOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson CallHierarchyOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson CallHierarchyOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure LinkedEditingRangeOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson LinkedEditingRangeOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson LinkedEditingRangeOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

structure MonikerOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson MonikerOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson MonikerOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Type hierarchy options used during static registration.  @since 3.17.0 -/
structure TypeHierarchyOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson TypeHierarchyOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson TypeHierarchyOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Inline value options used during static registration.  @since 3.17.0 -/
structure InlineValueOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson InlineValueOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson InlineValueOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Inlay hint options used during static registration.  @since 3.17.0 -/
structure InlayHintOptions where
  workDoneProgress : (Option Bool) := none
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson InlayHintOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson InlayHintOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { workDoneProgress, resolveProvider }

/-- Diagnostic options.  @since 3.17.0 -/
structure DiagnosticOptions where
  workDoneProgress : (Option Bool) := none
  identifier : (Option String) := none
  interFileDependencies : Bool
  workspaceDiagnostics : Bool
  deriving Inhabited

instance : ToJson DiagnosticOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.identifier with | some v => [("identifier", toJson v)] | none => []) ++
    [("interFileDependencies", toJson s.interFileDependencies)] ++
    [("workspaceDiagnostics", toJson s.workspaceDiagnostics)]

instance : FromJson DiagnosticOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let identifier := (json.getObjValAs? String "identifier").toOption
    let interFileDependencies ← json.getObjValAs? Bool "interFileDependencies"
    let workspaceDiagnostics ← json.getObjValAs? Bool "workspaceDiagnostics"
    return { workDoneProgress, identifier, interFileDependencies, workspaceDiagnostics }

/-- Hover options. -/
structure HoverOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson HoverOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson HoverOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Server Capabilities for a {@link SignatureHelpRequest}. -/
structure SignatureHelpOptions where
  workDoneProgress : (Option Bool) := none
  triggerCharacters : (Option (Array String)) := none
  retriggerCharacters : (Option (Array String)) := none
  deriving Inhabited

instance : ToJson SignatureHelpOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.triggerCharacters with | some v => [("triggerCharacters", toJson v)] | none => []) ++
    (match s.retriggerCharacters with | some v => [("retriggerCharacters", toJson v)] | none => [])

instance : FromJson SignatureHelpOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let triggerCharacters := (json.getObjValAs? (Array String) "triggerCharacters").toOption
    let retriggerCharacters := (json.getObjValAs? (Array String) "retriggerCharacters").toOption
    return { workDoneProgress, triggerCharacters, retriggerCharacters }

/-- Server Capabilities for a {@link DefinitionRequest}. -/
structure DefinitionOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson DefinitionOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson DefinitionOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Reference options. -/
structure ReferenceOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson ReferenceOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson ReferenceOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Provider options for a {@link DocumentHighlightRequest}. -/
structure DocumentHighlightOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentHighlightOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson DocumentHighlightOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Provider options for a {@link DocumentSymbolRequest}. -/
structure DocumentSymbolOptions where
  workDoneProgress : (Option Bool) := none
  label : (Option String) := none
  deriving Inhabited

instance : ToJson DocumentSymbolOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.label with | some v => [("label", toJson v)] | none => [])

instance : FromJson DocumentSymbolOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let label := (json.getObjValAs? String "label").toOption
    return { workDoneProgress, label }

/-- Provider options for a {@link CodeActionRequest}. -/
structure CodeActionOptions where
  workDoneProgress : (Option Bool) := none
  codeActionKinds : (Option (Array CodeActionKind)) := none
  documentation : Json := Json.null
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson CodeActionOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.codeActionKinds with | some v => [("codeActionKinds", toJson v)] | none => []) ++
    [("documentation", toJson s.documentation)] ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson CodeActionOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let codeActionKinds := (json.getObjValAs? (Array CodeActionKind) "codeActionKinds").toOption
    let documentation := json.getObjVal? "documentation" |>.toOption |>.getD Json.null
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { workDoneProgress, codeActionKinds, documentation, resolveProvider }

/-- Server capabilities for a {@link WorkspaceSymbolRequest}. -/
structure WorkspaceSymbolOptions where
  workDoneProgress : (Option Bool) := none
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson WorkspaceSymbolOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson WorkspaceSymbolOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { workDoneProgress, resolveProvider }

/-- Code Lens provider options of a {@link CodeLensRequest}. -/
structure CodeLensOptions where
  workDoneProgress : (Option Bool) := none
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson CodeLensOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson CodeLensOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { workDoneProgress, resolveProvider }

/-- Provider options for a {@link DocumentLinkRequest}. -/
structure DocumentLinkOptions where
  workDoneProgress : (Option Bool) := none
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentLinkOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson DocumentLinkOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { workDoneProgress, resolveProvider }

/-- Provider options for a {@link DocumentFormattingRequest}. -/
structure DocumentFormattingOptions where
  workDoneProgress : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentFormattingOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => [])

instance : FromJson DocumentFormattingOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    return { workDoneProgress }

/-- Provider options for a {@link DocumentRangeFormattingRequest}. -/
structure DocumentRangeFormattingOptions where
  workDoneProgress : (Option Bool) := none
  rangesSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentRangeFormattingOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.rangesSupport with | some v => [("rangesSupport", toJson v)] | none => [])

instance : FromJson DocumentRangeFormattingOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let rangesSupport := (json.getObjValAs? Bool "rangesSupport").toOption
    return { workDoneProgress, rangesSupport }

/-- Provider options for a {@link RenameRequest}. -/
structure RenameOptions where
  workDoneProgress : (Option Bool) := none
  prepareProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson RenameOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.prepareProvider with | some v => [("prepareProvider", toJson v)] | none => [])

instance : FromJson RenameOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let prepareProvider := (json.getObjValAs? Bool "prepareProvider").toOption
    return { workDoneProgress, prepareProvider }

/-- The server capabilities of a {@link ExecuteCommandRequest}. -/
structure ExecuteCommandOptions where
  workDoneProgress : (Option Bool) := none
  commands : (Array String)
  deriving Inhabited

instance : ToJson ExecuteCommandOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    [("commands", toJson s.commands)]

instance : FromJson ExecuteCommandOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let commands ← json.getObjValAs? (Array String) "commands"
    return { workDoneProgress, commands }

/-- Describe options to be used when registered for text document change events. -/
structure TextDocumentChangeRegistrationOptions where
  documentSelector : (Option Json)
  syncKind : TextDocumentSyncKind
  deriving Inhabited

instance : ToJson TextDocumentChangeRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    [("syncKind", toJson s.syncKind)]

instance : FromJson TextDocumentChangeRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let syncKind ← json.getObjValAs? TextDocumentSyncKind "syncKind"
    return { documentSelector, syncKind }

structure ShowMessageRequestParams where
  «type» : MessageType
  message : String
  actions : (Option (Array MessageActionItem)) := none
  deriving Inhabited

instance : ToJson ShowMessageRequestParams where
  toJson s := Json.mkObj <|
    [("type", toJson s.«type»)] ++
    [("message", toJson s.message)] ++
    (match s.actions with | some v => [("actions", toJson v)] | none => [])

instance : FromJson ShowMessageRequestParams where
  fromJson? json := do
    let «type» ← json.getObjValAs? MessageType "type"
    let message ← json.getObjValAs? String "message"
    let actions := (json.getObjValAs? (Array MessageActionItem) "actions").toOption
    return { «type», message, actions }

/-- The parameters of a {@link ExecuteCommandRequest}. -/
structure ExecuteCommandParams where
  workDoneToken : (Option ProgressToken) := none
  command : String
  arguments : Json := Json.null
  deriving Inhabited

instance : ToJson ExecuteCommandParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("command", toJson s.command)] ++
    [("arguments", toJson s.arguments)]

instance : FromJson ExecuteCommandParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let command ← json.getObjValAs? String "command"
    let arguments := json.getObjVal? "arguments" |>.toOption |>.getD Json.null
    return { workDoneToken, command, arguments }

/-- The parameters of a {@link WorkspaceSymbolRequest}. -/
structure WorkspaceSymbolParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  query : String
  deriving Inhabited

instance : ToJson WorkspaceSymbolParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("query", toJson s.query)]

instance : FromJson WorkspaceSymbolParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let query ← json.getObjValAs? String "query"
    return { workDoneToken, partialResultToken, query }

/-- The parameters of a configuration request. -/
structure ConfigurationParams where
  items : (Array ConfigurationItem)
  deriving Inhabited

instance : ToJson ConfigurationParams where
  toJson s := Json.mkObj <|
    [("items", toJson s.items)]

instance : FromJson ConfigurationParams where
  fromJson? json := do
    let items ← json.getObjValAs? (Array ConfigurationItem) "items"
    return { items }

/-- Parameters for a {@link DocumentColorRequest}. -/
structure DocumentColorParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson DocumentColorParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)]

instance : FromJson DocumentColorParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { workDoneToken, partialResultToken, textDocument }

/-- Parameters for a {@link FoldingRangeRequest}. -/
structure FoldingRangeParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson FoldingRangeParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)]

instance : FromJson FoldingRangeParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { workDoneToken, partialResultToken, textDocument }

/-- @since 3.16.0 -/
structure SemanticTokensParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson SemanticTokensParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)]

instance : FromJson SemanticTokensParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { workDoneToken, partialResultToken, textDocument }

/-- @since 3.16.0 -/
structure SemanticTokensDeltaParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  previousResultId : String
  deriving Inhabited

instance : ToJson SemanticTokensDeltaParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("previousResultId", toJson s.previousResultId)]

instance : FromJson SemanticTokensDeltaParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let previousResultId ← json.getObjValAs? String "previousResultId"
    return { workDoneToken, partialResultToken, textDocument, previousResultId }

/-- Parameters of the document diagnostic request.  @since 3.17.0 -/
structure DocumentDiagnosticParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  identifier : (Option String) := none
  previousResultId : (Option String) := none
  deriving Inhabited

instance : ToJson DocumentDiagnosticParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    (match s.identifier with | some v => [("identifier", toJson v)] | none => []) ++
    (match s.previousResultId with | some v => [("previousResultId", toJson v)] | none => [])

instance : FromJson DocumentDiagnosticParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let identifier := (json.getObjValAs? String "identifier").toOption
    let previousResultId := (json.getObjValAs? String "previousResultId").toOption
    return { workDoneToken, partialResultToken, textDocument, identifier, previousResultId }

/-- The parameters sent in a close text document notification -/
structure DidCloseTextDocumentParams where
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson DidCloseTextDocumentParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)]

instance : FromJson DidCloseTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { textDocument }

/-- The parameters sent in a save text document notification -/
structure DidSaveTextDocumentParams where
  textDocument : TextDocumentIdentifier
  text : (Option String) := none
  deriving Inhabited

instance : ToJson DidSaveTextDocumentParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    (match s.text with | some v => [("text", toJson v)] | none => [])

instance : FromJson DidSaveTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let text := (json.getObjValAs? String "text").toOption
    return { textDocument, text }

/-- The parameters sent in a will save text document notification. -/
structure WillSaveTextDocumentParams where
  textDocument : TextDocumentIdentifier
  reason : TextDocumentSaveReason
  deriving Inhabited

instance : ToJson WillSaveTextDocumentParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("reason", toJson s.reason)]

instance : FromJson WillSaveTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let reason ← json.getObjValAs? TextDocumentSaveReason "reason"
    return { textDocument, reason }

/-- Parameters for a {@link DocumentSymbolRequest}. -/
structure DocumentSymbolParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson DocumentSymbolParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)]

instance : FromJson DocumentSymbolParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { workDoneToken, partialResultToken, textDocument }

/-- The parameters of a {@link CodeLensRequest}. -/
structure CodeLensParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson CodeLensParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)]

instance : FromJson CodeLensParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { workDoneToken, partialResultToken, textDocument }

/-- The parameters of a {@link DocumentLinkRequest}. -/
structure DocumentLinkParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  deriving Inhabited

instance : ToJson DocumentLinkParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)]

instance : FromJson DocumentLinkParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    return { workDoneToken, partialResultToken, textDocument }

/-- A text document identifier to denote a specific version of a text document. -/
structure VersionedTextDocumentIdentifier where
  uri : String
  version : Int
  deriving Inhabited

instance : ToJson VersionedTextDocumentIdentifier where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("version", toJson s.version)]

instance : FromJson VersionedTextDocumentIdentifier where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let version ← json.getObjValAs? Int "version"
    return { uri, version }

/-- A text document identifier to optionally denote a specific version of a text document. -/
structure OptionalVersionedTextDocumentIdentifier where
  uri : String
  version : (Option Int)
  deriving Inhabited

instance : ToJson OptionalVersionedTextDocumentIdentifier where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("version", toJson s.version)]

instance : FromJson OptionalVersionedTextDocumentIdentifier where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let version ← json.getObjValAs? (Option Int) "version"
    return { uri, version }

/-- A parameter literal used in selection range requests. -/
structure SelectionRangeParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  positions : (Array Position)
  deriving Inhabited

instance : ToJson SelectionRangeParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("positions", toJson s.positions)]

instance : FromJson SelectionRangeParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let positions ← json.getObjValAs? (Array Position) "positions"
    return { workDoneToken, partialResultToken, textDocument, positions }

/-- A parameter literal used in requests to pass a text document and a position inside that document. -/
structure TextDocumentPositionParams where
  textDocument : TextDocumentIdentifier
  position : Position
  deriving Inhabited

instance : ToJson TextDocumentPositionParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)]

instance : FromJson TextDocumentPositionParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    return { textDocument, position }

/-- A range in a text document expressed as (zero-based) start and end positions.  If you want to specify a range that contains a line including the line ending character(s) then use an end position denoting the start of the next line. For example: ```ts {     start: { line: 5, character: 23 }     end :... -/
structure Range where
  start : Position
  «end» : Position
  deriving Inhabited

instance : ToJson Range where
  toJson s := Json.mkObj <|
    [("start", toJson s.start)] ++
    [("end", toJson s.«end»)]

instance : FromJson Range where
  fromJson? json := do
    let start ← json.getObjValAs? Position "start"
    let «end» ← json.getObjValAs? Position "end"
    return { start, «end» }

/-- @since 3.16.0 -/
structure SemanticTokensDelta where
  resultId : (Option String) := none
  edits : (Array SemanticTokensEdit)
  deriving Inhabited

instance : ToJson SemanticTokensDelta where
  toJson s := Json.mkObj <|
    (match s.resultId with | some v => [("resultId", toJson v)] | none => []) ++
    [("edits", toJson s.edits)]

instance : FromJson SemanticTokensDelta where
  fromJson? json := do
    let resultId := (json.getObjValAs? String "resultId").toOption
    let edits ← json.getObjValAs? (Array SemanticTokensEdit) "edits"
    return { resultId, edits }

/-- @since 3.16.0 -/
structure SemanticTokensDeltaPartialResult where
  edits : (Array SemanticTokensEdit)
  deriving Inhabited

instance : ToJson SemanticTokensDeltaPartialResult where
  toJson s := Json.mkObj <|
    [("edits", toJson s.edits)]

instance : FromJson SemanticTokensDeltaPartialResult where
  fromJson? json := do
    let edits ← json.getObjValAs? (Array SemanticTokensEdit) "edits"
    return { edits }

/-- The parameters sent in notifications/requests for user-initiated creation of files.  @since 3.16.0 -/
structure CreateFilesParams where
  files : (Array FileCreate)
  deriving Inhabited

instance : ToJson CreateFilesParams where
  toJson s := Json.mkObj <|
    [("files", toJson s.files)]

instance : FromJson CreateFilesParams where
  fromJson? json := do
    let files ← json.getObjValAs? (Array FileCreate) "files"
    return { files }

/-- The options to register for file operations.  @since 3.16.0 -/
structure FileOperationRegistrationOptions where
  filters : (Array FileOperationFilter)
  deriving Inhabited

instance : ToJson FileOperationRegistrationOptions where
  toJson s := Json.mkObj <|
    [("filters", toJson s.filters)]

instance : FromJson FileOperationRegistrationOptions where
  fromJson? json := do
    let filters ← json.getObjValAs? (Array FileOperationFilter) "filters"
    return { filters }

/-- The parameters sent in notifications/requests for user-initiated renames of files.  @since 3.16.0 -/
structure RenameFilesParams where
  files : (Array FileRename)
  deriving Inhabited

instance : ToJson RenameFilesParams where
  toJson s := Json.mkObj <|
    [("files", toJson s.files)]

instance : FromJson RenameFilesParams where
  fromJson? json := do
    let files ← json.getObjValAs? (Array FileRename) "files"
    return { files }

/-- The parameters sent in notifications/requests for user-initiated deletes of files.  @since 3.16.0 -/
structure DeleteFilesParams where
  files : (Array FileDelete)
  deriving Inhabited

instance : ToJson DeleteFilesParams where
  toJson s := Json.mkObj <|
    [("files", toJson s.files)]

instance : FromJson DeleteFilesParams where
  fromJson? json := do
    let files ← json.getObjValAs? (Array FileDelete) "files"
    return { files }

/-- Represents a parameter of a callable-signature. A parameter can have a label and a doc-comment. -/
structure ParameterInformation where
  label : Json
  documentation : Json := Json.null
  deriving Inhabited

instance : ToJson ParameterInformation where
  toJson s := Json.mkObj <|
    [("label", toJson s.label)] ++
    [("documentation", toJson s.documentation)]

instance : FromJson ParameterInformation where
  fromJson? json := do
    let label := json.getObjVal? "label" |>.toOption |>.getD Json.null
    let documentation := json.getObjVal? "documentation" |>.toOption |>.getD Json.null
    return { label, documentation }

/-- A full document diagnostic report for a workspace diagnostic result.  @since 3.17.0 -/
structure WorkspaceFullDocumentDiagnosticReport where
  kind : String
  resultId : (Option String) := none
  items : Json
  uri : String
  version : (Option Int)
  deriving Inhabited

instance : ToJson WorkspaceFullDocumentDiagnosticReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.resultId with | some v => [("resultId", toJson v)] | none => []) ++
    [("items", toJson s.items)] ++
    [("uri", toJson s.uri)] ++
    [("version", toJson s.version)]

instance : FromJson WorkspaceFullDocumentDiagnosticReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let resultId := (json.getObjValAs? String "resultId").toOption
    let items := json.getObjVal? "items" |>.toOption |>.getD Json.null
    let uri ← json.getObjValAs? String "uri"
    let version ← json.getObjValAs? (Option Int) "version"
    return { kind, resultId, items, uri, version }

/-- A partial result for a document diagnostic report.  @since 3.17.0 -/
structure DocumentDiagnosticReportPartialResult where
  relatedDocuments : Json
  deriving Inhabited

instance : ToJson DocumentDiagnosticReportPartialResult where
  toJson s := Json.mkObj <|
    [("relatedDocuments", toJson s.relatedDocuments)]

instance : FromJson DocumentDiagnosticReportPartialResult where
  fromJson? json := do
    let relatedDocuments := json.getObjVal? "relatedDocuments" |>.toOption |>.getD Json.null
    return { relatedDocuments }

/-- A full diagnostic report with a set of related documents.  @since 3.17.0 -/
structure RelatedFullDocumentDiagnosticReport where
  kind : String
  resultId : (Option String) := none
  items : Json
  relatedDocuments : Json := Json.null
  deriving Inhabited

instance : ToJson RelatedFullDocumentDiagnosticReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.resultId with | some v => [("resultId", toJson v)] | none => []) ++
    [("items", toJson s.items)] ++
    [("relatedDocuments", toJson s.relatedDocuments)]

instance : FromJson RelatedFullDocumentDiagnosticReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let resultId := (json.getObjValAs? String "resultId").toOption
    let items := json.getObjVal? "items" |>.toOption |>.getD Json.null
    let relatedDocuments := json.getObjVal? "relatedDocuments" |>.toOption |>.getD Json.null
    return { kind, resultId, items, relatedDocuments }

/-- An unchanged diagnostic report with a set of related documents.  @since 3.17.0 -/
structure RelatedUnchangedDocumentDiagnosticReport where
  kind : String
  resultId : String
  relatedDocuments : Json := Json.null
  deriving Inhabited

instance : ToJson RelatedUnchangedDocumentDiagnosticReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    [("resultId", toJson s.resultId)] ++
    [("relatedDocuments", toJson s.relatedDocuments)]

instance : FromJson RelatedUnchangedDocumentDiagnosticReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let resultId ← json.getObjValAs? String "resultId"
    let relatedDocuments := json.getObjVal? "relatedDocuments" |>.toOption |>.getD Json.null
    return { kind, resultId, relatedDocuments }

/-- An unchanged document diagnostic report for a workspace diagnostic result.  @since 3.17.0 -/
structure WorkspaceUnchangedDocumentDiagnosticReport where
  kind : String
  resultId : String
  uri : String
  version : (Option Int)
  deriving Inhabited

instance : ToJson WorkspaceUnchangedDocumentDiagnosticReport where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    [("resultId", toJson s.resultId)] ++
    [("uri", toJson s.uri)] ++
    [("version", toJson s.version)]

instance : FromJson WorkspaceUnchangedDocumentDiagnosticReport where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let resultId ← json.getObjValAs? String "resultId"
    let uri ← json.getObjValAs? String "uri"
    let version ← json.getObjValAs? (Option Int) "version"
    return { kind, resultId, uri, version }

/-- Parameters of the workspace diagnostic request.  @since 3.17.0 -/
structure WorkspaceDiagnosticParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  identifier : (Option String) := none
  previousResultIds : (Array PreviousResultId)
  deriving Inhabited

instance : ToJson WorkspaceDiagnosticParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    (match s.identifier with | some v => [("identifier", toJson v)] | none => []) ++
    [("previousResultIds", toJson s.previousResultIds)]

instance : FromJson WorkspaceDiagnosticParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let identifier := (json.getObjValAs? String "identifier").toOption
    let previousResultIds ← json.getObjValAs? (Array PreviousResultId) "previousResultIds"
    return { workDoneToken, partialResultToken, identifier, previousResultIds }

/-- The params sent in an open notebook document notification.  @since 3.17.0 -/
structure DidOpenNotebookDocumentParams where
  notebookDocument : NotebookDocument
  cellTextDocuments : (Array TextDocumentItem)
  deriving Inhabited

instance : ToJson DidOpenNotebookDocumentParams where
  toJson s := Json.mkObj <|
    [("notebookDocument", toJson s.notebookDocument)] ++
    [("cellTextDocuments", toJson s.cellTextDocuments)]

instance : FromJson DidOpenNotebookDocumentParams where
  fromJson? json := do
    let notebookDocument ← json.getObjValAs? NotebookDocument "notebookDocument"
    let cellTextDocuments ← json.getObjValAs? (Array TextDocumentItem) "cellTextDocuments"
    return { notebookDocument, cellTextDocuments }

/-- The parameters sent in an open text document notification -/
structure DidOpenTextDocumentParams where
  textDocument : TextDocumentItem
  deriving Inhabited

instance : ToJson DidOpenTextDocumentParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)]

instance : FromJson DidOpenTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentItem "textDocument"
    return { textDocument }

/-- The params sent in a save notebook document notification.  @since 3.17.0 -/
structure DidSaveNotebookDocumentParams where
  notebookDocument : NotebookDocumentIdentifier
  deriving Inhabited

instance : ToJson DidSaveNotebookDocumentParams where
  toJson s := Json.mkObj <|
    [("notebookDocument", toJson s.notebookDocument)]

instance : FromJson DidSaveNotebookDocumentParams where
  fromJson? json := do
    let notebookDocument ← json.getObjValAs? NotebookDocumentIdentifier "notebookDocument"
    return { notebookDocument }

/-- The params sent in a close notebook document notification.  @since 3.17.0 -/
structure DidCloseNotebookDocumentParams where
  notebookDocument : NotebookDocumentIdentifier
  cellTextDocuments : (Array TextDocumentIdentifier)
  deriving Inhabited

instance : ToJson DidCloseNotebookDocumentParams where
  toJson s := Json.mkObj <|
    [("notebookDocument", toJson s.notebookDocument)] ++
    [("cellTextDocuments", toJson s.cellTextDocuments)]

instance : FromJson DidCloseNotebookDocumentParams where
  fromJson? json := do
    let notebookDocument ← json.getObjValAs? NotebookDocumentIdentifier "notebookDocument"
    let cellTextDocuments ← json.getObjValAs? (Array TextDocumentIdentifier) "cellTextDocuments"
    return { notebookDocument, cellTextDocuments }

structure RegistrationParams where
  registrations : (Array Registration)
  deriving Inhabited

instance : ToJson RegistrationParams where
  toJson s := Json.mkObj <|
    [("registrations", toJson s.registrations)]

instance : FromJson RegistrationParams where
  fromJson? json := do
    let registrations ← json.getObjValAs? (Array Registration) "registrations"
    return { registrations }

structure UnregistrationParams where
  unregisterations : (Array Unregistration)
  deriving Inhabited

instance : ToJson UnregistrationParams where
  toJson s := Json.mkObj <|
    [("unregisterations", toJson s.unregisterations)]

instance : FromJson UnregistrationParams where
  fromJson? json := do
    let unregisterations ← json.getObjValAs? (Array Unregistration) "unregisterations"
    return { unregisterations }

/-- Save registration options. -/
structure TextDocumentSaveRegistrationOptions where
  documentSelector : (Option Json)
  includeText : (Option Bool) := none
  deriving Inhabited

instance : ToJson TextDocumentSaveRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.includeText with | some v => [("includeText", toJson v)] | none => [])

instance : FromJson TextDocumentSaveRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let includeText := (json.getObjValAs? Bool "includeText").toOption
    return { documentSelector, includeText }

structure TextDocumentSyncOptions where
  openClose : (Option Bool) := none
  change : (Option TextDocumentSyncKind) := none
  willSave : (Option Bool) := none
  willSaveWaitUntil : (Option Bool) := none
  save : Json := Json.null
  deriving Inhabited

instance : ToJson TextDocumentSyncOptions where
  toJson s := Json.mkObj <|
    (match s.openClose with | some v => [("openClose", toJson v)] | none => []) ++
    (match s.change with | some v => [("change", toJson v)] | none => []) ++
    (match s.willSave with | some v => [("willSave", toJson v)] | none => []) ++
    (match s.willSaveWaitUntil with | some v => [("willSaveWaitUntil", toJson v)] | none => []) ++
    [("save", toJson s.save)]

instance : FromJson TextDocumentSyncOptions where
  fromJson? json := do
    let openClose := (json.getObjValAs? Bool "openClose").toOption
    let change := (json.getObjValAs? TextDocumentSyncKind "change").toOption
    let willSave := (json.getObjValAs? Bool "willSave").toOption
    let willSaveWaitUntil := (json.getObjValAs? Bool "willSaveWaitUntil").toOption
    let save := json.getObjVal? "save" |>.toOption |>.getD Json.null
    return { openClose, change, willSave, willSaveWaitUntil, save }

/-- The watched files change notification's parameters. -/
structure DidChangeWatchedFilesParams where
  changes : (Array FileEvent)
  deriving Inhabited

instance : ToJson DidChangeWatchedFilesParams where
  toJson s := Json.mkObj <|
    [("changes", toJson s.changes)]

instance : FromJson DidChangeWatchedFilesParams where
  fromJson? json := do
    let changes ← json.getObjValAs? (Array FileEvent) "changes"
    return { changes }

/-- Describe options to be used when registered for text document change events. -/
structure DidChangeWatchedFilesRegistrationOptions where
  watchers : (Array FileSystemWatcher)
  deriving Inhabited

instance : ToJson DidChangeWatchedFilesRegistrationOptions where
  toJson s := Json.mkObj <|
    [("watchers", toJson s.watchers)]

instance : FromJson DidChangeWatchedFilesRegistrationOptions where
  fromJson? json := do
    let watchers ← json.getObjValAs? (Array FileSystemWatcher) "watchers"
    return { watchers }

/-- The parameters of a {@link DocumentFormattingRequest}. -/
structure DocumentFormattingParams where
  workDoneToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  options : FormattingOptions
  deriving Inhabited

instance : ToJson DocumentFormattingParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("options", toJson s.options)]

instance : FromJson DocumentFormattingParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let options ← json.getObjValAs? FormattingOptions "options"
    return { workDoneToken, textDocument, options }

/-- The parameters of a {@link DocumentOnTypeFormattingRequest}. -/
structure DocumentOnTypeFormattingParams where
  textDocument : TextDocumentIdentifier
  position : Position
  ch : String
  options : FormattingOptions
  deriving Inhabited

instance : ToJson DocumentOnTypeFormattingParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    [("ch", toJson s.ch)] ++
    [("options", toJson s.options)]

instance : FromJson DocumentOnTypeFormattingParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let ch ← json.getObjValAs? String "ch"
    let options ← json.getObjValAs? FormattingOptions "options"
    return { textDocument, position, ch, options }

/-- Registration options for a {@link DocumentOnTypeFormattingRequest}. -/
structure DocumentOnTypeFormattingRegistrationOptions where
  documentSelector : (Option Json)
  firstTriggerCharacter : String
  moreTriggerCharacter : (Option (Array String)) := none
  deriving Inhabited

instance : ToJson DocumentOnTypeFormattingRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    [("firstTriggerCharacter", toJson s.firstTriggerCharacter)] ++
    (match s.moreTriggerCharacter with | some v => [("moreTriggerCharacter", toJson v)] | none => [])

instance : FromJson DocumentOnTypeFormattingRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let firstTriggerCharacter ← json.getObjValAs? String "firstTriggerCharacter"
    let moreTriggerCharacter := (json.getObjValAs? (Array String) "moreTriggerCharacter").toOption
    return { documentSelector, firstTriggerCharacter, moreTriggerCharacter }

/-- @since 3.16.0 -/
structure SemanticTokensOptions where
  workDoneProgress : (Option Bool) := none
  legend : SemanticTokensLegend
  range : Json := Json.null
  full : Json := Json.null
  deriving Inhabited

instance : ToJson SemanticTokensOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    [("legend", toJson s.legend)] ++
    [("range", toJson s.range)] ++
    [("full", toJson s.full)]

instance : FromJson SemanticTokensOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let legend ← json.getObjValAs? SemanticTokensLegend "legend"
    let range := json.getObjVal? "range" |>.toOption |>.getD Json.null
    let full := json.getObjVal? "full" |>.toOption |>.getD Json.null
    return { workDoneProgress, legend, range, full }

/-- Create file operation. -/
structure CreateFile where
  kind : String
  annotationId : (Option ChangeAnnotationIdentifier) := none
  uri : String
  options : (Option CreateFileOptions) := none
  deriving Inhabited

instance : ToJson CreateFile where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.annotationId with | some v => [("annotationId", toJson v)] | none => []) ++
    [("uri", toJson s.uri)] ++
    (match s.options with | some v => [("options", toJson v)] | none => [])

instance : FromJson CreateFile where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let annotationId := (json.getObjValAs? ChangeAnnotationIdentifier "annotationId").toOption
    let uri ← json.getObjValAs? String "uri"
    let options := (json.getObjValAs? CreateFileOptions "options").toOption
    return { kind, annotationId, uri, options }

/-- Rename file operation -/
structure RenameFile where
  kind : String
  annotationId : (Option ChangeAnnotationIdentifier) := none
  oldUri : String
  newUri : String
  options : (Option RenameFileOptions) := none
  deriving Inhabited

instance : ToJson RenameFile where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.annotationId with | some v => [("annotationId", toJson v)] | none => []) ++
    [("oldUri", toJson s.oldUri)] ++
    [("newUri", toJson s.newUri)] ++
    (match s.options with | some v => [("options", toJson v)] | none => [])

instance : FromJson RenameFile where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let annotationId := (json.getObjValAs? ChangeAnnotationIdentifier "annotationId").toOption
    let oldUri ← json.getObjValAs? String "oldUri"
    let newUri ← json.getObjValAs? String "newUri"
    let options := (json.getObjValAs? RenameFileOptions "options").toOption
    return { kind, annotationId, oldUri, newUri, options }

/-- Delete file operation -/
structure DeleteFile where
  kind : String
  annotationId : (Option ChangeAnnotationIdentifier) := none
  uri : String
  options : (Option DeleteFileOptions) := none
  deriving Inhabited

instance : ToJson DeleteFile where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    (match s.annotationId with | some v => [("annotationId", toJson v)] | none => []) ++
    [("uri", toJson s.uri)] ++
    (match s.options with | some v => [("options", toJson v)] | none => [])

instance : FromJson DeleteFile where
  fromJson? json := do
    let kind ← json.getObjValAs? String "kind"
    let annotationId := (json.getObjValAs? ChangeAnnotationIdentifier "annotationId").toOption
    let uri ← json.getObjValAs? String "uri"
    let options := (json.getObjValAs? DeleteFileOptions "options").toOption
    return { kind, annotationId, uri, options }

/-- The initialize parameters -/
structure _InitializeParams where
  workDoneToken : (Option ProgressToken) := none
  processId : (Option Int)
  clientInfo : (Option ClientInfo) := none
  locale : (Option String) := none
  rootPath : (Option String) := none
  rootUri : (Option String)
  capabilities : Json
  initializationOptions : Json := Json.null
  trace : (Option TraceValue) := none
  deriving Inhabited

instance : ToJson _InitializeParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("processId", toJson s.processId)] ++
    (match s.clientInfo with | some v => [("clientInfo", toJson v)] | none => []) ++
    (match s.locale with | some v => [("locale", toJson v)] | none => []) ++
    (match s.rootPath with | some v => [("rootPath", toJson v)] | none => []) ++
    [("rootUri", toJson s.rootUri)] ++
    [("capabilities", toJson s.capabilities)] ++
    [("initializationOptions", toJson s.initializationOptions)] ++
    (match s.trace with | some v => [("trace", toJson v)] | none => [])

instance : FromJson _InitializeParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let processId ← json.getObjValAs? (Option Int) "processId"
    let clientInfo := (json.getObjValAs? ClientInfo "clientInfo").toOption
    let locale := (json.getObjValAs? String "locale").toOption
    let rootPath := (json.getObjValAs? String "rootPath").toOption
    let rootUri ← json.getObjValAs? (Option String) "rootUri"
    let capabilities := json.getObjVal? "capabilities" |>.toOption |>.getD Json.null
    let initializationOptions := json.getObjVal? "initializationOptions" |>.toOption |>.getD Json.null
    let trace := (json.getObjValAs? TraceValue "trace").toOption
    return { workDoneToken, processId, clientInfo, locale, rootPath, rootUri, capabilities, initializationOptions, trace }

/-- Completion options. -/
structure CompletionOptions where
  workDoneProgress : (Option Bool) := none
  triggerCharacters : (Option (Array String)) := none
  allCommitCharacters : (Option (Array String)) := none
  resolveProvider : (Option Bool) := none
  completionItem : (Option ServerCompletionItemOptions) := none
  deriving Inhabited

instance : ToJson CompletionOptions where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.triggerCharacters with | some v => [("triggerCharacters", toJson v)] | none => []) ++
    (match s.allCommitCharacters with | some v => [("allCommitCharacters", toJson v)] | none => []) ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => []) ++
    (match s.completionItem with | some v => [("completionItem", toJson v)] | none => [])

instance : FromJson CompletionOptions where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let triggerCharacters := (json.getObjValAs? (Array String) "triggerCharacters").toOption
    let allCommitCharacters := (json.getObjValAs? (Array String) "allCommitCharacters").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    let completionItem := (json.getObjValAs? ServerCompletionItemOptions "completionItem").toOption
    return { workDoneProgress, triggerCharacters, allCommitCharacters, resolveProvider, completionItem }

/-- A pattern to describe in which file operation requests or notifications the server is interested in receiving.  @since 3.16.0 -/
structure FileOperationPattern where
  glob : String
  «matches» : (Option FileOperationPatternKind) := none
  options : (Option FileOperationPatternOptions) := none
  deriving Inhabited

instance : ToJson FileOperationPattern where
  toJson s := Json.mkObj <|
    [("glob", toJson s.glob)] ++
    (match s.«matches» with | some v => [("matches", toJson v)] | none => []) ++
    (match s.options with | some v => [("options", toJson v)] | none => [])

instance : FromJson FileOperationPattern where
  fromJson? json := do
    let glob ← json.getObjValAs? String "glob"
    let «matches» := (json.getObjValAs? FileOperationPatternKind "matches").toOption
    let options := (json.getObjValAs? FileOperationPatternOptions "options").toOption
    return { glob, «matches», options }

/-- A notebook cell.  A cell's document URI must be unique across ALL notebook cells and can therefore be used to uniquely identify a notebook cell or the cell's text document.  @since 3.17.0 -/
structure NotebookCell where
  kind : NotebookCellKind
  document : String
  metadata : Json := Json.null
  executionSummary : (Option ExecutionSummary) := none
  deriving Inhabited

instance : ToJson NotebookCell where
  toJson s := Json.mkObj <|
    [("kind", toJson s.kind)] ++
    [("document", toJson s.document)] ++
    [("metadata", toJson s.metadata)] ++
    (match s.executionSummary with | some v => [("executionSummary", toJson v)] | none => [])

instance : FromJson NotebookCell where
  fromJson? json := do
    let kind ← json.getObjValAs? NotebookCellKind "kind"
    let document ← json.getObjValAs? String "document"
    let metadata := json.getObjVal? "metadata" |>.toOption |>.getD Json.null
    let executionSummary := (json.getObjValAs? ExecutionSummary "executionSummary").toOption
    return { kind, document, metadata, executionSummary }

/-- @since 3.18.0 -/
structure NotebookDocumentFilterWithNotebook where
  notebook : Json
  cells : (Option (Array NotebookCellLanguage)) := none
  deriving Inhabited

instance : ToJson NotebookDocumentFilterWithNotebook where
  toJson s := Json.mkObj <|
    [("notebook", toJson s.notebook)] ++
    (match s.cells with | some v => [("cells", toJson v)] | none => [])

instance : FromJson NotebookDocumentFilterWithNotebook where
  fromJson? json := do
    let notebook := json.getObjVal? "notebook" |>.toOption |>.getD Json.null
    let cells := (json.getObjValAs? (Array NotebookCellLanguage) "cells").toOption
    return { notebook, cells }

/-- @since 3.18.0 -/
structure NotebookDocumentFilterWithCells where
  notebook : Json := Json.null
  cells : (Array NotebookCellLanguage)
  deriving Inhabited

instance : ToJson NotebookDocumentFilterWithCells where
  toJson s := Json.mkObj <|
    [("notebook", toJson s.notebook)] ++
    [("cells", toJson s.cells)]

instance : FromJson NotebookDocumentFilterWithCells where
  fromJson? json := do
    let notebook := json.getObjVal? "notebook" |>.toOption |>.getD Json.null
    let cells ← json.getObjValAs? (Array NotebookCellLanguage) "cells"
    return { notebook, cells }

/-- Structural changes to cells in a notebook document.  @since 3.18.0 -/
structure NotebookDocumentCellChangeStructure where
  array : NotebookCellArrayChange
  didOpen : (Option (Array TextDocumentItem)) := none
  didClose : (Option (Array TextDocumentIdentifier)) := none
  deriving Inhabited

instance : ToJson NotebookDocumentCellChangeStructure where
  toJson s := Json.mkObj <|
    [("array", toJson s.array)] ++
    (match s.didOpen with | some v => [("didOpen", toJson v)] | none => []) ++
    (match s.didClose with | some v => [("didClose", toJson v)] | none => [])

instance : FromJson NotebookDocumentCellChangeStructure where
  fromJson? json := do
    let array ← json.getObjValAs? NotebookCellArrayChange "array"
    let didOpen := (json.getObjValAs? (Array TextDocumentItem) "didOpen").toOption
    let didClose := (json.getObjValAs? (Array TextDocumentIdentifier) "didClose").toOption
    return { array, didOpen, didClose }

/-- Capabilities specific to the notebook document support.  @since 3.17.0 -/
structure NotebookDocumentClientCapabilities where
  synchronization : NotebookDocumentSyncClientCapabilities
  deriving Inhabited

instance : ToJson NotebookDocumentClientCapabilities where
  toJson s := Json.mkObj <|
    [("synchronization", toJson s.synchronization)]

instance : FromJson NotebookDocumentClientCapabilities where
  fromJson? json := do
    let synchronization ← json.getObjValAs? NotebookDocumentSyncClientCapabilities "synchronization"
    return { synchronization }

/-- General client capabilities.  @since 3.16.0 -/
structure GeneralClientCapabilities where
  staleRequestSupport : (Option StaleRequestSupportOptions) := none
  regularExpressions : (Option RegularExpressionsClientCapabilities) := none
  markdown : (Option MarkdownClientCapabilities) := none
  positionEncodings : (Option (Array PositionEncodingKind)) := none
  deriving Inhabited

instance : ToJson GeneralClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.staleRequestSupport with | some v => [("staleRequestSupport", toJson v)] | none => []) ++
    (match s.regularExpressions with | some v => [("regularExpressions", toJson v)] | none => []) ++
    (match s.markdown with | some v => [("markdown", toJson v)] | none => []) ++
    (match s.positionEncodings with | some v => [("positionEncodings", toJson v)] | none => [])

instance : FromJson GeneralClientCapabilities where
  fromJson? json := do
    let staleRequestSupport := (json.getObjValAs? StaleRequestSupportOptions "staleRequestSupport").toOption
    let regularExpressions := (json.getObjValAs? RegularExpressionsClientCapabilities "regularExpressions").toOption
    let markdown := (json.getObjValAs? MarkdownClientCapabilities "markdown").toOption
    let positionEncodings := (json.getObjValAs? (Array PositionEncodingKind) "positionEncodings").toOption
    return { staleRequestSupport, regularExpressions, markdown, positionEncodings }

structure WorkspaceEditClientCapabilities where
  documentChanges : (Option Bool) := none
  resourceOperations : (Option (Array ResourceOperationKind)) := none
  failureHandling : (Option FailureHandlingKind) := none
  normalizesLineEndings : (Option Bool) := none
  changeAnnotationSupport : (Option ChangeAnnotationsSupportOptions) := none
  metadataSupport : (Option Bool) := none
  snippetEditSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson WorkspaceEditClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.documentChanges with | some v => [("documentChanges", toJson v)] | none => []) ++
    (match s.resourceOperations with | some v => [("resourceOperations", toJson v)] | none => []) ++
    (match s.failureHandling with | some v => [("failureHandling", toJson v)] | none => []) ++
    (match s.normalizesLineEndings with | some v => [("normalizesLineEndings", toJson v)] | none => []) ++
    (match s.changeAnnotationSupport with | some v => [("changeAnnotationSupport", toJson v)] | none => []) ++
    (match s.metadataSupport with | some v => [("metadataSupport", toJson v)] | none => []) ++
    (match s.snippetEditSupport with | some v => [("snippetEditSupport", toJson v)] | none => [])

instance : FromJson WorkspaceEditClientCapabilities where
  fromJson? json := do
    let documentChanges := (json.getObjValAs? Bool "documentChanges").toOption
    let resourceOperations := (json.getObjValAs? (Array ResourceOperationKind) "resourceOperations").toOption
    let failureHandling := (json.getObjValAs? FailureHandlingKind "failureHandling").toOption
    let normalizesLineEndings := (json.getObjValAs? Bool "normalizesLineEndings").toOption
    let changeAnnotationSupport := (json.getObjValAs? ChangeAnnotationsSupportOptions "changeAnnotationSupport").toOption
    let metadataSupport := (json.getObjValAs? Bool "metadataSupport").toOption
    let snippetEditSupport := (json.getObjValAs? Bool "snippetEditSupport").toOption
    return { documentChanges, resourceOperations, failureHandling, normalizesLineEndings, changeAnnotationSupport, metadataSupport, snippetEditSupport }

/-- Client Capabilities for a {@link DocumentSymbolRequest}. -/
structure DocumentSymbolClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  symbolKind : (Option ClientSymbolKindOptions) := none
  hierarchicalDocumentSymbolSupport : (Option Bool) := none
  tagSupport : (Option ClientSymbolTagOptions) := none
  labelSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentSymbolClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.symbolKind with | some v => [("symbolKind", toJson v)] | none => []) ++
    (match s.hierarchicalDocumentSymbolSupport with | some v => [("hierarchicalDocumentSymbolSupport", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => []) ++
    (match s.labelSupport with | some v => [("labelSupport", toJson v)] | none => [])

instance : FromJson DocumentSymbolClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let symbolKind := (json.getObjValAs? ClientSymbolKindOptions "symbolKind").toOption
    let hierarchicalDocumentSymbolSupport := (json.getObjValAs? Bool "hierarchicalDocumentSymbolSupport").toOption
    let tagSupport := (json.getObjValAs? ClientSymbolTagOptions "tagSupport").toOption
    let labelSupport := (json.getObjValAs? Bool "labelSupport").toOption
    return { dynamicRegistration, symbolKind, hierarchicalDocumentSymbolSupport, tagSupport, labelSupport }

/-- Client capabilities for a {@link WorkspaceSymbolRequest}. -/
structure WorkspaceSymbolClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  symbolKind : (Option ClientSymbolKindOptions) := none
  tagSupport : (Option ClientSymbolTagOptions) := none
  resolveSupport : (Option ClientSymbolResolveOptions) := none
  deriving Inhabited

instance : ToJson WorkspaceSymbolClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.symbolKind with | some v => [("symbolKind", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => []) ++
    (match s.resolveSupport with | some v => [("resolveSupport", toJson v)] | none => [])

instance : FromJson WorkspaceSymbolClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let symbolKind := (json.getObjValAs? ClientSymbolKindOptions "symbolKind").toOption
    let tagSupport := (json.getObjValAs? ClientSymbolTagOptions "tagSupport").toOption
    let resolveSupport := (json.getObjValAs? ClientSymbolResolveOptions "resolveSupport").toOption
    return { dynamicRegistration, symbolKind, tagSupport, resolveSupport }

/-- The client capabilities  of a {@link CodeLensRequest}. -/
structure CodeLensClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  resolveSupport : (Option ClientCodeLensResolveOptions) := none
  deriving Inhabited

instance : ToJson CodeLensClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.resolveSupport with | some v => [("resolveSupport", toJson v)] | none => [])

instance : FromJson CodeLensClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let resolveSupport := (json.getObjValAs? ClientCodeLensResolveOptions "resolveSupport").toOption
    return { dynamicRegistration, resolveSupport }

structure FoldingRangeClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  rangeLimit : (Option Nat) := none
  lineFoldingOnly : (Option Bool) := none
  foldingRangeKind : (Option ClientFoldingRangeKindOptions) := none
  foldingRange : (Option ClientFoldingRangeOptions) := none
  deriving Inhabited

instance : ToJson FoldingRangeClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.rangeLimit with | some v => [("rangeLimit", toJson v)] | none => []) ++
    (match s.lineFoldingOnly with | some v => [("lineFoldingOnly", toJson v)] | none => []) ++
    (match s.foldingRangeKind with | some v => [("foldingRangeKind", toJson v)] | none => []) ++
    (match s.foldingRange with | some v => [("foldingRange", toJson v)] | none => [])

instance : FromJson FoldingRangeClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let rangeLimit := (json.getObjValAs? Nat "rangeLimit").toOption
    let lineFoldingOnly := (json.getObjValAs? Bool "lineFoldingOnly").toOption
    let foldingRangeKind := (json.getObjValAs? ClientFoldingRangeKindOptions "foldingRangeKind").toOption
    let foldingRange := (json.getObjValAs? ClientFoldingRangeOptions "foldingRange").toOption
    return { dynamicRegistration, rangeLimit, lineFoldingOnly, foldingRangeKind, foldingRange }

/-- Inlay hint client capabilities.  @since 3.17.0 -/
structure InlayHintClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  resolveSupport : (Option ClientInlayHintResolveOptions) := none
  deriving Inhabited

instance : ToJson InlayHintClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.resolveSupport with | some v => [("resolveSupport", toJson v)] | none => [])

instance : FromJson InlayHintClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let resolveSupport := (json.getObjValAs? ClientInlayHintResolveOptions "resolveSupport").toOption
    return { dynamicRegistration, resolveSupport }

/-- Show message request client capabilities -/
structure ShowMessageRequestClientCapabilities where
  messageActionItem : (Option ClientShowMessageActionItemOptions) := none
  deriving Inhabited

instance : ToJson ShowMessageRequestClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.messageActionItem with | some v => [("messageActionItem", toJson v)] | none => [])

instance : FromJson ShowMessageRequestClientCapabilities where
  fromJson? json := do
    let messageActionItem := (json.getObjValAs? ClientShowMessageActionItemOptions "messageActionItem").toOption
    return { messageActionItem }

/-- @since 3.18.0 -/
structure ClientCompletionItemOptions where
  snippetSupport : (Option Bool) := none
  commitCharactersSupport : (Option Bool) := none
  documentationFormat : (Option (Array MarkupKind)) := none
  deprecatedSupport : (Option Bool) := none
  preselectSupport : (Option Bool) := none
  tagSupport : (Option CompletionItemTagOptions) := none
  insertReplaceSupport : (Option Bool) := none
  resolveSupport : (Option ClientCompletionItemResolveOptions) := none
  insertTextModeSupport : (Option ClientCompletionItemInsertTextModeOptions) := none
  labelDetailsSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson ClientCompletionItemOptions where
  toJson s := Json.mkObj <|
    (match s.snippetSupport with | some v => [("snippetSupport", toJson v)] | none => []) ++
    (match s.commitCharactersSupport with | some v => [("commitCharactersSupport", toJson v)] | none => []) ++
    (match s.documentationFormat with | some v => [("documentationFormat", toJson v)] | none => []) ++
    (match s.deprecatedSupport with | some v => [("deprecatedSupport", toJson v)] | none => []) ++
    (match s.preselectSupport with | some v => [("preselectSupport", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => []) ++
    (match s.insertReplaceSupport with | some v => [("insertReplaceSupport", toJson v)] | none => []) ++
    (match s.resolveSupport with | some v => [("resolveSupport", toJson v)] | none => []) ++
    (match s.insertTextModeSupport with | some v => [("insertTextModeSupport", toJson v)] | none => []) ++
    (match s.labelDetailsSupport with | some v => [("labelDetailsSupport", toJson v)] | none => [])

instance : FromJson ClientCompletionItemOptions where
  fromJson? json := do
    let snippetSupport := (json.getObjValAs? Bool "snippetSupport").toOption
    let commitCharactersSupport := (json.getObjValAs? Bool "commitCharactersSupport").toOption
    let documentationFormat := (json.getObjValAs? (Array MarkupKind) "documentationFormat").toOption
    let deprecatedSupport := (json.getObjValAs? Bool "deprecatedSupport").toOption
    let preselectSupport := (json.getObjValAs? Bool "preselectSupport").toOption
    let tagSupport := (json.getObjValAs? CompletionItemTagOptions "tagSupport").toOption
    let insertReplaceSupport := (json.getObjValAs? Bool "insertReplaceSupport").toOption
    let resolveSupport := (json.getObjValAs? ClientCompletionItemResolveOptions "resolveSupport").toOption
    let insertTextModeSupport := (json.getObjValAs? ClientCompletionItemInsertTextModeOptions "insertTextModeSupport").toOption
    let labelDetailsSupport := (json.getObjValAs? Bool "labelDetailsSupport").toOption
    return { snippetSupport, commitCharactersSupport, documentationFormat, deprecatedSupport, preselectSupport, tagSupport, insertReplaceSupport, resolveSupport, insertTextModeSupport, labelDetailsSupport }

/-- @since 3.18.0 -/
structure ClientSignatureInformationOptions where
  documentationFormat : (Option (Array MarkupKind)) := none
  parameterInformation : (Option ClientSignatureParameterInformationOptions) := none
  activeParameterSupport : (Option Bool) := none
  noActiveParameterSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson ClientSignatureInformationOptions where
  toJson s := Json.mkObj <|
    (match s.documentationFormat with | some v => [("documentationFormat", toJson v)] | none => []) ++
    (match s.parameterInformation with | some v => [("parameterInformation", toJson v)] | none => []) ++
    (match s.activeParameterSupport with | some v => [("activeParameterSupport", toJson v)] | none => []) ++
    (match s.noActiveParameterSupport with | some v => [("noActiveParameterSupport", toJson v)] | none => [])

instance : FromJson ClientSignatureInformationOptions where
  fromJson? json := do
    let documentationFormat := (json.getObjValAs? (Array MarkupKind) "documentationFormat").toOption
    let parameterInformation := (json.getObjValAs? ClientSignatureParameterInformationOptions "parameterInformation").toOption
    let activeParameterSupport := (json.getObjValAs? Bool "activeParameterSupport").toOption
    let noActiveParameterSupport := (json.getObjValAs? Bool "noActiveParameterSupport").toOption
    return { documentationFormat, parameterInformation, activeParameterSupport, noActiveParameterSupport }

/-- @since 3.18.0 -/
structure ClientCodeActionLiteralOptions where
  codeActionKind : ClientCodeActionKindOptions
  deriving Inhabited

instance : ToJson ClientCodeActionLiteralOptions where
  toJson s := Json.mkObj <|
    [("codeActionKind", toJson s.codeActionKind)]

instance : FromJson ClientCodeActionLiteralOptions where
  fromJson? json := do
    let codeActionKind ← json.getObjValAs? ClientCodeActionKindOptions "codeActionKind"
    return { codeActionKind }

/-- General diagnostics capabilities for pull and push model. -/
structure DiagnosticsCapabilities where
  relatedInformation : (Option Bool) := none
  tagSupport : (Option ClientDiagnosticsTagOptions) := none
  codeDescriptionSupport : (Option Bool) := none
  dataSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DiagnosticsCapabilities where
  toJson s := Json.mkObj <|
    (match s.relatedInformation with | some v => [("relatedInformation", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => []) ++
    (match s.codeDescriptionSupport with | some v => [("codeDescriptionSupport", toJson v)] | none => []) ++
    (match s.dataSupport with | some v => [("dataSupport", toJson v)] | none => [])

instance : FromJson DiagnosticsCapabilities where
  fromJson? json := do
    let relatedInformation := (json.getObjValAs? Bool "relatedInformation").toOption
    let tagSupport := (json.getObjValAs? ClientDiagnosticsTagOptions "tagSupport").toOption
    let codeDescriptionSupport := (json.getObjValAs? Bool "codeDescriptionSupport").toOption
    let dataSupport := (json.getObjValAs? Bool "dataSupport").toOption
    return { relatedInformation, tagSupport, codeDescriptionSupport, dataSupport }

/-- @since 3.18.0 -/
structure ClientSemanticTokensRequestOptions where
  range : Json := Json.null
  full : Json := Json.null
  deriving Inhabited

instance : ToJson ClientSemanticTokensRequestOptions where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("full", toJson s.full)]

instance : FromJson ClientSemanticTokensRequestOptions where
  fromJson? json := do
    let range := json.getObjVal? "range" |>.toOption |>.getD Json.null
    let full := json.getObjVal? "full" |>.toOption |>.getD Json.null
    return { range, full }

/-- The parameters of a `workspace/didChangeWorkspaceFolders` notification. -/
structure DidChangeWorkspaceFoldersParams where
  event : WorkspaceFoldersChangeEvent
  deriving Inhabited

instance : ToJson DidChangeWorkspaceFoldersParams where
  toJson s := Json.mkObj <|
    [("event", toJson s.event)]

instance : FromJson DidChangeWorkspaceFoldersParams where
  fromJson? json := do
    let event ← json.getObjValAs? WorkspaceFoldersChangeEvent "event"
    return { event }

structure ImplementationRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson ImplementationRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson ImplementationRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure TypeDefinitionRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson TypeDefinitionRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson TypeDefinitionRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure DocumentColorRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson DocumentColorRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson DocumentColorRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure FoldingRangeRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson FoldingRangeRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson FoldingRangeRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure DeclarationRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson DeclarationRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson DeclarationRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure SelectionRangeRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson SelectionRangeRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson SelectionRangeRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

/-- Call hierarchy options used during static or dynamic registration.  @since 3.16.0 -/
structure CallHierarchyRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson CallHierarchyRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson CallHierarchyRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure LinkedEditingRangeRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson LinkedEditingRangeRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson LinkedEditingRangeRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

structure MonikerRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson MonikerRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson MonikerRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Type hierarchy options used during static or dynamic registration.  @since 3.17.0 -/
structure TypeHierarchyRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson TypeHierarchyRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson TypeHierarchyRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

/-- Inline value options used during static or dynamic registration.  @since 3.17.0 -/
structure InlineValueRegistrationOptions where
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson InlineValueRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson InlineValueRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, id }

/-- Inlay hint options used during static or dynamic registration.  @since 3.17.0 -/
structure InlayHintRegistrationOptions where
  resolveProvider : (Option Bool) := none
  documentSelector : (Option Json)
  id : (Option String) := none
  deriving Inhabited

instance : ToJson InlayHintRegistrationOptions where
  toJson s := Json.mkObj <|
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => []) ++
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson InlayHintRegistrationOptions where
  fromJson? json := do
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let id := (json.getObjValAs? String "id").toOption
    return { resolveProvider, documentSelector, id }

/-- Diagnostic registration options.  @since 3.17.0 -/
structure DiagnosticRegistrationOptions where
  documentSelector : (Option Json)
  identifier : (Option String) := none
  interFileDependencies : Bool
  workspaceDiagnostics : Bool
  id : (Option String) := none
  deriving Inhabited

instance : ToJson DiagnosticRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.identifier with | some v => [("identifier", toJson v)] | none => []) ++
    [("interFileDependencies", toJson s.interFileDependencies)] ++
    [("workspaceDiagnostics", toJson s.workspaceDiagnostics)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson DiagnosticRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let identifier := (json.getObjValAs? String "identifier").toOption
    let interFileDependencies ← json.getObjValAs? Bool "interFileDependencies"
    let workspaceDiagnostics ← json.getObjValAs? Bool "workspaceDiagnostics"
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, identifier, interFileDependencies, workspaceDiagnostics, id }

/-- Registration options for a {@link HoverRequest}. -/
structure HoverRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson HoverRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson HoverRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Registration options for a {@link SignatureHelpRequest}. -/
structure SignatureHelpRegistrationOptions where
  documentSelector : (Option Json)
  triggerCharacters : (Option (Array String)) := none
  retriggerCharacters : (Option (Array String)) := none
  deriving Inhabited

instance : ToJson SignatureHelpRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.triggerCharacters with | some v => [("triggerCharacters", toJson v)] | none => []) ++
    (match s.retriggerCharacters with | some v => [("retriggerCharacters", toJson v)] | none => [])

instance : FromJson SignatureHelpRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let triggerCharacters := (json.getObjValAs? (Array String) "triggerCharacters").toOption
    let retriggerCharacters := (json.getObjValAs? (Array String) "retriggerCharacters").toOption
    return { documentSelector, triggerCharacters, retriggerCharacters }

/-- Registration options for a {@link DefinitionRequest}. -/
structure DefinitionRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson DefinitionRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson DefinitionRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Registration options for a {@link ReferencesRequest}. -/
structure ReferenceRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson ReferenceRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson ReferenceRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Registration options for a {@link DocumentHighlightRequest}. -/
structure DocumentHighlightRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson DocumentHighlightRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson DocumentHighlightRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Registration options for a {@link DocumentSymbolRequest}. -/
structure DocumentSymbolRegistrationOptions where
  documentSelector : (Option Json)
  label : (Option String) := none
  deriving Inhabited

instance : ToJson DocumentSymbolRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.label with | some v => [("label", toJson v)] | none => [])

instance : FromJson DocumentSymbolRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let label := (json.getObjValAs? String "label").toOption
    return { documentSelector, label }

/-- Registration options for a {@link CodeActionRequest}. -/
structure CodeActionRegistrationOptions where
  documentSelector : (Option Json)
  codeActionKinds : (Option (Array CodeActionKind)) := none
  documentation : Json := Json.null
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson CodeActionRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.codeActionKinds with | some v => [("codeActionKinds", toJson v)] | none => []) ++
    [("documentation", toJson s.documentation)] ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson CodeActionRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let codeActionKinds := (json.getObjValAs? (Array CodeActionKind) "codeActionKinds").toOption
    let documentation := json.getObjVal? "documentation" |>.toOption |>.getD Json.null
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { documentSelector, codeActionKinds, documentation, resolveProvider }

/-- Registration options for a {@link WorkspaceSymbolRequest}. -/
structure WorkspaceSymbolRegistrationOptions where
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson WorkspaceSymbolRegistrationOptions where
  toJson s := Json.mkObj <|
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson WorkspaceSymbolRegistrationOptions where
  fromJson? json := do
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { resolveProvider }

/-- Registration options for a {@link CodeLensRequest}. -/
structure CodeLensRegistrationOptions where
  documentSelector : (Option Json)
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson CodeLensRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson CodeLensRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { documentSelector, resolveProvider }

/-- Registration options for a {@link DocumentLinkRequest}. -/
structure DocumentLinkRegistrationOptions where
  documentSelector : (Option Json)
  resolveProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentLinkRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => [])

instance : FromJson DocumentLinkRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    return { documentSelector, resolveProvider }

/-- Registration options for a {@link DocumentFormattingRequest}. -/
structure DocumentFormattingRegistrationOptions where
  documentSelector : (Option Json)
  deriving Inhabited

instance : ToJson DocumentFormattingRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)]

instance : FromJson DocumentFormattingRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    return { documentSelector }

/-- Registration options for a {@link DocumentRangeFormattingRequest}. -/
structure DocumentRangeFormattingRegistrationOptions where
  documentSelector : (Option Json)
  rangesSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DocumentRangeFormattingRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.rangesSupport with | some v => [("rangesSupport", toJson v)] | none => [])

instance : FromJson DocumentRangeFormattingRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let rangesSupport := (json.getObjValAs? Bool "rangesSupport").toOption
    return { documentSelector, rangesSupport }

/-- Registration options for a {@link RenameRequest}. -/
structure RenameRegistrationOptions where
  documentSelector : (Option Json)
  prepareProvider : (Option Bool) := none
  deriving Inhabited

instance : ToJson RenameRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.prepareProvider with | some v => [("prepareProvider", toJson v)] | none => [])

instance : FromJson RenameRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let prepareProvider := (json.getObjValAs? Bool "prepareProvider").toOption
    return { documentSelector, prepareProvider }

/-- Registration options for a {@link ExecuteCommandRequest}. -/
structure ExecuteCommandRegistrationOptions where
  commands : (Array String)
  deriving Inhabited

instance : ToJson ExecuteCommandRegistrationOptions where
  toJson s := Json.mkObj <|
    [("commands", toJson s.commands)]

instance : FromJson ExecuteCommandRegistrationOptions where
  fromJson? json := do
    let commands ← json.getObjValAs? (Array String) "commands"
    return { commands }

/-- The change text document notification's parameters. -/
structure DidChangeTextDocumentParams where
  textDocument : VersionedTextDocumentIdentifier
  contentChanges : (Array TextDocumentContentChangeEvent)
  deriving Inhabited

instance : ToJson DidChangeTextDocumentParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("contentChanges", toJson s.contentChanges)]

instance : FromJson DidChangeTextDocumentParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? VersionedTextDocumentIdentifier "textDocument"
    let contentChanges ← json.getObjValAs? (Array TextDocumentContentChangeEvent) "contentChanges"
    return { textDocument, contentChanges }

/-- Content changes to a cell in a notebook document.  @since 3.18.0 -/
structure NotebookDocumentCellContentChanges where
  document : VersionedTextDocumentIdentifier
  changes : (Array TextDocumentContentChangeEvent)
  deriving Inhabited

instance : ToJson NotebookDocumentCellContentChanges where
  toJson s := Json.mkObj <|
    [("document", toJson s.document)] ++
    [("changes", toJson s.changes)]

instance : FromJson NotebookDocumentCellContentChanges where
  fromJson? json := do
    let document ← json.getObjValAs? VersionedTextDocumentIdentifier "document"
    let changes ← json.getObjValAs? (Array TextDocumentContentChangeEvent) "changes"
    return { document, changes }

structure ImplementationParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson ImplementationParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson ImplementationParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { textDocument, position, workDoneToken, partialResultToken }

structure TypeDefinitionParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson TypeDefinitionParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson TypeDefinitionParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { textDocument, position, workDoneToken, partialResultToken }

structure DeclarationParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson DeclarationParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson DeclarationParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { textDocument, position, workDoneToken, partialResultToken }

/-- The parameter of a `textDocument/prepareCallHierarchy` request.  @since 3.16.0 -/
structure CallHierarchyPrepareParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson CallHierarchyPrepareParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => [])

instance : FromJson CallHierarchyPrepareParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    return { textDocument, position, workDoneToken }

structure LinkedEditingRangeParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson LinkedEditingRangeParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => [])

instance : FromJson LinkedEditingRangeParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    return { textDocument, position, workDoneToken }

structure MonikerParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson MonikerParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson MonikerParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { textDocument, position, workDoneToken, partialResultToken }

/-- The parameter of a `textDocument/prepareTypeHierarchy` request.  @since 3.17.0 -/
structure TypeHierarchyPrepareParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson TypeHierarchyPrepareParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => [])

instance : FromJson TypeHierarchyPrepareParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    return { textDocument, position, workDoneToken }

/-- Completion parameters -/
structure CompletionParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  context : (Option CompletionContext) := none
  deriving Inhabited

instance : ToJson CompletionParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    (match s.context with | some v => [("context", toJson v)] | none => [])

instance : FromJson CompletionParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let context := (json.getObjValAs? CompletionContext "context").toOption
    return { textDocument, position, workDoneToken, partialResultToken, context }

/-- Parameters for a {@link HoverRequest}. -/
structure HoverParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson HoverParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => [])

instance : FromJson HoverParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    return { textDocument, position, workDoneToken }

/-- Parameters for a {@link DefinitionRequest}. -/
structure DefinitionParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson DefinitionParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson DefinitionParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { textDocument, position, workDoneToken, partialResultToken }

/-- Parameters for a {@link ReferencesRequest}. -/
structure ReferenceParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  context : ReferenceContext
  deriving Inhabited

instance : ToJson ReferenceParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("context", toJson s.context)]

instance : FromJson ReferenceParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let context ← json.getObjValAs? ReferenceContext "context"
    return { textDocument, position, workDoneToken, partialResultToken, context }

/-- Parameters for a {@link DocumentHighlightRequest}. -/
structure DocumentHighlightParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson DocumentHighlightParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => [])

instance : FromJson DocumentHighlightParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    return { textDocument, position, workDoneToken, partialResultToken }

/-- The parameters of a {@link RenameRequest}. -/
structure RenameParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  newName : String
  deriving Inhabited

instance : ToJson RenameParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("newName", toJson s.newName)]

instance : FromJson RenameParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let newName ← json.getObjValAs? String "newName"
    return { textDocument, position, workDoneToken, newName }

structure PrepareRenameParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  deriving Inhabited

instance : ToJson PrepareRenameParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => [])

instance : FromJson PrepareRenameParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    return { textDocument, position, workDoneToken }

/-- Represents a location inside a resource, such as a line inside a text file. -/
structure Location where
  uri : String
  range : Range
  deriving Inhabited

instance : ToJson Location where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    [("range", toJson s.range)]

instance : FromJson Location where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let range ← json.getObjValAs? Range "range"
    return { uri, range }

/-- Represents a color range from a document. -/
structure ColorInformation where
  range : Range
  color : Color
  deriving Inhabited

instance : ToJson ColorInformation where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("color", toJson s.color)]

instance : FromJson ColorInformation where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let color ← json.getObjValAs? Color "color"
    return { range, color }

/-- Parameters for a {@link ColorPresentationRequest}. -/
structure ColorPresentationParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  color : Color
  range : Range
  deriving Inhabited

instance : ToJson ColorPresentationParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("color", toJson s.color)] ++
    [("range", toJson s.range)]

instance : FromJson ColorPresentationParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let color ← json.getObjValAs? Color "color"
    let range ← json.getObjValAs? Range "range"
    return { workDoneToken, partialResultToken, textDocument, color, range }

/-- A selection range represents a part of a selection hierarchy. A selection range may have a parent selection range that contains it. -/
structure SelectionRange where
  range : Range
  parent : Json := Json.null
  deriving Inhabited

instance : ToJson SelectionRange where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("parent", toJson s.parent)]

instance : FromJson SelectionRange where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let parent := json.getObjVal? "parent" |>.toOption |>.getD Json.null
    return { range, parent }

/-- Represents programming constructs like functions or constructors in the context of call hierarchy.  @since 3.16.0 -/
structure CallHierarchyItem where
  name : String
  kind : SymbolKind
  tags : (Option (Array SymbolTag)) := none
  detail : (Option String) := none
  uri : String
  range : Range
  selectionRange : Range
  data : Json := Json.null
  deriving Inhabited

instance : ToJson CallHierarchyItem where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    [("kind", toJson s.kind)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.detail with | some v => [("detail", toJson v)] | none => []) ++
    [("uri", toJson s.uri)] ++
    [("range", toJson s.range)] ++
    [("selectionRange", toJson s.selectionRange)] ++
    [("data", toJson s.data)]

instance : FromJson CallHierarchyItem where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let kind ← json.getObjValAs? SymbolKind "kind"
    let tags := (json.getObjValAs? (Array SymbolTag) "tags").toOption
    let detail := (json.getObjValAs? String "detail").toOption
    let uri ← json.getObjValAs? String "uri"
    let range ← json.getObjValAs? Range "range"
    let selectionRange ← json.getObjValAs? Range "selectionRange"
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { name, kind, tags, detail, uri, range, selectionRange, data }

/-- @since 3.16.0 -/
structure SemanticTokensRangeParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  range : Range
  deriving Inhabited

instance : ToJson SemanticTokensRangeParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("range", toJson s.range)]

instance : FromJson SemanticTokensRangeParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let range ← json.getObjValAs? Range "range"
    return { workDoneToken, partialResultToken, textDocument, range }

/-- Params to show a resource in the UI.  @since 3.16.0 -/
structure ShowDocumentParams where
  uri : String
  external : (Option Bool) := none
  takeFocus : (Option Bool) := none
  selection : (Option Range) := none
  deriving Inhabited

instance : ToJson ShowDocumentParams where
  toJson s := Json.mkObj <|
    [("uri", toJson s.uri)] ++
    (match s.external with | some v => [("external", toJson v)] | none => []) ++
    (match s.takeFocus with | some v => [("takeFocus", toJson v)] | none => []) ++
    (match s.selection with | some v => [("selection", toJson v)] | none => [])

instance : FromJson ShowDocumentParams where
  fromJson? json := do
    let uri ← json.getObjValAs? String "uri"
    let external := (json.getObjValAs? Bool "external").toOption
    let takeFocus := (json.getObjValAs? Bool "takeFocus").toOption
    let selection := (json.getObjValAs? Range "selection").toOption
    return { uri, external, takeFocus, selection }

/-- The result of a linked editing range request.  @since 3.16.0 -/
structure LinkedEditingRanges where
  ranges : (Array Range)
  wordPattern : (Option String) := none
  deriving Inhabited

instance : ToJson LinkedEditingRanges where
  toJson s := Json.mkObj <|
    [("ranges", toJson s.ranges)] ++
    (match s.wordPattern with | some v => [("wordPattern", toJson v)] | none => [])

instance : FromJson LinkedEditingRanges where
  fromJson? json := do
    let ranges ← json.getObjValAs? (Array Range) "ranges"
    let wordPattern := (json.getObjValAs? String "wordPattern").toOption
    return { ranges, wordPattern }

/-- @since 3.17.0 -/
structure TypeHierarchyItem where
  name : String
  kind : SymbolKind
  tags : (Option (Array SymbolTag)) := none
  detail : (Option String) := none
  uri : String
  range : Range
  selectionRange : Range
  data : Json := Json.null
  deriving Inhabited

instance : ToJson TypeHierarchyItem where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    [("kind", toJson s.kind)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.detail with | some v => [("detail", toJson v)] | none => []) ++
    [("uri", toJson s.uri)] ++
    [("range", toJson s.range)] ++
    [("selectionRange", toJson s.selectionRange)] ++
    [("data", toJson s.data)]

instance : FromJson TypeHierarchyItem where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let kind ← json.getObjValAs? SymbolKind "kind"
    let tags := (json.getObjValAs? (Array SymbolTag) "tags").toOption
    let detail := (json.getObjValAs? String "detail").toOption
    let uri ← json.getObjValAs? String "uri"
    let range ← json.getObjValAs? Range "range"
    let selectionRange ← json.getObjValAs? Range "selectionRange"
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { name, kind, tags, detail, uri, range, selectionRange, data }

/-- A parameter literal used in inlay hint requests.  @since 3.17.0 -/
structure InlayHintParams where
  workDoneToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  range : Range
  deriving Inhabited

instance : ToJson InlayHintParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("range", toJson s.range)]

instance : FromJson InlayHintParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let range ← json.getObjValAs? Range "range"
    return { workDoneToken, textDocument, range }

/-- A text edit applicable to a text document. -/
structure TextEdit where
  range : Range
  newText : String
  deriving Inhabited

instance : ToJson TextEdit where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("newText", toJson s.newText)]

instance : FromJson TextEdit where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let newText ← json.getObjValAs? String "newText"
    return { range, newText }

/-- The result of a hover request. -/
structure Hover where
  contents : Json
  range : (Option Range) := none
  deriving Inhabited

instance : ToJson Hover where
  toJson s := Json.mkObj <|
    [("contents", toJson s.contents)] ++
    (match s.range with | some v => [("range", toJson v)] | none => [])

instance : FromJson Hover where
  fromJson? json := do
    let contents := json.getObjVal? "contents" |>.toOption |>.getD Json.null
    let range := (json.getObjValAs? Range "range").toOption
    return { contents, range }

/-- A document highlight is a range inside a text document which deserves special attention. Usually a document highlight is visualized by changing the background color of its range. -/
structure DocumentHighlight where
  range : Range
  kind : (Option DocumentHighlightKind) := none
  deriving Inhabited

instance : ToJson DocumentHighlight where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.kind with | some v => [("kind", toJson v)] | none => [])

instance : FromJson DocumentHighlight where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let kind := (json.getObjValAs? DocumentHighlightKind "kind").toOption
    return { range, kind }

/-- Represents programming constructs like variables, classes, interfaces etc. that appear in a document. Document symbols can be hierarchical and they have two ranges: one that encloses its definition and one that points to its most interesting range, e.g. the range of an identifier. -/
structure DocumentSymbol where
  name : String
  detail : (Option String) := none
  kind : SymbolKind
  tags : (Option (Array SymbolTag)) := none
  deprecated : (Option Bool) := none
  range : Range
  selectionRange : Range
  children : Json := Json.null
  deriving Inhabited

instance : ToJson DocumentSymbol where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    (match s.detail with | some v => [("detail", toJson v)] | none => []) ++
    [("kind", toJson s.kind)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.deprecated with | some v => [("deprecated", toJson v)] | none => []) ++
    [("range", toJson s.range)] ++
    [("selectionRange", toJson s.selectionRange)] ++
    [("children", toJson s.children)]

instance : FromJson DocumentSymbol where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let detail := (json.getObjValAs? String "detail").toOption
    let kind ← json.getObjValAs? SymbolKind "kind"
    let tags := (json.getObjValAs? (Array SymbolTag) "tags").toOption
    let deprecated := (json.getObjValAs? Bool "deprecated").toOption
    let range ← json.getObjValAs? Range "range"
    let selectionRange ← json.getObjValAs? Range "selectionRange"
    let children := json.getObjVal? "children" |>.toOption |>.getD Json.null
    return { name, detail, kind, tags, deprecated, range, selectionRange, children }

/-- The parameters of a {@link CodeActionRequest}. -/
structure CodeActionParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  range : Range
  context : CodeActionContext
  deriving Inhabited

instance : ToJson CodeActionParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("range", toJson s.range)] ++
    [("context", toJson s.context)]

instance : FromJson CodeActionParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let range ← json.getObjValAs? Range "range"
    let context ← json.getObjValAs? CodeActionContext "context"
    return { workDoneToken, partialResultToken, textDocument, range, context }

/-- A code lens represents a {@link Command command} that should be shown along with source text, like the number of references, a way to run tests, etc.  A code lens is _unresolved_ when no command is associated to it. For performance reasons the creation of a code lens and resolving should be done in ... -/
structure CodeLens where
  range : Range
  command : (Option Command) := none
  data : Json := Json.null
  deriving Inhabited

instance : ToJson CodeLens where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.command with | some v => [("command", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson CodeLens where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let command := (json.getObjValAs? Command "command").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { range, command, data }

/-- A document link is a range in a text document that links to an internal or external resource, like another text document or a web site. -/
structure DocumentLink where
  range : Range
  target : (Option String) := none
  tooltip : (Option String) := none
  data : Json := Json.null
  deriving Inhabited

instance : ToJson DocumentLink where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.target with | some v => [("target", toJson v)] | none => []) ++
    (match s.tooltip with | some v => [("tooltip", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson DocumentLink where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let target := (json.getObjValAs? String "target").toOption
    let tooltip := (json.getObjValAs? String "tooltip").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { range, target, tooltip, data }

/-- The parameters of a {@link DocumentRangeFormattingRequest}. -/
structure DocumentRangeFormattingParams where
  workDoneToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  range : Range
  options : FormattingOptions
  deriving Inhabited

instance : ToJson DocumentRangeFormattingParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("range", toJson s.range)] ++
    [("options", toJson s.options)]

instance : FromJson DocumentRangeFormattingParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let range ← json.getObjValAs? Range "range"
    let options ← json.getObjValAs? FormattingOptions "options"
    return { workDoneToken, textDocument, range, options }

/-- Represents the connection of two locations. Provides additional metadata over normal {@link Location locations}, including an origin range. -/
structure LocationLink where
  originSelectionRange : (Option Range) := none
  targetUri : String
  targetRange : Range
  targetSelectionRange : Range
  deriving Inhabited

instance : ToJson LocationLink where
  toJson s := Json.mkObj <|
    (match s.originSelectionRange with | some v => [("originSelectionRange", toJson v)] | none => []) ++
    [("targetUri", toJson s.targetUri)] ++
    [("targetRange", toJson s.targetRange)] ++
    [("targetSelectionRange", toJson s.targetSelectionRange)]

instance : FromJson LocationLink where
  fromJson? json := do
    let originSelectionRange := (json.getObjValAs? Range "originSelectionRange").toOption
    let targetUri ← json.getObjValAs? String "targetUri"
    let targetRange ← json.getObjValAs? Range "targetRange"
    let targetSelectionRange ← json.getObjValAs? Range "targetSelectionRange"
    return { originSelectionRange, targetUri, targetRange, targetSelectionRange }

/-- @since 3.17.0 -/
structure InlineValueContext where
  frameId : Int
  stoppedLocation : Range
  deriving Inhabited

instance : ToJson InlineValueContext where
  toJson s := Json.mkObj <|
    [("frameId", toJson s.frameId)] ++
    [("stoppedLocation", toJson s.stoppedLocation)]

instance : FromJson InlineValueContext where
  fromJson? json := do
    let frameId ← json.getObjValAs? Int "frameId"
    let stoppedLocation ← json.getObjValAs? Range "stoppedLocation"
    return { frameId, stoppedLocation }

/-- Provide inline value as text.  @since 3.17.0 -/
structure InlineValueText where
  range : Range
  text : String
  deriving Inhabited

instance : ToJson InlineValueText where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("text", toJson s.text)]

instance : FromJson InlineValueText where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let text ← json.getObjValAs? String "text"
    return { range, text }

/-- Provide inline value through a variable lookup. If only a range is specified, the variable name will be extracted from the underlying document. An optional variable name can be used to override the extracted name.  @since 3.17.0 -/
structure InlineValueVariableLookup where
  range : Range
  variableName : (Option String) := none
  caseSensitiveLookup : Bool
  deriving Inhabited

instance : ToJson InlineValueVariableLookup where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.variableName with | some v => [("variableName", toJson v)] | none => []) ++
    [("caseSensitiveLookup", toJson s.caseSensitiveLookup)]

instance : FromJson InlineValueVariableLookup where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let variableName := (json.getObjValAs? String "variableName").toOption
    let caseSensitiveLookup ← json.getObjValAs? Bool "caseSensitiveLookup"
    return { range, variableName, caseSensitiveLookup }

/-- Provide an inline value through an expression evaluation. If only a range is specified, the expression will be extracted from the underlying document. An optional expression can be used to override the extracted expression.  @since 3.17.0 -/
structure InlineValueEvaluatableExpression where
  range : Range
  expression : (Option String) := none
  deriving Inhabited

instance : ToJson InlineValueEvaluatableExpression where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.expression with | some v => [("expression", toJson v)] | none => [])

instance : FromJson InlineValueEvaluatableExpression where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let expression := (json.getObjValAs? String "expression").toOption
    return { range, expression }

/-- A special text edit to provide an insert and a replace operation.  @since 3.16.0 -/
structure InsertReplaceEdit where
  newText : String
  insert : Range
  replace : Range
  deriving Inhabited

instance : ToJson InsertReplaceEdit where
  toJson s := Json.mkObj <|
    [("newText", toJson s.newText)] ++
    [("insert", toJson s.insert)] ++
    [("replace", toJson s.replace)]

instance : FromJson InsertReplaceEdit where
  fromJson? json := do
    let newText ← json.getObjValAs? String "newText"
    let insert ← json.getObjValAs? Range "insert"
    let replace ← json.getObjValAs? Range "replace"
    return { newText, insert, replace }

/-- @since 3.18.0 -/
structure PrepareRenamePlaceholder where
  range : Range
  placeholder : String
  deriving Inhabited

instance : ToJson PrepareRenamePlaceholder where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("placeholder", toJson s.placeholder)]

instance : FromJson PrepareRenamePlaceholder where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let placeholder ← json.getObjValAs? String "placeholder"
    return { range, placeholder }

/-- @since 3.18.0 -/
structure TextDocumentContentChangePartial where
  range : Range
  rangeLength : (Option Nat) := none
  text : String
  deriving Inhabited

instance : ToJson TextDocumentContentChangePartial where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.rangeLength with | some v => [("rangeLength", toJson v)] | none => []) ++
    [("text", toJson s.text)]

instance : FromJson TextDocumentContentChangePartial where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let rangeLength := (json.getObjValAs? Nat "rangeLength").toOption
    let text ← json.getObjValAs? String "text"
    return { range, rangeLength, text }

/-- Edit range variant that includes ranges for insert and replace operations.  @since 3.18.0 -/
structure EditRangeWithInsertReplace where
  insert : Range
  replace : Range
  deriving Inhabited

instance : ToJson EditRangeWithInsertReplace where
  toJson s := Json.mkObj <|
    [("insert", toJson s.insert)] ++
    [("replace", toJson s.replace)]

instance : FromJson EditRangeWithInsertReplace where
  fromJson? json := do
    let insert ← json.getObjValAs? Range "insert"
    let replace ← json.getObjValAs? Range "replace"
    return { insert, replace }

/-- Options for notifications/requests for user operations on files.  @since 3.16.0 -/
structure FileOperationOptions where
  didCreate : (Option FileOperationRegistrationOptions) := none
  willCreate : (Option FileOperationRegistrationOptions) := none
  didRename : (Option FileOperationRegistrationOptions) := none
  willRename : (Option FileOperationRegistrationOptions) := none
  didDelete : (Option FileOperationRegistrationOptions) := none
  willDelete : (Option FileOperationRegistrationOptions) := none
  deriving Inhabited

instance : ToJson FileOperationOptions where
  toJson s := Json.mkObj <|
    (match s.didCreate with | some v => [("didCreate", toJson v)] | none => []) ++
    (match s.willCreate with | some v => [("willCreate", toJson v)] | none => []) ++
    (match s.didRename with | some v => [("didRename", toJson v)] | none => []) ++
    (match s.willRename with | some v => [("willRename", toJson v)] | none => []) ++
    (match s.didDelete with | some v => [("didDelete", toJson v)] | none => []) ++
    (match s.willDelete with | some v => [("willDelete", toJson v)] | none => [])

instance : FromJson FileOperationOptions where
  fromJson? json := do
    let didCreate := (json.getObjValAs? FileOperationRegistrationOptions "didCreate").toOption
    let willCreate := (json.getObjValAs? FileOperationRegistrationOptions "willCreate").toOption
    let didRename := (json.getObjValAs? FileOperationRegistrationOptions "didRename").toOption
    let willRename := (json.getObjValAs? FileOperationRegistrationOptions "willRename").toOption
    let didDelete := (json.getObjValAs? FileOperationRegistrationOptions "didDelete").toOption
    let willDelete := (json.getObjValAs? FileOperationRegistrationOptions "willDelete").toOption
    return { didCreate, willCreate, didRename, willRename, didDelete, willDelete }

/-- Represents the signature of something callable. A signature can have a label, like a function-name, a doc-comment, and a set of parameters. -/
structure SignatureInformation where
  label : String
  documentation : Json := Json.null
  parameters : (Option (Array ParameterInformation)) := none
  activeParameter : (Option Nat) := none
  deriving Inhabited

instance : ToJson SignatureInformation where
  toJson s := Json.mkObj <|
    [("label", toJson s.label)] ++
    [("documentation", toJson s.documentation)] ++
    (match s.parameters with | some v => [("parameters", toJson v)] | none => []) ++
    (match s.activeParameter with | some v => [("activeParameter", toJson v)] | none => [])

instance : FromJson SignatureInformation where
  fromJson? json := do
    let label ← json.getObjValAs? String "label"
    let documentation := json.getObjVal? "documentation" |>.toOption |>.getD Json.null
    let parameters := (json.getObjValAs? (Array ParameterInformation) "parameters").toOption
    let activeParameter := (json.getObjValAs? Nat "activeParameter").toOption
    return { label, documentation, parameters, activeParameter }

/-- @since 3.16.0 -/
structure SemanticTokensRegistrationOptions where
  documentSelector : (Option Json)
  legend : SemanticTokensLegend
  range : Json := Json.null
  full : Json := Json.null
  id : (Option String) := none
  deriving Inhabited

instance : ToJson SemanticTokensRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    [("legend", toJson s.legend)] ++
    [("range", toJson s.range)] ++
    [("full", toJson s.full)] ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson SemanticTokensRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let legend ← json.getObjValAs? SemanticTokensLegend "legend"
    let range := json.getObjVal? "range" |>.toOption |>.getD Json.null
    let full := json.getObjVal? "full" |>.toOption |>.getD Json.null
    let id := (json.getObjValAs? String "id").toOption
    return { documentSelector, legend, range, full, id }

structure InitializeParams where
  processId : (Option Int)
  clientInfo : (Option ClientInfo) := none
  locale : (Option String) := none
  rootPath : (Option String) := none
  rootUri : (Option String)
  capabilities : Json
  initializationOptions : Json := Json.null
  trace : (Option TraceValue) := none
  workspaceFolders : (Option (Array WorkspaceFolder)) := none
  deriving Inhabited

instance : ToJson InitializeParams where
  toJson s := Json.mkObj <|
    [("processId", toJson s.processId)] ++
    (match s.clientInfo with | some v => [("clientInfo", toJson v)] | none => []) ++
    (match s.locale with | some v => [("locale", toJson v)] | none => []) ++
    (match s.rootPath with | some v => [("rootPath", toJson v)] | none => []) ++
    [("rootUri", toJson s.rootUri)] ++
    [("capabilities", toJson s.capabilities)] ++
    [("initializationOptions", toJson s.initializationOptions)] ++
    (match s.trace with | some v => [("trace", toJson v)] | none => []) ++
    (match s.workspaceFolders with | some v => [("workspaceFolders", toJson v)] | none => [])

instance : FromJson InitializeParams where
  fromJson? json := do
    let processId ← json.getObjValAs? (Option Int) "processId"
    let clientInfo := (json.getObjValAs? ClientInfo "clientInfo").toOption
    let locale := (json.getObjValAs? String "locale").toOption
    let rootPath := (json.getObjValAs? String "rootPath").toOption
    let rootUri ← json.getObjValAs? (Option String) "rootUri"
    let capabilities := json.getObjVal? "capabilities" |>.toOption |>.getD Json.null
    let initializationOptions := json.getObjVal? "initializationOptions" |>.toOption |>.getD Json.null
    let trace := (json.getObjValAs? TraceValue "trace").toOption
    let workspaceFolders := (json.getObjValAs? (Array WorkspaceFolder) "workspaceFolders").toOption
    return { processId, clientInfo, locale, rootPath, rootUri, capabilities, initializationOptions, trace, workspaceFolders }

/-- Registration options for a {@link CompletionRequest}. -/
structure CompletionRegistrationOptions where
  documentSelector : (Option Json)
  triggerCharacters : (Option (Array String)) := none
  allCommitCharacters : (Option (Array String)) := none
  resolveProvider : (Option Bool) := none
  completionItem : (Option ServerCompletionItemOptions) := none
  deriving Inhabited

instance : ToJson CompletionRegistrationOptions where
  toJson s := Json.mkObj <|
    [("documentSelector", toJson s.documentSelector)] ++
    (match s.triggerCharacters with | some v => [("triggerCharacters", toJson v)] | none => []) ++
    (match s.allCommitCharacters with | some v => [("allCommitCharacters", toJson v)] | none => []) ++
    (match s.resolveProvider with | some v => [("resolveProvider", toJson v)] | none => []) ++
    (match s.completionItem with | some v => [("completionItem", toJson v)] | none => [])

instance : FromJson CompletionRegistrationOptions where
  fromJson? json := do
    let documentSelector ← json.getObjValAs? (Option Json) "documentSelector"
    let triggerCharacters := (json.getObjValAs? (Array String) "triggerCharacters").toOption
    let allCommitCharacters := (json.getObjValAs? (Array String) "allCommitCharacters").toOption
    let resolveProvider := (json.getObjValAs? Bool "resolveProvider").toOption
    let completionItem := (json.getObjValAs? ServerCompletionItemOptions "completionItem").toOption
    return { documentSelector, triggerCharacters, allCommitCharacters, resolveProvider, completionItem }

/-- Options specific to a notebook plus its cells to be synced to the server.  If a selector provides a notebook document filter but no cell selector all cells of a matching notebook document will be synced.  If a selector provides no notebook document filter but only a cell selector all notebook docume... -/
structure NotebookDocumentSyncOptions where
  notebookSelector : Json
  save : (Option Bool) := none
  deriving Inhabited

instance : ToJson NotebookDocumentSyncOptions where
  toJson s := Json.mkObj <|
    [("notebookSelector", toJson s.notebookSelector)] ++
    (match s.save with | some v => [("save", toJson v)] | none => [])

instance : FromJson NotebookDocumentSyncOptions where
  fromJson? json := do
    let notebookSelector := json.getObjVal? "notebookSelector" |>.toOption |>.getD Json.null
    let save := (json.getObjValAs? Bool "save").toOption
    return { notebookSelector, save }

/-- Workspace specific client capabilities. -/
structure WorkspaceClientCapabilities where
  applyEdit : (Option Bool) := none
  workspaceEdit : (Option WorkspaceEditClientCapabilities) := none
  didChangeConfiguration : (Option DidChangeConfigurationClientCapabilities) := none
  didChangeWatchedFiles : (Option DidChangeWatchedFilesClientCapabilities) := none
  symbol : (Option WorkspaceSymbolClientCapabilities) := none
  executeCommand : (Option ExecuteCommandClientCapabilities) := none
  workspaceFolders : (Option Bool) := none
  configuration : (Option Bool) := none
  semanticTokens : (Option SemanticTokensWorkspaceClientCapabilities) := none
  codeLens : (Option CodeLensWorkspaceClientCapabilities) := none
  fileOperations : (Option FileOperationClientCapabilities) := none
  inlineValue : (Option InlineValueWorkspaceClientCapabilities) := none
  inlayHint : (Option InlayHintWorkspaceClientCapabilities) := none
  diagnostics : (Option DiagnosticWorkspaceClientCapabilities) := none
  foldingRange : Json := Json.null
  textDocumentContent : Json := Json.null
  deriving Inhabited

instance : ToJson WorkspaceClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.applyEdit with | some v => [("applyEdit", toJson v)] | none => []) ++
    (match s.workspaceEdit with | some v => [("workspaceEdit", toJson v)] | none => []) ++
    (match s.didChangeConfiguration with | some v => [("didChangeConfiguration", toJson v)] | none => []) ++
    (match s.didChangeWatchedFiles with | some v => [("didChangeWatchedFiles", toJson v)] | none => []) ++
    (match s.symbol with | some v => [("symbol", toJson v)] | none => []) ++
    (match s.executeCommand with | some v => [("executeCommand", toJson v)] | none => []) ++
    (match s.workspaceFolders with | some v => [("workspaceFolders", toJson v)] | none => []) ++
    (match s.configuration with | some v => [("configuration", toJson v)] | none => []) ++
    (match s.semanticTokens with | some v => [("semanticTokens", toJson v)] | none => []) ++
    (match s.codeLens with | some v => [("codeLens", toJson v)] | none => []) ++
    (match s.fileOperations with | some v => [("fileOperations", toJson v)] | none => []) ++
    (match s.inlineValue with | some v => [("inlineValue", toJson v)] | none => []) ++
    (match s.inlayHint with | some v => [("inlayHint", toJson v)] | none => []) ++
    (match s.diagnostics with | some v => [("diagnostics", toJson v)] | none => []) ++
    [("foldingRange", toJson s.foldingRange)] ++
    [("textDocumentContent", toJson s.textDocumentContent)]

instance : FromJson WorkspaceClientCapabilities where
  fromJson? json := do
    let applyEdit := (json.getObjValAs? Bool "applyEdit").toOption
    let workspaceEdit := (json.getObjValAs? WorkspaceEditClientCapabilities "workspaceEdit").toOption
    let didChangeConfiguration := (json.getObjValAs? DidChangeConfigurationClientCapabilities "didChangeConfiguration").toOption
    let didChangeWatchedFiles := (json.getObjValAs? DidChangeWatchedFilesClientCapabilities "didChangeWatchedFiles").toOption
    let symbol := (json.getObjValAs? WorkspaceSymbolClientCapabilities "symbol").toOption
    let executeCommand := (json.getObjValAs? ExecuteCommandClientCapabilities "executeCommand").toOption
    let workspaceFolders := (json.getObjValAs? Bool "workspaceFolders").toOption
    let configuration := (json.getObjValAs? Bool "configuration").toOption
    let semanticTokens := (json.getObjValAs? SemanticTokensWorkspaceClientCapabilities "semanticTokens").toOption
    let codeLens := (json.getObjValAs? CodeLensWorkspaceClientCapabilities "codeLens").toOption
    let fileOperations := (json.getObjValAs? FileOperationClientCapabilities "fileOperations").toOption
    let inlineValue := (json.getObjValAs? InlineValueWorkspaceClientCapabilities "inlineValue").toOption
    let inlayHint := (json.getObjValAs? InlayHintWorkspaceClientCapabilities "inlayHint").toOption
    let diagnostics := (json.getObjValAs? DiagnosticWorkspaceClientCapabilities "diagnostics").toOption
    let foldingRange := json.getObjVal? "foldingRange" |>.toOption |>.getD Json.null
    let textDocumentContent := json.getObjVal? "textDocumentContent" |>.toOption |>.getD Json.null
    return { applyEdit, workspaceEdit, didChangeConfiguration, didChangeWatchedFiles, symbol, executeCommand, workspaceFolders, configuration, semanticTokens, codeLens, fileOperations, inlineValue, inlayHint, diagnostics, foldingRange, textDocumentContent }

structure WindowClientCapabilities where
  workDoneProgress : (Option Bool) := none
  showMessage : (Option ShowMessageRequestClientCapabilities) := none
  showDocument : (Option ShowDocumentClientCapabilities) := none
  deriving Inhabited

instance : ToJson WindowClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.workDoneProgress with | some v => [("workDoneProgress", toJson v)] | none => []) ++
    (match s.showMessage with | some v => [("showMessage", toJson v)] | none => []) ++
    (match s.showDocument with | some v => [("showDocument", toJson v)] | none => [])

instance : FromJson WindowClientCapabilities where
  fromJson? json := do
    let workDoneProgress := (json.getObjValAs? Bool "workDoneProgress").toOption
    let showMessage := (json.getObjValAs? ShowMessageRequestClientCapabilities "showMessage").toOption
    let showDocument := (json.getObjValAs? ShowDocumentClientCapabilities "showDocument").toOption
    return { workDoneProgress, showMessage, showDocument }

/-- Completion client capabilities -/
structure CompletionClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  completionItem : (Option ClientCompletionItemOptions) := none
  completionItemKind : (Option ClientCompletionItemOptionsKind) := none
  insertTextMode : (Option InsertTextMode) := none
  contextSupport : (Option Bool) := none
  completionList : (Option CompletionListCapabilities) := none
  deriving Inhabited

instance : ToJson CompletionClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.completionItem with | some v => [("completionItem", toJson v)] | none => []) ++
    (match s.completionItemKind with | some v => [("completionItemKind", toJson v)] | none => []) ++
    (match s.insertTextMode with | some v => [("insertTextMode", toJson v)] | none => []) ++
    (match s.contextSupport with | some v => [("contextSupport", toJson v)] | none => []) ++
    (match s.completionList with | some v => [("completionList", toJson v)] | none => [])

instance : FromJson CompletionClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let completionItem := (json.getObjValAs? ClientCompletionItemOptions "completionItem").toOption
    let completionItemKind := (json.getObjValAs? ClientCompletionItemOptionsKind "completionItemKind").toOption
    let insertTextMode := (json.getObjValAs? InsertTextMode "insertTextMode").toOption
    let contextSupport := (json.getObjValAs? Bool "contextSupport").toOption
    let completionList := (json.getObjValAs? CompletionListCapabilities "completionList").toOption
    return { dynamicRegistration, completionItem, completionItemKind, insertTextMode, contextSupport, completionList }

/-- Client Capabilities for a {@link SignatureHelpRequest}. -/
structure SignatureHelpClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  signatureInformation : (Option ClientSignatureInformationOptions) := none
  contextSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson SignatureHelpClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.signatureInformation with | some v => [("signatureInformation", toJson v)] | none => []) ++
    (match s.contextSupport with | some v => [("contextSupport", toJson v)] | none => [])

instance : FromJson SignatureHelpClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let signatureInformation := (json.getObjValAs? ClientSignatureInformationOptions "signatureInformation").toOption
    let contextSupport := (json.getObjValAs? Bool "contextSupport").toOption
    return { dynamicRegistration, signatureInformation, contextSupport }

/-- The Client Capabilities of a {@link CodeActionRequest}. -/
structure CodeActionClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  codeActionLiteralSupport : (Option ClientCodeActionLiteralOptions) := none
  isPreferredSupport : (Option Bool) := none
  disabledSupport : (Option Bool) := none
  dataSupport : (Option Bool) := none
  resolveSupport : (Option ClientCodeActionResolveOptions) := none
  honorsChangeAnnotations : (Option Bool) := none
  documentationSupport : (Option Bool) := none
  tagSupport : (Option CodeActionTagOptions) := none
  deriving Inhabited

instance : ToJson CodeActionClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.codeActionLiteralSupport with | some v => [("codeActionLiteralSupport", toJson v)] | none => []) ++
    (match s.isPreferredSupport with | some v => [("isPreferredSupport", toJson v)] | none => []) ++
    (match s.disabledSupport with | some v => [("disabledSupport", toJson v)] | none => []) ++
    (match s.dataSupport with | some v => [("dataSupport", toJson v)] | none => []) ++
    (match s.resolveSupport with | some v => [("resolveSupport", toJson v)] | none => []) ++
    (match s.honorsChangeAnnotations with | some v => [("honorsChangeAnnotations", toJson v)] | none => []) ++
    (match s.documentationSupport with | some v => [("documentationSupport", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => [])

instance : FromJson CodeActionClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let codeActionLiteralSupport := (json.getObjValAs? ClientCodeActionLiteralOptions "codeActionLiteralSupport").toOption
    let isPreferredSupport := (json.getObjValAs? Bool "isPreferredSupport").toOption
    let disabledSupport := (json.getObjValAs? Bool "disabledSupport").toOption
    let dataSupport := (json.getObjValAs? Bool "dataSupport").toOption
    let resolveSupport := (json.getObjValAs? ClientCodeActionResolveOptions "resolveSupport").toOption
    let honorsChangeAnnotations := (json.getObjValAs? Bool "honorsChangeAnnotations").toOption
    let documentationSupport := (json.getObjValAs? Bool "documentationSupport").toOption
    let tagSupport := (json.getObjValAs? CodeActionTagOptions "tagSupport").toOption
    return { dynamicRegistration, codeActionLiteralSupport, isPreferredSupport, disabledSupport, dataSupport, resolveSupport, honorsChangeAnnotations, documentationSupport, tagSupport }

/-- The publish diagnostic client capabilities. -/
structure PublishDiagnosticsClientCapabilities where
  relatedInformation : (Option Bool) := none
  tagSupport : (Option ClientDiagnosticsTagOptions) := none
  codeDescriptionSupport : (Option Bool) := none
  dataSupport : (Option Bool) := none
  versionSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson PublishDiagnosticsClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.relatedInformation with | some v => [("relatedInformation", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => []) ++
    (match s.codeDescriptionSupport with | some v => [("codeDescriptionSupport", toJson v)] | none => []) ++
    (match s.dataSupport with | some v => [("dataSupport", toJson v)] | none => []) ++
    (match s.versionSupport with | some v => [("versionSupport", toJson v)] | none => [])

instance : FromJson PublishDiagnosticsClientCapabilities where
  fromJson? json := do
    let relatedInformation := (json.getObjValAs? Bool "relatedInformation").toOption
    let tagSupport := (json.getObjValAs? ClientDiagnosticsTagOptions "tagSupport").toOption
    let codeDescriptionSupport := (json.getObjValAs? Bool "codeDescriptionSupport").toOption
    let dataSupport := (json.getObjValAs? Bool "dataSupport").toOption
    let versionSupport := (json.getObjValAs? Bool "versionSupport").toOption
    return { relatedInformation, tagSupport, codeDescriptionSupport, dataSupport, versionSupport }

/-- Client capabilities specific to diagnostic pull requests.  @since 3.17.0 -/
structure DiagnosticClientCapabilities where
  relatedInformation : (Option Bool) := none
  tagSupport : (Option ClientDiagnosticsTagOptions) := none
  codeDescriptionSupport : (Option Bool) := none
  dataSupport : (Option Bool) := none
  dynamicRegistration : (Option Bool) := none
  relatedDocumentSupport : (Option Bool) := none
  deriving Inhabited

instance : ToJson DiagnosticClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.relatedInformation with | some v => [("relatedInformation", toJson v)] | none => []) ++
    (match s.tagSupport with | some v => [("tagSupport", toJson v)] | none => []) ++
    (match s.codeDescriptionSupport with | some v => [("codeDescriptionSupport", toJson v)] | none => []) ++
    (match s.dataSupport with | some v => [("dataSupport", toJson v)] | none => []) ++
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    (match s.relatedDocumentSupport with | some v => [("relatedDocumentSupport", toJson v)] | none => [])

instance : FromJson DiagnosticClientCapabilities where
  fromJson? json := do
    let relatedInformation := (json.getObjValAs? Bool "relatedInformation").toOption
    let tagSupport := (json.getObjValAs? ClientDiagnosticsTagOptions "tagSupport").toOption
    let codeDescriptionSupport := (json.getObjValAs? Bool "codeDescriptionSupport").toOption
    let dataSupport := (json.getObjValAs? Bool "dataSupport").toOption
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let relatedDocumentSupport := (json.getObjValAs? Bool "relatedDocumentSupport").toOption
    return { relatedInformation, tagSupport, codeDescriptionSupport, dataSupport, dynamicRegistration, relatedDocumentSupport }

/-- @since 3.16.0 -/
structure SemanticTokensClientCapabilities where
  dynamicRegistration : (Option Bool) := none
  requests : ClientSemanticTokensRequestOptions
  tokenTypes : (Array String)
  tokenModifiers : (Array String)
  formats : (Array TokenFormat)
  overlappingTokenSupport : (Option Bool) := none
  multilineTokenSupport : (Option Bool) := none
  serverCancelSupport : (Option Bool) := none
  augmentsSyntaxTokens : (Option Bool) := none
  deriving Inhabited

instance : ToJson SemanticTokensClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.dynamicRegistration with | some v => [("dynamicRegistration", toJson v)] | none => []) ++
    [("requests", toJson s.requests)] ++
    [("tokenTypes", toJson s.tokenTypes)] ++
    [("tokenModifiers", toJson s.tokenModifiers)] ++
    [("formats", toJson s.formats)] ++
    (match s.overlappingTokenSupport with | some v => [("overlappingTokenSupport", toJson v)] | none => []) ++
    (match s.multilineTokenSupport with | some v => [("multilineTokenSupport", toJson v)] | none => []) ++
    (match s.serverCancelSupport with | some v => [("serverCancelSupport", toJson v)] | none => []) ++
    (match s.augmentsSyntaxTokens with | some v => [("augmentsSyntaxTokens", toJson v)] | none => [])

instance : FromJson SemanticTokensClientCapabilities where
  fromJson? json := do
    let dynamicRegistration := (json.getObjValAs? Bool "dynamicRegistration").toOption
    let requests ← json.getObjValAs? ClientSemanticTokensRequestOptions "requests"
    let tokenTypes ← json.getObjValAs? (Array String) "tokenTypes"
    let tokenModifiers ← json.getObjValAs? (Array String) "tokenModifiers"
    let formats ← json.getObjValAs? (Array TokenFormat) "formats"
    let overlappingTokenSupport := (json.getObjValAs? Bool "overlappingTokenSupport").toOption
    let multilineTokenSupport := (json.getObjValAs? Bool "multilineTokenSupport").toOption
    let serverCancelSupport := (json.getObjValAs? Bool "serverCancelSupport").toOption
    let augmentsSyntaxTokens := (json.getObjValAs? Bool "augmentsSyntaxTokens").toOption
    return { dynamicRegistration, requests, tokenTypes, tokenModifiers, formats, overlappingTokenSupport, multilineTokenSupport, serverCancelSupport, augmentsSyntaxTokens }

/-- Cell changes to a notebook document.  @since 3.18.0 -/
structure NotebookDocumentCellChanges where
  «structure» : (Option NotebookDocumentCellChangeStructure) := none
  data : Json := Json.null
  textContent : (Option (Array NotebookDocumentCellContentChanges)) := none
  deriving Inhabited

instance : ToJson NotebookDocumentCellChanges where
  toJson s := Json.mkObj <|
    (match s.«structure» with | some v => [("structure", toJson v)] | none => []) ++
    [("data", toJson s.data)] ++
    (match s.textContent with | some v => [("textContent", toJson v)] | none => [])

instance : FromJson NotebookDocumentCellChanges where
  fromJson? json := do
    let «structure» := (json.getObjValAs? NotebookDocumentCellChangeStructure "structure").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    let textContent := (json.getObjValAs? (Array NotebookDocumentCellContentChanges) "textContent").toOption
    return { «structure», data, textContent }

/-- Represents information about programming constructs like variables, classes, interfaces etc. -/
structure SymbolInformation where
  name : String
  kind : SymbolKind
  tags : (Option (Array SymbolTag)) := none
  containerName : (Option String) := none
  deprecated : (Option Bool) := none
  location : Location
  deriving Inhabited

instance : ToJson SymbolInformation where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    [("kind", toJson s.kind)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.containerName with | some v => [("containerName", toJson v)] | none => []) ++
    (match s.deprecated with | some v => [("deprecated", toJson v)] | none => []) ++
    [("location", toJson s.location)]

instance : FromJson SymbolInformation where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let kind ← json.getObjValAs? SymbolKind "kind"
    let tags := (json.getObjValAs? (Array SymbolTag) "tags").toOption
    let containerName := (json.getObjValAs? String "containerName").toOption
    let deprecated := (json.getObjValAs? Bool "deprecated").toOption
    let location ← json.getObjValAs? Location "location"
    return { name, kind, tags, containerName, deprecated, location }

/-- A special workspace symbol that supports locations without a range.  See also SymbolInformation.  @since 3.17.0 -/
structure WorkspaceSymbol where
  name : String
  kind : SymbolKind
  tags : (Option (Array SymbolTag)) := none
  containerName : (Option String) := none
  location : Json
  data : Json := Json.null
  deriving Inhabited

instance : ToJson WorkspaceSymbol where
  toJson s := Json.mkObj <|
    [("name", toJson s.name)] ++
    [("kind", toJson s.kind)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.containerName with | some v => [("containerName", toJson v)] | none => []) ++
    [("location", toJson s.location)] ++
    [("data", toJson s.data)]

instance : FromJson WorkspaceSymbol where
  fromJson? json := do
    let name ← json.getObjValAs? String "name"
    let kind ← json.getObjValAs? SymbolKind "kind"
    let tags := (json.getObjValAs? (Array SymbolTag) "tags").toOption
    let containerName := (json.getObjValAs? String "containerName").toOption
    let location := json.getObjVal? "location" |>.toOption |>.getD Json.null
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { name, kind, tags, containerName, location, data }

/-- An inlay hint label part allows for interactive and composite labels of inlay hints.  @since 3.17.0 -/
structure InlayHintLabelPart where
  value : String
  tooltip : Json := Json.null
  location : (Option Location) := none
  command : (Option Command) := none
  deriving Inhabited

instance : ToJson InlayHintLabelPart where
  toJson s := Json.mkObj <|
    [("value", toJson s.value)] ++
    [("tooltip", toJson s.tooltip)] ++
    (match s.location with | some v => [("location", toJson v)] | none => []) ++
    (match s.command with | some v => [("command", toJson v)] | none => [])

instance : FromJson InlayHintLabelPart where
  fromJson? json := do
    let value ← json.getObjValAs? String "value"
    let tooltip := json.getObjVal? "tooltip" |>.toOption |>.getD Json.null
    let location := (json.getObjValAs? Location "location").toOption
    let command := (json.getObjValAs? Command "command").toOption
    return { value, tooltip, location, command }

/-- Represents a related message and source code location for a diagnostic. This should be used to point to code locations that cause or related to a diagnostics, e.g when duplicating a symbol in a scope. -/
structure DiagnosticRelatedInformation where
  location : Location
  message : String
  deriving Inhabited

instance : ToJson DiagnosticRelatedInformation where
  toJson s := Json.mkObj <|
    [("location", toJson s.location)] ++
    [("message", toJson s.message)]

instance : FromJson DiagnosticRelatedInformation where
  fromJson? json := do
    let location ← json.getObjValAs? Location "location"
    let message ← json.getObjValAs? String "message"
    return { location, message }

/-- The parameter of a `callHierarchy/incomingCalls` request.  @since 3.16.0 -/
structure CallHierarchyIncomingCallsParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  item : CallHierarchyItem
  deriving Inhabited

instance : ToJson CallHierarchyIncomingCallsParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("item", toJson s.item)]

instance : FromJson CallHierarchyIncomingCallsParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let item ← json.getObjValAs? CallHierarchyItem "item"
    return { workDoneToken, partialResultToken, item }

/-- Represents an incoming call, e.g. a caller of a method or constructor.  @since 3.16.0 -/
structure CallHierarchyIncomingCall where
  «from» : CallHierarchyItem
  fromRanges : (Array Range)
  deriving Inhabited

instance : ToJson CallHierarchyIncomingCall where
  toJson s := Json.mkObj <|
    [("from", toJson s.«from»)] ++
    [("fromRanges", toJson s.fromRanges)]

instance : FromJson CallHierarchyIncomingCall where
  fromJson? json := do
    let «from» ← json.getObjValAs? CallHierarchyItem "from"
    let fromRanges ← json.getObjValAs? (Array Range) "fromRanges"
    return { «from», fromRanges }

/-- The parameter of a `callHierarchy/outgoingCalls` request.  @since 3.16.0 -/
structure CallHierarchyOutgoingCallsParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  item : CallHierarchyItem
  deriving Inhabited

instance : ToJson CallHierarchyOutgoingCallsParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("item", toJson s.item)]

instance : FromJson CallHierarchyOutgoingCallsParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let item ← json.getObjValAs? CallHierarchyItem "item"
    return { workDoneToken, partialResultToken, item }

/-- Represents an outgoing call, e.g. calling a getter from a method or a method from a constructor etc.  @since 3.16.0 -/
structure CallHierarchyOutgoingCall where
  to : CallHierarchyItem
  fromRanges : (Array Range)
  deriving Inhabited

instance : ToJson CallHierarchyOutgoingCall where
  toJson s := Json.mkObj <|
    [("to", toJson s.to)] ++
    [("fromRanges", toJson s.fromRanges)]

instance : FromJson CallHierarchyOutgoingCall where
  fromJson? json := do
    let to ← json.getObjValAs? CallHierarchyItem "to"
    let fromRanges ← json.getObjValAs? (Array Range) "fromRanges"
    return { to, fromRanges }

/-- The parameter of a `typeHierarchy/supertypes` request.  @since 3.17.0 -/
structure TypeHierarchySupertypesParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  item : TypeHierarchyItem
  deriving Inhabited

instance : ToJson TypeHierarchySupertypesParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("item", toJson s.item)]

instance : FromJson TypeHierarchySupertypesParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let item ← json.getObjValAs? TypeHierarchyItem "item"
    return { workDoneToken, partialResultToken, item }

/-- The parameter of a `typeHierarchy/subtypes` request.  @since 3.17.0 -/
structure TypeHierarchySubtypesParams where
  workDoneToken : (Option ProgressToken) := none
  partialResultToken : (Option ProgressToken) := none
  item : TypeHierarchyItem
  deriving Inhabited

instance : ToJson TypeHierarchySubtypesParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.partialResultToken with | some v => [("partialResultToken", toJson v)] | none => []) ++
    [("item", toJson s.item)]

instance : FromJson TypeHierarchySubtypesParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let partialResultToken := (json.getObjValAs? ProgressToken "partialResultToken").toOption
    let item ← json.getObjValAs? TypeHierarchyItem "item"
    return { workDoneToken, partialResultToken, item }

structure ColorPresentation where
  label : String
  textEdit : (Option TextEdit) := none
  additionalTextEdits : (Option (Array TextEdit)) := none
  deriving Inhabited

instance : ToJson ColorPresentation where
  toJson s := Json.mkObj <|
    [("label", toJson s.label)] ++
    (match s.textEdit with | some v => [("textEdit", toJson v)] | none => []) ++
    (match s.additionalTextEdits with | some v => [("additionalTextEdits", toJson v)] | none => [])

instance : FromJson ColorPresentation where
  fromJson? json := do
    let label ← json.getObjValAs? String "label"
    let textEdit := (json.getObjValAs? TextEdit "textEdit").toOption
    let additionalTextEdits := (json.getObjValAs? (Array TextEdit) "additionalTextEdits").toOption
    return { label, textEdit, additionalTextEdits }

/-- A special text edit with an additional change annotation.  @since 3.16.0. -/
structure AnnotatedTextEdit where
  range : Range
  newText : String
  annotationId : ChangeAnnotationIdentifier
  deriving Inhabited

instance : ToJson AnnotatedTextEdit where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    [("newText", toJson s.newText)] ++
    [("annotationId", toJson s.annotationId)]

instance : FromJson AnnotatedTextEdit where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let newText ← json.getObjValAs? String "newText"
    let annotationId ← json.getObjValAs? ChangeAnnotationIdentifier "annotationId"
    return { range, newText, annotationId }

/-- A parameter literal used in inline value requests.  @since 3.17.0 -/
structure InlineValueParams where
  workDoneToken : (Option ProgressToken) := none
  textDocument : TextDocumentIdentifier
  range : Range
  context : InlineValueContext
  deriving Inhabited

instance : ToJson InlineValueParams where
  toJson s := Json.mkObj <|
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    [("textDocument", toJson s.textDocument)] ++
    [("range", toJson s.range)] ++
    [("context", toJson s.context)]

instance : FromJson InlineValueParams where
  fromJson? json := do
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let range ← json.getObjValAs? Range "range"
    let context ← json.getObjValAs? InlineValueContext "context"
    return { workDoneToken, textDocument, range, context }

/-- A completion item represents a text snippet that is proposed to complete text that is being typed. -/
structure CompletionItem where
  label : String
  labelDetails : (Option CompletionItemLabelDetails) := none
  kind : (Option CompletionItemKind) := none
  tags : (Option (Array CompletionItemTag)) := none
  detail : (Option String) := none
  documentation : Json := Json.null
  deprecated : (Option Bool) := none
  preselect : (Option Bool) := none
  sortText : (Option String) := none
  filterText : (Option String) := none
  insertText : (Option String) := none
  insertTextFormat : (Option InsertTextFormat) := none
  insertTextMode : (Option InsertTextMode) := none
  textEdit : Json := Json.null
  textEditText : (Option String) := none
  additionalTextEdits : (Option (Array TextEdit)) := none
  commitCharacters : (Option (Array String)) := none
  command : (Option Command) := none
  data : Json := Json.null
  deriving Inhabited

instance : ToJson CompletionItem where
  toJson s := Json.mkObj <|
    [("label", toJson s.label)] ++
    (match s.labelDetails with | some v => [("labelDetails", toJson v)] | none => []) ++
    (match s.kind with | some v => [("kind", toJson v)] | none => []) ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.detail with | some v => [("detail", toJson v)] | none => []) ++
    [("documentation", toJson s.documentation)] ++
    (match s.deprecated with | some v => [("deprecated", toJson v)] | none => []) ++
    (match s.preselect with | some v => [("preselect", toJson v)] | none => []) ++
    (match s.sortText with | some v => [("sortText", toJson v)] | none => []) ++
    (match s.filterText with | some v => [("filterText", toJson v)] | none => []) ++
    (match s.insertText with | some v => [("insertText", toJson v)] | none => []) ++
    (match s.insertTextFormat with | some v => [("insertTextFormat", toJson v)] | none => []) ++
    (match s.insertTextMode with | some v => [("insertTextMode", toJson v)] | none => []) ++
    [("textEdit", toJson s.textEdit)] ++
    (match s.textEditText with | some v => [("textEditText", toJson v)] | none => []) ++
    (match s.additionalTextEdits with | some v => [("additionalTextEdits", toJson v)] | none => []) ++
    (match s.commitCharacters with | some v => [("commitCharacters", toJson v)] | none => []) ++
    (match s.command with | some v => [("command", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson CompletionItem where
  fromJson? json := do
    let label ← json.getObjValAs? String "label"
    let labelDetails := (json.getObjValAs? CompletionItemLabelDetails "labelDetails").toOption
    let kind := (json.getObjValAs? CompletionItemKind "kind").toOption
    let tags := (json.getObjValAs? (Array CompletionItemTag) "tags").toOption
    let detail := (json.getObjValAs? String "detail").toOption
    let documentation := json.getObjVal? "documentation" |>.toOption |>.getD Json.null
    let deprecated := (json.getObjValAs? Bool "deprecated").toOption
    let preselect := (json.getObjValAs? Bool "preselect").toOption
    let sortText := (json.getObjValAs? String "sortText").toOption
    let filterText := (json.getObjValAs? String "filterText").toOption
    let insertText := (json.getObjValAs? String "insertText").toOption
    let insertTextFormat := (json.getObjValAs? InsertTextFormat "insertTextFormat").toOption
    let insertTextMode := (json.getObjValAs? InsertTextMode "insertTextMode").toOption
    let textEdit := json.getObjVal? "textEdit" |>.toOption |>.getD Json.null
    let textEditText := (json.getObjValAs? String "textEditText").toOption
    let additionalTextEdits := (json.getObjValAs? (Array TextEdit) "additionalTextEdits").toOption
    let commitCharacters := (json.getObjValAs? (Array String) "commitCharacters").toOption
    let command := (json.getObjValAs? Command "command").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { label, labelDetails, kind, tags, detail, documentation, deprecated, preselect, sortText, filterText, insertText, insertTextFormat, insertTextMode, textEdit, textEditText, additionalTextEdits, commitCharacters, command, data }

/-- In many cases the items of an actual completion result share the same value for properties like `commitCharacters` or the range of a text edit. A completion list can therefore define item defaults which will be used if a completion item itself doesn't specify the value.  If a completion list specifi... -/
structure CompletionItemDefaults where
  commitCharacters : (Option (Array String)) := none
  editRange : Json := Json.null
  insertTextFormat : (Option InsertTextFormat) := none
  insertTextMode : (Option InsertTextMode) := none
  data : Json := Json.null
  deriving Inhabited

instance : ToJson CompletionItemDefaults where
  toJson s := Json.mkObj <|
    (match s.commitCharacters with | some v => [("commitCharacters", toJson v)] | none => []) ++
    [("editRange", toJson s.editRange)] ++
    (match s.insertTextFormat with | some v => [("insertTextFormat", toJson v)] | none => []) ++
    (match s.insertTextMode with | some v => [("insertTextMode", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson CompletionItemDefaults where
  fromJson? json := do
    let commitCharacters := (json.getObjValAs? (Array String) "commitCharacters").toOption
    let editRange := json.getObjVal? "editRange" |>.toOption |>.getD Json.null
    let insertTextFormat := (json.getObjValAs? InsertTextFormat "insertTextFormat").toOption
    let insertTextMode := (json.getObjValAs? InsertTextMode "insertTextMode").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { commitCharacters, editRange, insertTextFormat, insertTextMode, data }

/-- Defines workspace specific capabilities of the server.  @since 3.18.0 -/
structure WorkspaceOptions where
  workspaceFolders : (Option WorkspaceFoldersServerCapabilities) := none
  fileOperations : (Option FileOperationOptions) := none
  textDocumentContent : Json := Json.null
  deriving Inhabited

instance : ToJson WorkspaceOptions where
  toJson s := Json.mkObj <|
    (match s.workspaceFolders with | some v => [("workspaceFolders", toJson v)] | none => []) ++
    (match s.fileOperations with | some v => [("fileOperations", toJson v)] | none => []) ++
    [("textDocumentContent", toJson s.textDocumentContent)]

instance : FromJson WorkspaceOptions where
  fromJson? json := do
    let workspaceFolders := (json.getObjValAs? WorkspaceFoldersServerCapabilities "workspaceFolders").toOption
    let fileOperations := (json.getObjValAs? FileOperationOptions "fileOperations").toOption
    let textDocumentContent := json.getObjVal? "textDocumentContent" |>.toOption |>.getD Json.null
    return { workspaceFolders, fileOperations, textDocumentContent }

/-- Signature help represents the signature of something callable. There can be multiple signature but only one active and only one active parameter. -/
structure SignatureHelp where
  signatures : (Array SignatureInformation)
  activeSignature : (Option Nat) := none
  activeParameter : (Option Nat) := none
  deriving Inhabited

instance : ToJson SignatureHelp where
  toJson s := Json.mkObj <|
    [("signatures", toJson s.signatures)] ++
    (match s.activeSignature with | some v => [("activeSignature", toJson v)] | none => []) ++
    (match s.activeParameter with | some v => [("activeParameter", toJson v)] | none => [])

instance : FromJson SignatureHelp where
  fromJson? json := do
    let signatures ← json.getObjValAs? (Array SignatureInformation) "signatures"
    let activeSignature := (json.getObjValAs? Nat "activeSignature").toOption
    let activeParameter := (json.getObjValAs? Nat "activeParameter").toOption
    return { signatures, activeSignature, activeParameter }

/-- Registration options specific to a notebook.  @since 3.17.0 -/
structure NotebookDocumentSyncRegistrationOptions where
  notebookSelector : Json
  save : (Option Bool) := none
  id : (Option String) := none
  deriving Inhabited

instance : ToJson NotebookDocumentSyncRegistrationOptions where
  toJson s := Json.mkObj <|
    [("notebookSelector", toJson s.notebookSelector)] ++
    (match s.save with | some v => [("save", toJson v)] | none => []) ++
    (match s.id with | some v => [("id", toJson v)] | none => [])

instance : FromJson NotebookDocumentSyncRegistrationOptions where
  fromJson? json := do
    let notebookSelector := json.getObjVal? "notebookSelector" |>.toOption |>.getD Json.null
    let save := (json.getObjValAs? Bool "save").toOption
    let id := (json.getObjValAs? String "id").toOption
    return { notebookSelector, save, id }

/-- Text document specific client capabilities. -/
structure TextDocumentClientCapabilities where
  synchronization : (Option TextDocumentSyncClientCapabilities) := none
  filters : (Option TextDocumentFilterClientCapabilities) := none
  completion : (Option CompletionClientCapabilities) := none
  hover : (Option HoverClientCapabilities) := none
  signatureHelp : (Option SignatureHelpClientCapabilities) := none
  declaration : (Option DeclarationClientCapabilities) := none
  definition : (Option DefinitionClientCapabilities) := none
  typeDefinition : (Option TypeDefinitionClientCapabilities) := none
  implementation : (Option ImplementationClientCapabilities) := none
  references : (Option ReferenceClientCapabilities) := none
  documentHighlight : (Option DocumentHighlightClientCapabilities) := none
  documentSymbol : (Option DocumentSymbolClientCapabilities) := none
  codeAction : (Option CodeActionClientCapabilities) := none
  codeLens : (Option CodeLensClientCapabilities) := none
  documentLink : (Option DocumentLinkClientCapabilities) := none
  colorProvider : (Option DocumentColorClientCapabilities) := none
  formatting : (Option DocumentFormattingClientCapabilities) := none
  rangeFormatting : (Option DocumentRangeFormattingClientCapabilities) := none
  onTypeFormatting : (Option DocumentOnTypeFormattingClientCapabilities) := none
  rename : (Option RenameClientCapabilities) := none
  foldingRange : (Option FoldingRangeClientCapabilities) := none
  selectionRange : (Option SelectionRangeClientCapabilities) := none
  publishDiagnostics : (Option PublishDiagnosticsClientCapabilities) := none
  callHierarchy : (Option CallHierarchyClientCapabilities) := none
  semanticTokens : (Option SemanticTokensClientCapabilities) := none
  linkedEditingRange : (Option LinkedEditingRangeClientCapabilities) := none
  moniker : (Option MonikerClientCapabilities) := none
  typeHierarchy : (Option TypeHierarchyClientCapabilities) := none
  inlineValue : (Option InlineValueClientCapabilities) := none
  inlayHint : (Option InlayHintClientCapabilities) := none
  diagnostic : (Option DiagnosticClientCapabilities) := none
  inlineCompletion : Json := Json.null
  deriving Inhabited

instance : ToJson TextDocumentClientCapabilities where
  toJson s := Json.mkObj <|
    (match s.synchronization with | some v => [("synchronization", toJson v)] | none => []) ++
    (match s.filters with | some v => [("filters", toJson v)] | none => []) ++
    (match s.completion with | some v => [("completion", toJson v)] | none => []) ++
    (match s.hover with | some v => [("hover", toJson v)] | none => []) ++
    (match s.signatureHelp with | some v => [("signatureHelp", toJson v)] | none => []) ++
    (match s.declaration with | some v => [("declaration", toJson v)] | none => []) ++
    (match s.definition with | some v => [("definition", toJson v)] | none => []) ++
    (match s.typeDefinition with | some v => [("typeDefinition", toJson v)] | none => []) ++
    (match s.implementation with | some v => [("implementation", toJson v)] | none => []) ++
    (match s.references with | some v => [("references", toJson v)] | none => []) ++
    (match s.documentHighlight with | some v => [("documentHighlight", toJson v)] | none => []) ++
    (match s.documentSymbol with | some v => [("documentSymbol", toJson v)] | none => []) ++
    (match s.codeAction with | some v => [("codeAction", toJson v)] | none => []) ++
    (match s.codeLens with | some v => [("codeLens", toJson v)] | none => []) ++
    (match s.documentLink with | some v => [("documentLink", toJson v)] | none => []) ++
    (match s.colorProvider with | some v => [("colorProvider", toJson v)] | none => []) ++
    (match s.formatting with | some v => [("formatting", toJson v)] | none => []) ++
    (match s.rangeFormatting with | some v => [("rangeFormatting", toJson v)] | none => []) ++
    (match s.onTypeFormatting with | some v => [("onTypeFormatting", toJson v)] | none => []) ++
    (match s.rename with | some v => [("rename", toJson v)] | none => []) ++
    (match s.foldingRange with | some v => [("foldingRange", toJson v)] | none => []) ++
    (match s.selectionRange with | some v => [("selectionRange", toJson v)] | none => []) ++
    (match s.publishDiagnostics with | some v => [("publishDiagnostics", toJson v)] | none => []) ++
    (match s.callHierarchy with | some v => [("callHierarchy", toJson v)] | none => []) ++
    (match s.semanticTokens with | some v => [("semanticTokens", toJson v)] | none => []) ++
    (match s.linkedEditingRange with | some v => [("linkedEditingRange", toJson v)] | none => []) ++
    (match s.moniker with | some v => [("moniker", toJson v)] | none => []) ++
    (match s.typeHierarchy with | some v => [("typeHierarchy", toJson v)] | none => []) ++
    (match s.inlineValue with | some v => [("inlineValue", toJson v)] | none => []) ++
    (match s.inlayHint with | some v => [("inlayHint", toJson v)] | none => []) ++
    (match s.diagnostic with | some v => [("diagnostic", toJson v)] | none => []) ++
    [("inlineCompletion", toJson s.inlineCompletion)]

instance : FromJson TextDocumentClientCapabilities where
  fromJson? json := do
    let synchronization := (json.getObjValAs? TextDocumentSyncClientCapabilities "synchronization").toOption
    let filters := (json.getObjValAs? TextDocumentFilterClientCapabilities "filters").toOption
    let completion := (json.getObjValAs? CompletionClientCapabilities "completion").toOption
    let hover := (json.getObjValAs? HoverClientCapabilities "hover").toOption
    let signatureHelp := (json.getObjValAs? SignatureHelpClientCapabilities "signatureHelp").toOption
    let declaration := (json.getObjValAs? DeclarationClientCapabilities "declaration").toOption
    let definition := (json.getObjValAs? DefinitionClientCapabilities "definition").toOption
    let typeDefinition := (json.getObjValAs? TypeDefinitionClientCapabilities "typeDefinition").toOption
    let implementation := (json.getObjValAs? ImplementationClientCapabilities "implementation").toOption
    let references := (json.getObjValAs? ReferenceClientCapabilities "references").toOption
    let documentHighlight := (json.getObjValAs? DocumentHighlightClientCapabilities "documentHighlight").toOption
    let documentSymbol := (json.getObjValAs? DocumentSymbolClientCapabilities "documentSymbol").toOption
    let codeAction := (json.getObjValAs? CodeActionClientCapabilities "codeAction").toOption
    let codeLens := (json.getObjValAs? CodeLensClientCapabilities "codeLens").toOption
    let documentLink := (json.getObjValAs? DocumentLinkClientCapabilities "documentLink").toOption
    let colorProvider := (json.getObjValAs? DocumentColorClientCapabilities "colorProvider").toOption
    let formatting := (json.getObjValAs? DocumentFormattingClientCapabilities "formatting").toOption
    let rangeFormatting := (json.getObjValAs? DocumentRangeFormattingClientCapabilities "rangeFormatting").toOption
    let onTypeFormatting := (json.getObjValAs? DocumentOnTypeFormattingClientCapabilities "onTypeFormatting").toOption
    let rename := (json.getObjValAs? RenameClientCapabilities "rename").toOption
    let foldingRange := (json.getObjValAs? FoldingRangeClientCapabilities "foldingRange").toOption
    let selectionRange := (json.getObjValAs? SelectionRangeClientCapabilities "selectionRange").toOption
    let publishDiagnostics := (json.getObjValAs? PublishDiagnosticsClientCapabilities "publishDiagnostics").toOption
    let callHierarchy := (json.getObjValAs? CallHierarchyClientCapabilities "callHierarchy").toOption
    let semanticTokens := (json.getObjValAs? SemanticTokensClientCapabilities "semanticTokens").toOption
    let linkedEditingRange := (json.getObjValAs? LinkedEditingRangeClientCapabilities "linkedEditingRange").toOption
    let moniker := (json.getObjValAs? MonikerClientCapabilities "moniker").toOption
    let typeHierarchy := (json.getObjValAs? TypeHierarchyClientCapabilities "typeHierarchy").toOption
    let inlineValue := (json.getObjValAs? InlineValueClientCapabilities "inlineValue").toOption
    let inlayHint := (json.getObjValAs? InlayHintClientCapabilities "inlayHint").toOption
    let diagnostic := (json.getObjValAs? DiagnosticClientCapabilities "diagnostic").toOption
    let inlineCompletion := json.getObjVal? "inlineCompletion" |>.toOption |>.getD Json.null
    return { synchronization, filters, completion, hover, signatureHelp, declaration, definition, typeDefinition, implementation, references, documentHighlight, documentSymbol, codeAction, codeLens, documentLink, colorProvider, formatting, rangeFormatting, onTypeFormatting, rename, foldingRange, selectionRange, publishDiagnostics, callHierarchy, semanticTokens, linkedEditingRange, moniker, typeHierarchy, inlineValue, inlayHint, diagnostic, inlineCompletion }

/-- A change event for a notebook document.  @since 3.17.0 -/
structure NotebookDocumentChangeEvent where
  metadata : Json := Json.null
  cells : (Option NotebookDocumentCellChanges) := none
  deriving Inhabited

instance : ToJson NotebookDocumentChangeEvent where
  toJson s := Json.mkObj <|
    [("metadata", toJson s.metadata)] ++
    (match s.cells with | some v => [("cells", toJson v)] | none => [])

instance : FromJson NotebookDocumentChangeEvent where
  fromJson? json := do
    let metadata := json.getObjVal? "metadata" |>.toOption |>.getD Json.null
    let cells := (json.getObjValAs? NotebookDocumentCellChanges "cells").toOption
    return { metadata, cells }

/-- Inlay hint information.  @since 3.17.0 -/
structure InlayHint where
  position : Position
  label : Json
  kind : (Option InlayHintKind) := none
  textEdits : (Option (Array TextEdit)) := none
  tooltip : Json := Json.null
  paddingLeft : (Option Bool) := none
  paddingRight : (Option Bool) := none
  data : Json := Json.null
  deriving Inhabited

instance : ToJson InlayHint where
  toJson s := Json.mkObj <|
    [("position", toJson s.position)] ++
    [("label", toJson s.label)] ++
    (match s.kind with | some v => [("kind", toJson v)] | none => []) ++
    (match s.textEdits with | some v => [("textEdits", toJson v)] | none => []) ++
    [("tooltip", toJson s.tooltip)] ++
    (match s.paddingLeft with | some v => [("paddingLeft", toJson v)] | none => []) ++
    (match s.paddingRight with | some v => [("paddingRight", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson InlayHint where
  fromJson? json := do
    let position ← json.getObjValAs? Position "position"
    let label := json.getObjVal? "label" |>.toOption |>.getD Json.null
    let kind := (json.getObjValAs? InlayHintKind "kind").toOption
    let textEdits := (json.getObjValAs? (Array TextEdit) "textEdits").toOption
    let tooltip := json.getObjVal? "tooltip" |>.toOption |>.getD Json.null
    let paddingLeft := (json.getObjValAs? Bool "paddingLeft").toOption
    let paddingRight := (json.getObjValAs? Bool "paddingRight").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { position, label, kind, textEdits, tooltip, paddingLeft, paddingRight, data }

/-- Represents a diagnostic, such as a compiler error or warning. Diagnostic objects are only valid in the scope of a resource. -/
structure Diagnostic where
  range : Range
  severity : (Option DiagnosticSeverity) := none
  code : Json := Json.null
  codeDescription : (Option CodeDescription) := none
  source : (Option String) := none
  message : String
  tags : (Option (Array DiagnosticTag)) := none
  relatedInformation : (Option (Array DiagnosticRelatedInformation)) := none
  data : Json := Json.null
  deriving Inhabited

instance : ToJson Diagnostic where
  toJson s := Json.mkObj <|
    [("range", toJson s.range)] ++
    (match s.severity with | some v => [("severity", toJson v)] | none => []) ++
    [("code", toJson s.code)] ++
    (match s.codeDescription with | some v => [("codeDescription", toJson v)] | none => []) ++
    (match s.source with | some v => [("source", toJson v)] | none => []) ++
    [("message", toJson s.message)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => []) ++
    (match s.relatedInformation with | some v => [("relatedInformation", toJson v)] | none => []) ++
    [("data", toJson s.data)]

instance : FromJson Diagnostic where
  fromJson? json := do
    let range ← json.getObjValAs? Range "range"
    let severity := (json.getObjValAs? DiagnosticSeverity "severity").toOption
    let code := json.getObjVal? "code" |>.toOption |>.getD Json.null
    let codeDescription := (json.getObjValAs? CodeDescription "codeDescription").toOption
    let source := (json.getObjValAs? String "source").toOption
    let message ← json.getObjValAs? String "message"
    let tags := (json.getObjValAs? (Array DiagnosticTag) "tags").toOption
    let relatedInformation := (json.getObjValAs? (Array DiagnosticRelatedInformation) "relatedInformation").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    return { range, severity, code, codeDescription, source, message, tags, relatedInformation, data }

/-- Describes textual changes on a text document. A TextDocumentEdit describes all changes on a document version Si and after they are applied move the document to version Si+1. So the creator of a TextDocumentEdit doesn't need to sort the array of edits or do any kind of ordering. However the edits mus... -/
structure TextDocumentEdit where
  textDocument : OptionalVersionedTextDocumentIdentifier
  edits : Json
  deriving Inhabited

instance : ToJson TextDocumentEdit where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("edits", toJson s.edits)]

instance : FromJson TextDocumentEdit where
  fromJson? json := do
    let textDocument ← json.getObjValAs? OptionalVersionedTextDocumentIdentifier "textDocument"
    let edits := json.getObjVal? "edits" |>.toOption |>.getD Json.null
    return { textDocument, edits }

/-- Represents a collection of {@link CompletionItem completion items} to be presented in the editor. -/
structure CompletionList where
  isIncomplete : Bool
  itemDefaults : (Option CompletionItemDefaults) := none
  applyKind : (Option CompletionItemApplyKinds) := none
  items : Json
  deriving Inhabited

instance : ToJson CompletionList where
  toJson s := Json.mkObj <|
    [("isIncomplete", toJson s.isIncomplete)] ++
    (match s.itemDefaults with | some v => [("itemDefaults", toJson v)] | none => []) ++
    (match s.applyKind with | some v => [("applyKind", toJson v)] | none => []) ++
    [("items", toJson s.items)]

instance : FromJson CompletionList where
  fromJson? json := do
    let isIncomplete ← json.getObjValAs? Bool "isIncomplete"
    let itemDefaults := (json.getObjValAs? CompletionItemDefaults "itemDefaults").toOption
    let applyKind := (json.getObjValAs? CompletionItemApplyKinds "applyKind").toOption
    let items := json.getObjVal? "items" |>.toOption |>.getD Json.null
    return { isIncomplete, itemDefaults, applyKind, items }

/-- Additional information about the context in which a signature help request was triggered.  @since 3.15.0 -/
structure SignatureHelpContext where
  triggerKind : SignatureHelpTriggerKind
  triggerCharacter : (Option String) := none
  isRetrigger : Bool
  activeSignatureHelp : (Option SignatureHelp) := none
  deriving Inhabited

instance : ToJson SignatureHelpContext where
  toJson s := Json.mkObj <|
    [("triggerKind", toJson s.triggerKind)] ++
    (match s.triggerCharacter with | some v => [("triggerCharacter", toJson v)] | none => []) ++
    [("isRetrigger", toJson s.isRetrigger)] ++
    (match s.activeSignatureHelp with | some v => [("activeSignatureHelp", toJson v)] | none => [])

instance : FromJson SignatureHelpContext where
  fromJson? json := do
    let triggerKind ← json.getObjValAs? SignatureHelpTriggerKind "triggerKind"
    let triggerCharacter := (json.getObjValAs? String "triggerCharacter").toOption
    let isRetrigger ← json.getObjValAs? Bool "isRetrigger"
    let activeSignatureHelp := (json.getObjValAs? SignatureHelp "activeSignatureHelp").toOption
    return { triggerKind, triggerCharacter, isRetrigger, activeSignatureHelp }

/-- Defines the capabilities provided by a language server. -/
structure ServerCapabilities where
  positionEncoding : (Option PositionEncodingKind) := none
  textDocumentSync : Json := Json.null
  notebookDocumentSync : Json := Json.null
  completionProvider : (Option CompletionOptions) := none
  hoverProvider : Json := Json.null
  signatureHelpProvider : (Option SignatureHelpOptions) := none
  declarationProvider : Json := Json.null
  definitionProvider : Json := Json.null
  typeDefinitionProvider : Json := Json.null
  implementationProvider : Json := Json.null
  referencesProvider : Json := Json.null
  documentHighlightProvider : Json := Json.null
  documentSymbolProvider : Json := Json.null
  codeActionProvider : Json := Json.null
  codeLensProvider : (Option CodeLensOptions) := none
  documentLinkProvider : (Option DocumentLinkOptions) := none
  colorProvider : Json := Json.null
  workspaceSymbolProvider : Json := Json.null
  documentFormattingProvider : Json := Json.null
  documentRangeFormattingProvider : Json := Json.null
  documentOnTypeFormattingProvider : (Option DocumentOnTypeFormattingOptions) := none
  renameProvider : Json := Json.null
  foldingRangeProvider : Json := Json.null
  selectionRangeProvider : Json := Json.null
  executeCommandProvider : (Option ExecuteCommandOptions) := none
  callHierarchyProvider : Json := Json.null
  linkedEditingRangeProvider : Json := Json.null
  semanticTokensProvider : Json := Json.null
  monikerProvider : Json := Json.null
  typeHierarchyProvider : Json := Json.null
  inlineValueProvider : Json := Json.null
  inlayHintProvider : Json := Json.null
  diagnosticProvider : Json := Json.null
  inlineCompletionProvider : Json := Json.null
  workspace : (Option WorkspaceOptions) := none
  experimental : Json := Json.null
  deriving Inhabited

instance : ToJson ServerCapabilities where
  toJson s := Json.mkObj <|
    (match s.positionEncoding with | some v => [("positionEncoding", toJson v)] | none => []) ++
    [("textDocumentSync", toJson s.textDocumentSync)] ++
    [("notebookDocumentSync", toJson s.notebookDocumentSync)] ++
    (match s.completionProvider with | some v => [("completionProvider", toJson v)] | none => []) ++
    [("hoverProvider", toJson s.hoverProvider)] ++
    (match s.signatureHelpProvider with | some v => [("signatureHelpProvider", toJson v)] | none => []) ++
    [("declarationProvider", toJson s.declarationProvider)] ++
    [("definitionProvider", toJson s.definitionProvider)] ++
    [("typeDefinitionProvider", toJson s.typeDefinitionProvider)] ++
    [("implementationProvider", toJson s.implementationProvider)] ++
    [("referencesProvider", toJson s.referencesProvider)] ++
    [("documentHighlightProvider", toJson s.documentHighlightProvider)] ++
    [("documentSymbolProvider", toJson s.documentSymbolProvider)] ++
    [("codeActionProvider", toJson s.codeActionProvider)] ++
    (match s.codeLensProvider with | some v => [("codeLensProvider", toJson v)] | none => []) ++
    (match s.documentLinkProvider with | some v => [("documentLinkProvider", toJson v)] | none => []) ++
    [("colorProvider", toJson s.colorProvider)] ++
    [("workspaceSymbolProvider", toJson s.workspaceSymbolProvider)] ++
    [("documentFormattingProvider", toJson s.documentFormattingProvider)] ++
    [("documentRangeFormattingProvider", toJson s.documentRangeFormattingProvider)] ++
    (match s.documentOnTypeFormattingProvider with | some v => [("documentOnTypeFormattingProvider", toJson v)] | none => []) ++
    [("renameProvider", toJson s.renameProvider)] ++
    [("foldingRangeProvider", toJson s.foldingRangeProvider)] ++
    [("selectionRangeProvider", toJson s.selectionRangeProvider)] ++
    (match s.executeCommandProvider with | some v => [("executeCommandProvider", toJson v)] | none => []) ++
    [("callHierarchyProvider", toJson s.callHierarchyProvider)] ++
    [("linkedEditingRangeProvider", toJson s.linkedEditingRangeProvider)] ++
    [("semanticTokensProvider", toJson s.semanticTokensProvider)] ++
    [("monikerProvider", toJson s.monikerProvider)] ++
    [("typeHierarchyProvider", toJson s.typeHierarchyProvider)] ++
    [("inlineValueProvider", toJson s.inlineValueProvider)] ++
    [("inlayHintProvider", toJson s.inlayHintProvider)] ++
    [("diagnosticProvider", toJson s.diagnosticProvider)] ++
    [("inlineCompletionProvider", toJson s.inlineCompletionProvider)] ++
    (match s.workspace with | some v => [("workspace", toJson v)] | none => []) ++
    [("experimental", toJson s.experimental)]

instance : FromJson ServerCapabilities where
  fromJson? json := do
    let positionEncoding := (json.getObjValAs? PositionEncodingKind "positionEncoding").toOption
    let textDocumentSync := json.getObjVal? "textDocumentSync" |>.toOption |>.getD Json.null
    let notebookDocumentSync := json.getObjVal? "notebookDocumentSync" |>.toOption |>.getD Json.null
    let completionProvider := (json.getObjValAs? CompletionOptions "completionProvider").toOption
    let hoverProvider := json.getObjVal? "hoverProvider" |>.toOption |>.getD Json.null
    let signatureHelpProvider := (json.getObjValAs? SignatureHelpOptions "signatureHelpProvider").toOption
    let declarationProvider := json.getObjVal? "declarationProvider" |>.toOption |>.getD Json.null
    let definitionProvider := json.getObjVal? "definitionProvider" |>.toOption |>.getD Json.null
    let typeDefinitionProvider := json.getObjVal? "typeDefinitionProvider" |>.toOption |>.getD Json.null
    let implementationProvider := json.getObjVal? "implementationProvider" |>.toOption |>.getD Json.null
    let referencesProvider := json.getObjVal? "referencesProvider" |>.toOption |>.getD Json.null
    let documentHighlightProvider := json.getObjVal? "documentHighlightProvider" |>.toOption |>.getD Json.null
    let documentSymbolProvider := json.getObjVal? "documentSymbolProvider" |>.toOption |>.getD Json.null
    let codeActionProvider := json.getObjVal? "codeActionProvider" |>.toOption |>.getD Json.null
    let codeLensProvider := (json.getObjValAs? CodeLensOptions "codeLensProvider").toOption
    let documentLinkProvider := (json.getObjValAs? DocumentLinkOptions "documentLinkProvider").toOption
    let colorProvider := json.getObjVal? "colorProvider" |>.toOption |>.getD Json.null
    let workspaceSymbolProvider := json.getObjVal? "workspaceSymbolProvider" |>.toOption |>.getD Json.null
    let documentFormattingProvider := json.getObjVal? "documentFormattingProvider" |>.toOption |>.getD Json.null
    let documentRangeFormattingProvider := json.getObjVal? "documentRangeFormattingProvider" |>.toOption |>.getD Json.null
    let documentOnTypeFormattingProvider := (json.getObjValAs? DocumentOnTypeFormattingOptions "documentOnTypeFormattingProvider").toOption
    let renameProvider := json.getObjVal? "renameProvider" |>.toOption |>.getD Json.null
    let foldingRangeProvider := json.getObjVal? "foldingRangeProvider" |>.toOption |>.getD Json.null
    let selectionRangeProvider := json.getObjVal? "selectionRangeProvider" |>.toOption |>.getD Json.null
    let executeCommandProvider := (json.getObjValAs? ExecuteCommandOptions "executeCommandProvider").toOption
    let callHierarchyProvider := json.getObjVal? "callHierarchyProvider" |>.toOption |>.getD Json.null
    let linkedEditingRangeProvider := json.getObjVal? "linkedEditingRangeProvider" |>.toOption |>.getD Json.null
    let semanticTokensProvider := json.getObjVal? "semanticTokensProvider" |>.toOption |>.getD Json.null
    let monikerProvider := json.getObjVal? "monikerProvider" |>.toOption |>.getD Json.null
    let typeHierarchyProvider := json.getObjVal? "typeHierarchyProvider" |>.toOption |>.getD Json.null
    let inlineValueProvider := json.getObjVal? "inlineValueProvider" |>.toOption |>.getD Json.null
    let inlayHintProvider := json.getObjVal? "inlayHintProvider" |>.toOption |>.getD Json.null
    let diagnosticProvider := json.getObjVal? "diagnosticProvider" |>.toOption |>.getD Json.null
    let inlineCompletionProvider := json.getObjVal? "inlineCompletionProvider" |>.toOption |>.getD Json.null
    let workspace := (json.getObjValAs? WorkspaceOptions "workspace").toOption
    let experimental := json.getObjVal? "experimental" |>.toOption |>.getD Json.null
    return { positionEncoding, textDocumentSync, notebookDocumentSync, completionProvider, hoverProvider, signatureHelpProvider, declarationProvider, definitionProvider, typeDefinitionProvider, implementationProvider, referencesProvider, documentHighlightProvider, documentSymbolProvider, codeActionProvider, codeLensProvider, documentLinkProvider, colorProvider, workspaceSymbolProvider, documentFormattingProvider, documentRangeFormattingProvider, documentOnTypeFormattingProvider, renameProvider, foldingRangeProvider, selectionRangeProvider, executeCommandProvider, callHierarchyProvider, linkedEditingRangeProvider, semanticTokensProvider, monikerProvider, typeHierarchyProvider, inlineValueProvider, inlayHintProvider, diagnosticProvider, inlineCompletionProvider, workspace, experimental }

/-- Defines the capabilities provided by the client. -/
structure ClientCapabilities where
  workspace : Json := Json.null
  textDocument : (Option TextDocumentClientCapabilities) := none
  notebookDocument : (Option NotebookDocumentClientCapabilities) := none
  window : (Option WindowClientCapabilities) := none
  general : (Option GeneralClientCapabilities) := none
  experimental : Json := Json.null
  deriving Inhabited

instance : ToJson ClientCapabilities where
  toJson s := Json.mkObj <|
    [("workspace", toJson s.workspace)] ++
    (match s.textDocument with | some v => [("textDocument", toJson v)] | none => []) ++
    (match s.notebookDocument with | some v => [("notebookDocument", toJson v)] | none => []) ++
    (match s.window with | some v => [("window", toJson v)] | none => []) ++
    (match s.general with | some v => [("general", toJson v)] | none => []) ++
    [("experimental", toJson s.experimental)]

instance : FromJson ClientCapabilities where
  fromJson? json := do
    let workspace := json.getObjVal? "workspace" |>.toOption |>.getD Json.null
    let textDocument := (json.getObjValAs? TextDocumentClientCapabilities "textDocument").toOption
    let notebookDocument := (json.getObjValAs? NotebookDocumentClientCapabilities "notebookDocument").toOption
    let window := (json.getObjValAs? WindowClientCapabilities "window").toOption
    let general := (json.getObjValAs? GeneralClientCapabilities "general").toOption
    let experimental := json.getObjVal? "experimental" |>.toOption |>.getD Json.null
    return { workspace, textDocument, notebookDocument, window, general, experimental }

/-- The params sent in a change notebook document notification.  @since 3.17.0 -/
structure DidChangeNotebookDocumentParams where
  notebookDocument : VersionedNotebookDocumentIdentifier
  change : NotebookDocumentChangeEvent
  deriving Inhabited

instance : ToJson DidChangeNotebookDocumentParams where
  toJson s := Json.mkObj <|
    [("notebookDocument", toJson s.notebookDocument)] ++
    [("change", toJson s.change)]

instance : FromJson DidChangeNotebookDocumentParams where
  fromJson? json := do
    let notebookDocument ← json.getObjValAs? VersionedNotebookDocumentIdentifier "notebookDocument"
    let change ← json.getObjValAs? NotebookDocumentChangeEvent "change"
    return { notebookDocument, change }

/-- A workspace edit represents changes to many resources managed in the workspace. The edit should either provide `changes` or `documentChanges`. If documentChanges are present they are preferred over `changes` if the client can handle versioned document edits.  Since version 3.13.0 a workspace edit ca... -/
structure WorkspaceEdit where
  changes : Json := Json.null
  documentChanges : Json := Json.null
  changeAnnotations : Json := Json.null
  deriving Inhabited

instance : ToJson WorkspaceEdit where
  toJson s := Json.mkObj <|
    [("changes", toJson s.changes)] ++
    [("documentChanges", toJson s.documentChanges)] ++
    [("changeAnnotations", toJson s.changeAnnotations)]

instance : FromJson WorkspaceEdit where
  fromJson? json := do
    let changes := json.getObjVal? "changes" |>.toOption |>.getD Json.null
    let documentChanges := json.getObjVal? "documentChanges" |>.toOption |>.getD Json.null
    let changeAnnotations := json.getObjVal? "changeAnnotations" |>.toOption |>.getD Json.null
    return { changes, documentChanges, changeAnnotations }

/-- Parameters for a {@link SignatureHelpRequest}. -/
structure SignatureHelpParams where
  textDocument : TextDocumentIdentifier
  position : Position
  workDoneToken : (Option ProgressToken) := none
  context : (Option SignatureHelpContext) := none
  deriving Inhabited

instance : ToJson SignatureHelpParams where
  toJson s := Json.mkObj <|
    [("textDocument", toJson s.textDocument)] ++
    [("position", toJson s.position)] ++
    (match s.workDoneToken with | some v => [("workDoneToken", toJson v)] | none => []) ++
    (match s.context with | some v => [("context", toJson v)] | none => [])

instance : FromJson SignatureHelpParams where
  fromJson? json := do
    let textDocument ← json.getObjValAs? TextDocumentIdentifier "textDocument"
    let position ← json.getObjValAs? Position "position"
    let workDoneToken := (json.getObjValAs? ProgressToken "workDoneToken").toOption
    let context := (json.getObjValAs? SignatureHelpContext "context").toOption
    return { textDocument, position, workDoneToken, context }

/-- The result returned from an initialize request. -/
structure InitializeResult where
  capabilities : ServerCapabilities
  serverInfo : (Option ServerInfo) := none
  deriving Inhabited

instance : ToJson InitializeResult where
  toJson s := Json.mkObj <|
    [("capabilities", toJson s.capabilities)] ++
    (match s.serverInfo with | some v => [("serverInfo", toJson v)] | none => [])

instance : FromJson InitializeResult where
  fromJson? json := do
    let capabilities ← json.getObjValAs? ServerCapabilities "capabilities"
    let serverInfo := (json.getObjValAs? ServerInfo "serverInfo").toOption
    return { capabilities, serverInfo }

/-- A code action represents a change that can be performed in code, e.g. to fix a problem or to refactor code.  A CodeAction must set either `edit` and/or a `command`. If both are supplied, the `edit` is applied first, then the `command` is executed. -/
structure CodeAction where
  title : String
  kind : (Option CodeActionKind) := none
  diagnostics : Json := Json.null
  isPreferred : (Option Bool) := none
  disabled : (Option CodeActionDisabled) := none
  edit : (Option WorkspaceEdit) := none
  command : (Option Command) := none
  data : Json := Json.null
  tags : (Option (Array CodeActionTag)) := none
  deriving Inhabited

instance : ToJson CodeAction where
  toJson s := Json.mkObj <|
    [("title", toJson s.title)] ++
    (match s.kind with | some v => [("kind", toJson v)] | none => []) ++
    [("diagnostics", toJson s.diagnostics)] ++
    (match s.isPreferred with | some v => [("isPreferred", toJson v)] | none => []) ++
    (match s.disabled with | some v => [("disabled", toJson v)] | none => []) ++
    (match s.edit with | some v => [("edit", toJson v)] | none => []) ++
    (match s.command with | some v => [("command", toJson v)] | none => []) ++
    [("data", toJson s.data)] ++
    (match s.tags with | some v => [("tags", toJson v)] | none => [])

instance : FromJson CodeAction where
  fromJson? json := do
    let title ← json.getObjValAs? String "title"
    let kind := (json.getObjValAs? CodeActionKind "kind").toOption
    let diagnostics := json.getObjVal? "diagnostics" |>.toOption |>.getD Json.null
    let isPreferred := (json.getObjValAs? Bool "isPreferred").toOption
    let disabled := (json.getObjValAs? CodeActionDisabled "disabled").toOption
    let edit := (json.getObjValAs? WorkspaceEdit "edit").toOption
    let command := (json.getObjValAs? Command "command").toOption
    let data := json.getObjVal? "data" |>.toOption |>.getD Json.null
    let tags := (json.getObjValAs? (Array CodeActionTag) "tags").toOption
    return { title, kind, diagnostics, isPreferred, disabled, edit, command, data, tags }

/-- The parameters passed via an apply workspace edit request. -/
structure ApplyWorkspaceEditParams where
  label : (Option String) := none
  edit : WorkspaceEdit
  metadata : Json := Json.null
  deriving Inhabited

instance : ToJson ApplyWorkspaceEditParams where
  toJson s := Json.mkObj <|
    (match s.label with | some v => [("label", toJson v)] | none => []) ++
    [("edit", toJson s.edit)] ++
    [("metadata", toJson s.metadata)]

instance : FromJson ApplyWorkspaceEditParams where
  fromJson? json := do
    let label := (json.getObjValAs? String "label").toOption
    let edit ← json.getObjValAs? WorkspaceEdit "edit"
    let metadata := json.getObjVal? "metadata" |>.toOption |>.getD Json.null
    return { label, edit, metadata }

/-! ## Request Methods -/

/-- Method: `textDocument/implementation` -/
def ImplementationRequestMethod : String := "textDocument/implementation"

/-- Method: `textDocument/typeDefinition` -/
def TypeDefinitionRequestMethod : String := "textDocument/typeDefinition"

/-- Method: `workspace/workspaceFolders` -/
def WorkspaceFoldersRequestMethod : String := "workspace/workspaceFolders"

/-- Method: `workspace/configuration` -/
def ConfigurationRequestMethod : String := "workspace/configuration"

/-- Method: `textDocument/documentColor` -/
def DocumentColorRequestMethod : String := "textDocument/documentColor"

/-- Method: `textDocument/colorPresentation` -/
def ColorPresentationRequestMethod : String := "textDocument/colorPresentation"

/-- Method: `textDocument/foldingRange` -/
def FoldingRangeRequestMethod : String := "textDocument/foldingRange"

/-- Method: `textDocument/declaration` -/
def DeclarationRequestMethod : String := "textDocument/declaration"

/-- Method: `textDocument/selectionRange` -/
def SelectionRangeRequestMethod : String := "textDocument/selectionRange"

/-- Method: `window/workDoneProgress/create` -/
def WorkDoneProgressCreateRequestMethod : String := "window/workDoneProgress/create"

/-- Method: `textDocument/prepareCallHierarchy` -/
def CallHierarchyPrepareRequestMethod : String := "textDocument/prepareCallHierarchy"

/-- Method: `callHierarchy/incomingCalls` -/
def CallHierarchyIncomingCallsRequestMethod : String := "callHierarchy/incomingCalls"

/-- Method: `callHierarchy/outgoingCalls` -/
def CallHierarchyOutgoingCallsRequestMethod : String := "callHierarchy/outgoingCalls"

/-- Method: `textDocument/semanticTokens/full` -/
def SemanticTokensRequestMethod : String := "textDocument/semanticTokens/full"

/-- Method: `textDocument/semanticTokens/full/delta` -/
def SemanticTokensDeltaRequestMethod : String := "textDocument/semanticTokens/full/delta"

/-- Method: `textDocument/semanticTokens/range` -/
def SemanticTokensRangeRequestMethod : String := "textDocument/semanticTokens/range"

/-- Method: `workspace/semanticTokens/refresh` -/
def SemanticTokensRefreshRequestMethod : String := "workspace/semanticTokens/refresh"

/-- Method: `window/showDocument` -/
def ShowDocumentRequestMethod : String := "window/showDocument"

/-- Method: `textDocument/linkedEditingRange` -/
def LinkedEditingRangeRequestMethod : String := "textDocument/linkedEditingRange"

/-- Method: `workspace/willCreateFiles` -/
def WillCreateFilesRequestMethod : String := "workspace/willCreateFiles"

/-- Method: `workspace/willRenameFiles` -/
def WillRenameFilesRequestMethod : String := "workspace/willRenameFiles"

/-- Method: `workspace/willDeleteFiles` -/
def WillDeleteFilesRequestMethod : String := "workspace/willDeleteFiles"

/-- Method: `textDocument/moniker` -/
def MonikerRequestMethod : String := "textDocument/moniker"

/-- Method: `textDocument/prepareTypeHierarchy` -/
def TypeHierarchyPrepareRequestMethod : String := "textDocument/prepareTypeHierarchy"

/-- Method: `typeHierarchy/supertypes` -/
def TypeHierarchySupertypesRequestMethod : String := "typeHierarchy/supertypes"

/-- Method: `typeHierarchy/subtypes` -/
def TypeHierarchySubtypesRequestMethod : String := "typeHierarchy/subtypes"

/-- Method: `textDocument/inlineValue` -/
def InlineValueRequestMethod : String := "textDocument/inlineValue"

/-- Method: `workspace/inlineValue/refresh` -/
def InlineValueRefreshRequestMethod : String := "workspace/inlineValue/refresh"

/-- Method: `textDocument/inlayHint` -/
def InlayHintRequestMethod : String := "textDocument/inlayHint"

/-- Method: `inlayHint/resolve` -/
def InlayHintResolveRequestMethod : String := "inlayHint/resolve"

/-- Method: `workspace/inlayHint/refresh` -/
def InlayHintRefreshRequestMethod : String := "workspace/inlayHint/refresh"

/-- Method: `textDocument/diagnostic` -/
def DocumentDiagnosticRequestMethod : String := "textDocument/diagnostic"

/-- Method: `workspace/diagnostic` -/
def WorkspaceDiagnosticRequestMethod : String := "workspace/diagnostic"

/-- Method: `workspace/diagnostic/refresh` -/
def DiagnosticRefreshRequestMethod : String := "workspace/diagnostic/refresh"

/-- Method: `client/registerCapability` -/
def RegistrationRequestMethod : String := "client/registerCapability"

/-- Method: `client/unregisterCapability` -/
def UnregistrationRequestMethod : String := "client/unregisterCapability"

/-- Method: `initialize` -/
def InitializeRequestMethod : String := "initialize"

/-- Method: `shutdown` -/
def ShutdownRequestMethod : String := "shutdown"

/-- Method: `window/showMessageRequest` -/
def ShowMessageRequestMethod : String := "window/showMessageRequest"

/-- Method: `textDocument/willSaveWaitUntil` -/
def WillSaveTextDocumentWaitUntilRequestMethod : String := "textDocument/willSaveWaitUntil"

/-- Method: `textDocument/completion` -/
def CompletionRequestMethod : String := "textDocument/completion"

/-- Method: `completionItem/resolve` -/
def CompletionResolveRequestMethod : String := "completionItem/resolve"

/-- Method: `textDocument/hover` -/
def HoverRequestMethod : String := "textDocument/hover"

/-- Method: `textDocument/signatureHelp` -/
def SignatureHelpRequestMethod : String := "textDocument/signatureHelp"

/-- Method: `textDocument/definition` -/
def DefinitionRequestMethod : String := "textDocument/definition"

/-- Method: `textDocument/references` -/
def ReferencesRequestMethod : String := "textDocument/references"

/-- Method: `textDocument/documentHighlight` -/
def DocumentHighlightRequestMethod : String := "textDocument/documentHighlight"

/-- Method: `textDocument/documentSymbol` -/
def DocumentSymbolRequestMethod : String := "textDocument/documentSymbol"

/-- Method: `textDocument/codeAction` -/
def CodeActionRequestMethod : String := "textDocument/codeAction"

/-- Method: `codeAction/resolve` -/
def CodeActionResolveRequestMethod : String := "codeAction/resolve"

/-- Method: `workspace/symbol` -/
def WorkspaceSymbolRequestMethod : String := "workspace/symbol"

/-- Method: `workspaceSymbol/resolve` -/
def WorkspaceSymbolResolveRequestMethod : String := "workspaceSymbol/resolve"

/-- Method: `textDocument/codeLens` -/
def CodeLensRequestMethod : String := "textDocument/codeLens"

/-- Method: `codeLens/resolve` -/
def CodeLensResolveRequestMethod : String := "codeLens/resolve"

/-- Method: `workspace/codeLens/refresh` -/
def CodeLensRefreshRequestMethod : String := "workspace/codeLens/refresh"

/-- Method: `textDocument/documentLink` -/
def DocumentLinkRequestMethod : String := "textDocument/documentLink"

/-- Method: `documentLink/resolve` -/
def DocumentLinkResolveRequestMethod : String := "documentLink/resolve"

/-- Method: `textDocument/formatting` -/
def DocumentFormattingRequestMethod : String := "textDocument/formatting"

/-- Method: `textDocument/rangeFormatting` -/
def DocumentRangeFormattingRequestMethod : String := "textDocument/rangeFormatting"

/-- Method: `textDocument/onTypeFormatting` -/
def DocumentOnTypeFormattingRequestMethod : String := "textDocument/onTypeFormatting"

/-- Method: `textDocument/rename` -/
def RenameRequestMethod : String := "textDocument/rename"

/-- Method: `textDocument/prepareRename` -/
def PrepareRenameRequestMethod : String := "textDocument/prepareRename"

/-- Method: `workspace/executeCommand` -/
def ExecuteCommandRequestMethod : String := "workspace/executeCommand"

/-- Method: `workspace/applyEdit` -/
def ApplyWorkspaceEditRequestMethod : String := "workspace/applyEdit"

/-! ## Notification Methods -/

/-- Method: `workspace/didChangeWorkspaceFolders` -/
def DidChangeWorkspaceFoldersNotificationMethod : String := "workspace/didChangeWorkspaceFolders"

/-- Method: `window/workDoneProgress/cancel` -/
def WorkDoneProgressCancelNotificationMethod : String := "window/workDoneProgress/cancel"

/-- Method: `workspace/didCreateFiles` -/
def DidCreateFilesNotificationMethod : String := "workspace/didCreateFiles"

/-- Method: `workspace/didRenameFiles` -/
def DidRenameFilesNotificationMethod : String := "workspace/didRenameFiles"

/-- Method: `workspace/didDeleteFiles` -/
def DidDeleteFilesNotificationMethod : String := "workspace/didDeleteFiles"

/-- Method: `notebookDocument/didOpen` -/
def DidOpenNotebookDocumentNotificationMethod : String := "notebookDocument/didOpen"

/-- Method: `notebookDocument/didChange` -/
def DidChangeNotebookDocumentNotificationMethod : String := "notebookDocument/didChange"

/-- Method: `notebookDocument/didSave` -/
def DidSaveNotebookDocumentNotificationMethod : String := "notebookDocument/didSave"

/-- Method: `notebookDocument/didClose` -/
def DidCloseNotebookDocumentNotificationMethod : String := "notebookDocument/didClose"

/-- Method: `initialized` -/
def InitializedNotificationMethod : String := "initialized"

/-- Method: `exit` -/
def ExitNotificationMethod : String := "exit"

/-- Method: `workspace/didChangeConfiguration` -/
def DidChangeConfigurationNotificationMethod : String := "workspace/didChangeConfiguration"

/-- Method: `window/showMessage` -/
def ShowMessageNotificationMethod : String := "window/showMessage"

/-- Method: `window/logMessage` -/
def LogMessageNotificationMethod : String := "window/logMessage"

/-- Method: `telemetry/event` -/
def TelemetryEventNotificationMethod : String := "telemetry/event"

/-- Method: `textDocument/didOpen` -/
def DidOpenTextDocumentNotificationMethod : String := "textDocument/didOpen"

/-- Method: `textDocument/didChange` -/
def DidChangeTextDocumentNotificationMethod : String := "textDocument/didChange"

/-- Method: `textDocument/didClose` -/
def DidCloseTextDocumentNotificationMethod : String := "textDocument/didClose"

/-- Method: `textDocument/didSave` -/
def DidSaveTextDocumentNotificationMethod : String := "textDocument/didSave"

/-- Method: `textDocument/willSave` -/
def WillSaveTextDocumentNotificationMethod : String := "textDocument/willSave"

/-- Method: `workspace/didChangeWatchedFiles` -/
def DidChangeWatchedFilesNotificationMethod : String := "workspace/didChangeWatchedFiles"

/-- Method: `textDocument/publishDiagnostics` -/
def PublishDiagnosticsNotificationMethod : String := "textDocument/publishDiagnostics"

/-- Method: `$/setTrace` -/
def SetTraceNotificationMethod : String := "$/setTrace"

/-- Method: `$/logTrace` -/
def LogTraceNotificationMethod : String := "$/logTrace"

/-- Method: `$/cancelRequest` -/
def CancelNotificationMethod : String := "$/cancelRequest"

/-- Method: `$/progress` -/
def ProgressNotificationMethod : String := "$/progress"

end Lapis.Protocol.Generated
