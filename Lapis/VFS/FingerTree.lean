/-
  A purely functional, persistent data structure providing:
  - O(1) amortized access at both ends
  - O(log n) concatenation and splitting
  - O(log n) indexed access via monoidal measures

  Based on Hinze & Paterson's "Finger Trees: A Simple General-purpose Data Structure"

  This implementation uses a concrete element type (Piece) and measure type
  for the piece table use case, avoiding the complexity of universe-polymorphic
  and nested finger trees in Lean 4.
-/

namespace Lapis.VFS.FingerTree

/-! ## Measure Type for Piece Table -/

/-- Measure for piece table: tracks byte count, UTF-16 units, and line count -/
structure Measure where
  bytes : Nat        -- UTF-8 byte count
  utf16Units : Nat   -- UTF-16 code unit count (for LSP compatibility)
  lines : Nat        -- Newline count
  deriving Repr, Inhabited, BEq

instance : Add Measure where
  add a b := {
    bytes := a.bytes + b.bytes
    utf16Units := a.utf16Units + b.utf16Units
    lines := a.lines + b.lines
  }

def Measure.empty : Measure := ⟨0, 0, 0⟩

/-! ## Elem: The element type stored in the tree

For the piece table, this will be a Piece descriptor.
We define a placeholder here that will be refined in PieceTable.lean
-/

/-- Placeholder element type - will be replaced by Piece in actual usage -/
structure Elem where
  measure : Measure
  deriving Repr, Inhabited

/-! ## Digit Type -/

/-- A digit holds 1-4 elements at the ends of a finger tree -/
inductive Digit
  | one : Elem → Digit
  | two : Elem → Elem → Digit
  | three : Elem → Elem → Elem → Digit
  | four : Elem → Elem → Elem → Elem → Digit
  deriving Repr, Inhabited

namespace Digit

/-- Convert a digit to a list -/
def toList : Digit → List Elem
  | one a => [a]
  | two a b => [a, b]
  | three a b c => [a, b, c]
  | four a b c d => [a, b, c, d]

/-- Get the head element of a digit -/
def head : Digit → Elem
  | one a => a
  | two a _ => a
  | three a _ _ => a
  | four a _ _ _ => a

/-- Get the last element of a digit -/
def last : Digit → Elem
  | one a => a
  | two _ b => b
  | three _ _ c => c
  | four _ _ _ d => d

/-- Remove the head element, returning the tail if non-empty -/
def tail? : Digit → Option Digit
  | one _ => none
  | two _ b => some (one b)
  | three _ b c => some (two b c)
  | four _ b c d => some (three b c d)

/-- Remove the last element, returning the init if non-empty -/
def init? : Digit → Option Digit
  | one _ => none
  | two a _ => some (one a)
  | three a b _ => some (two a b)
  | four a b c _ => some (three a b c)

/-- Create a digit from a non-empty list (1-4 elements) -/
def fromList? : List Elem → Option Digit
  | [a] => some (one a)
  | [a, b] => some (two a b)
  | [a, b, c] => some (three a b c)
  | [a, b, c, d] => some (four a b c d)
  | _ => none

/-- Measure a digit by combining measures of its elements -/
def measure : Digit → Measure
  | one a => a.measure
  | two a b => a.measure + b.measure
  | three a b c => a.measure + b.measure + c.measure
  | four a b c d => a.measure + b.measure + c.measure + d.measure

end Digit

/-! ## Node Type -/

/-- A node is a 2-3 node with cached measure -/
inductive Node
  | node2 : Measure → Elem → Elem → Node
  | node3 : Measure → Elem → Elem → Elem → Node
  deriving Repr, Inhabited

namespace Node

/-- Get the cached measure of a node -/
def measure : Node → Measure
  | node2 v _ _ => v
  | node3 v _ _ _ => v

/-- Convert a node to a digit -/
def toDigit : Node → Digit
  | node2 _ a b => Digit.two a b
  | node3 _ a b c => Digit.three a b c

/-- Convert a node to a list -/
def toList : Node → List Elem
  | node2 _ a b => [a, b]
  | node3 _ a b c => [a, b, c]

/-- Create a 2-node with computed measure -/
def mk2 (a b : Elem) : Node :=
  .node2 (a.measure + b.measure) a b

/-- Create a 3-node with computed measure -/
def mk3 (a b c : Elem) : Node :=
  .node3 (a.measure + b.measure + c.measure) a b c

/-- Convert a node to an element (for spine trees) -/
def toElem (n : Node) : Elem :=
  { measure := n.measure }

end Node

/-! ## Spine Type

The spine is a separate type that holds nodes.
We use mutual inductive types to handle the nesting.
-/

/-- Node digit for spine -/
inductive NodeDigit
  | one : Node → NodeDigit
  | two : Node → Node → NodeDigit
  | three : Node → Node → Node → NodeDigit
  | four : Node → Node → Node → Node → NodeDigit
  deriving Repr, Inhabited

namespace NodeDigit

def toList : NodeDigit → List Node
  | one a => [a]
  | two a b => [a, b]
  | three a b c => [a, b, c]
  | four a b c d => [a, b, c, d]

def head : NodeDigit → Node
  | one a => a
  | two a _ => a
  | three a _ _ => a
  | four a _ _ _ => a

def last : NodeDigit → Node
  | one a => a
  | two _ b => b
  | three _ _ c => c
  | four _ _ _ d => d

def tail? : NodeDigit → Option NodeDigit
  | one _ => none
  | two _ b => some (one b)
  | three _ b c => some (two b c)
  | four _ b c d => some (three b c d)

def init? : NodeDigit → Option NodeDigit
  | one _ => none
  | two a _ => some (one a)
  | three a b _ => some (two a b)
  | four a b c _ => some (three a b c)

def fromList? : List Node → Option NodeDigit
  | [a] => some (one a)
  | [a, b] => some (two a b)
  | [a, b, c] => some (three a b c)
  | [a, b, c, d] => some (four a b c d)
  | _ => none

def measure : NodeDigit → Measure
  | one a => a.measure
  | two a b => a.measure + b.measure
  | three a b c => a.measure + b.measure + c.measure
  | four a b c d => a.measure + b.measure + c.measure + d.measure

end NodeDigit

/-! ## Spine

A spine is a finger tree of nodes. We define it as a separate inductive
to avoid nested inductive issues.
-/

/-- Spine: a finger tree of nodes -/
inductive Spine
  | empty : Spine
  | single : Node → Spine
  | deep : Measure → NodeDigit → (Unit → Spine) → NodeDigit → Spine
  deriving Inhabited

namespace Spine

def measure : Spine → Measure
  | empty => Measure.empty
  | single n => n.measure
  | deep m _ _ _ => m

def isEmpty : Spine → Bool
  | empty => true
  | _ => false

end Spine

/-! ## Finger Tree Type -/

/--
A finger tree is either empty, a single element, or a deep tree.
-/
inductive FingerTree
  | empty : FingerTree
  | single : Elem → FingerTree
  | deep : Measure → Digit → (Unit → Spine) → Digit → FingerTree
  deriving Inhabited

namespace FingerTree

/-- Get the measure of a tree -/
def measure : FingerTree → Measure
  | empty => Measure.empty
  | single a => a.measure
  | deep m _ _ _ => m

/-- Check if tree is empty -/
def isEmpty : FingerTree → Bool
  | empty => true
  | _ => false

/-- Create a deep tree with computed measure -/
def mkDeep (pr : Digit) (sp : Unit → Spine) (sf : Digit) : FingerTree :=
  let spMeas := (sp ()).measure
  deep (pr.measure + spMeas + sf.measure) pr sp sf

/-- Create a singleton tree -/
def singleton (a : Elem) : FingerTree := single a

/-! ### Spine operations (forward declarations needed) -/

/-- Create node from two elements -/
private def mkNode2 (a b : Elem) : Node := Node.mk2 a b

/-- Create node from three elements -/
private def mkNode3 (a b c : Elem) : Node := Node.mk3 a b c

/-- Deep spine with computed measure -/
def mkSpineDeep (pr : NodeDigit) (sp : Unit → Spine) (sf : NodeDigit) : Spine :=
  let spMeas := (sp ()).measure
  Spine.deep (pr.measure + spMeas + sf.measure) pr sp sf

/-- Convert NodeDigit to Spine -/
def nodeDigitToSpine : NodeDigit → Spine
  | .one a => Spine.single a
  | .two a b => mkSpineDeep (.one a) (fun _ => Spine.empty) (.one b)
  | .three a b c => mkSpineDeep (.two a b) (fun _ => Spine.empty) (.one c)
  | .four a b c d => mkSpineDeep (.two a b) (fun _ => Spine.empty) (.two c d)

/-- Create node2 from two nodes -/
private def mkNodeNode2 (a b : Node) : Node :=
  Node.node2 (a.measure + b.measure) a.toElem b.toElem

/-- Create node3 from three nodes -/
private def mkNodeNode3 (a b c : Node) : Node :=
  Node.node3 (a.measure + b.measure + c.measure) a.toElem b.toElem c.toElem

/-! ### Spine cons/snoc -/

partial def spineCons (n : Node) (sp : Spine) : Spine :=
  match sp with
  | .empty => .single n
  | .single m => mkSpineDeep (.one n) (fun _ => .empty) (.one m)
  | .deep m pr spThunk sf =>
    match pr with
    | .one b => .deep (n.measure + m) (.two n b) spThunk sf
    | .two b c => .deep (n.measure + m) (.three n b c) spThunk sf
    | .three b c e => .deep (n.measure + m) (.four n b c e) spThunk sf
    | .four b c e f =>
      let node := mkNodeNode3 c e f
      let newSpine := fun _ => spineCons node (spThunk ())
      mkSpineDeep (.two n b) newSpine sf

partial def spineSnoc (sp : Spine) (n : Node) : Spine :=
  match sp with
  | .empty => .single n
  | .single m => mkSpineDeep (.one m) (fun _ => .empty) (.one n)
  | .deep m pr spThunk sf =>
    match sf with
    | .one b => .deep (m + n.measure) pr spThunk (.two b n)
    | .two b c => .deep (m + n.measure) pr spThunk (.three b c n)
    | .three b c e => .deep (m + n.measure) pr spThunk (.four b c e n)
    | .four b c e f =>
      let node := mkNodeNode3 b c e
      let newSpine := fun _ => spineSnoc (spThunk ()) node
      mkSpineDeep pr newSpine (.two f n)

/-! ### Spine views -/

inductive SpineViewL
  | nil : SpineViewL
  | cons : Node → Spine → SpineViewL
  deriving Inhabited

inductive SpineViewR
  | nil : SpineViewR
  | snoc : Spine → Node → SpineViewR
  deriving Inhabited

partial def spineViewL (sp : Spine) : SpineViewL :=
  match sp with
  | .empty => .nil
  | .single n => .cons n .empty
  | .deep _ pr spThunk sf =>
    let rest := spineDeepL pr.tail? spThunk sf
    .cons pr.head rest
where
  spineDeepL (pr : Option NodeDigit) (sp : Unit → Spine) (sf : NodeDigit) : Spine :=
    match pr with
    | some pr' => mkSpineDeep pr' sp sf
    | none =>
      match spineViewL (sp ()) with
      | .nil => nodeDigitToSpine sf
      | .cons node rest => mkSpineDeep (NodeDigit.one node) (fun _ => rest) sf

partial def spineViewR (sp : Spine) : SpineViewR :=
  match sp with
  | .empty => .nil
  | .single n => .snoc .empty n
  | .deep _ pr spThunk sf =>
    let rest := spineDeepR pr spThunk sf.init?
    .snoc rest sf.last
where
  spineDeepR (pr : NodeDigit) (sp : Unit → Spine) (sf : Option NodeDigit) : Spine :=
    match sf with
    | some sf' => mkSpineDeep pr sp sf'
    | none =>
      match spineViewR (sp ()) with
      | .nil => nodeDigitToSpine pr
      | .snoc rest node => mkSpineDeep pr (fun _ => rest) (.one node)

/-! ### Adding elements -/

/-- Prepend an element to the tree -/
partial def cons (a : Elem) (t : FingerTree) : FingerTree :=
  match t with
  | empty => single a
  | single b => mkDeep (.one a) (fun _ => .empty) (.one b)
  | deep m pr sp sf =>
    match pr with
    | .one b => deep (a.measure + m) (.two a b) sp sf
    | .two b c => deep (a.measure + m) (.three a b c) sp sf
    | .three b c e => deep (a.measure + m) (.four a b c e) sp sf
    | .four b c e f =>
      let node := mkNode3 c e f
      let newSpine := fun _ => spineCons node (sp ())
      mkDeep (.two a b) newSpine sf

/-- Append an element to the tree -/
partial def snoc (t : FingerTree) (a : Elem) : FingerTree :=
  match t with
  | empty => single a
  | single b => mkDeep (.one b) (fun _ => .empty) (.one a)
  | deep m pr sp sf =>
    match sf with
    | .one b => deep (m + a.measure) pr sp (.two b a)
    | .two b c => deep (m + a.measure) pr sp (.three b c a)
    | .three b c e => deep (m + a.measure) pr sp (.four b c e a)
    | .four b c e f =>
      let node := mkNode3 b c e
      let newSpine := fun _ => spineSnoc (sp ()) node
      mkDeep pr newSpine (.two f a)

/-! ### Views -/

/-- View from the left -/
inductive ViewL
  | nil : ViewL
  | cons : Elem → FingerTree → ViewL
  deriving Inhabited

/-- View from the right -/
inductive ViewR
  | nil : ViewR
  | snoc : FingerTree → Elem → ViewR
  deriving Inhabited

/-- Convert a digit to a tree -/
def digitToTree : Digit → FingerTree
  | .one a => single a
  | .two a b => mkDeep (.one a) (fun _ => .empty) (.one b)
  | .three a b c => mkDeep (.two a b) (fun _ => .empty) (.one c)
  | .four a b c d => mkDeep (.two a b) (fun _ => .empty) (.two c d)

/-- View from the left with helper -/
partial def viewL (t : FingerTree) : ViewL :=
  match t with
  | empty => .nil
  | single a => .cons a empty
  | deep _ pr sp sf =>
    let rest := deepL pr.tail? sp sf
    .cons pr.head rest
where
  deepL (pr : Option Digit) (sp : Unit → Spine) (sf : Digit) : FingerTree :=
    match pr with
    | some pr' => mkDeep pr' sp sf
    | none =>
      match spineViewL (sp ()) with
      | .nil => digitToTree sf
      | .cons node rest => mkDeep node.toDigit (fun _ => rest) sf

/-- View from the right with helper -/
partial def viewR (t : FingerTree) : ViewR :=
  match t with
  | empty => .nil
  | single a => .snoc empty a
  | deep _ pr sp sf =>
    let rest := deepR pr sp sf.init?
    .snoc rest sf.last
where
  deepR (pr : Digit) (sp : Unit → Spine) (sf : Option Digit) : FingerTree :=
    match sf with
    | some sf' => mkDeep pr sp sf'
    | none =>
      match spineViewR (sp ()) with
      | .nil => digitToTree pr
      | .snoc rest node => mkDeep pr (fun _ => rest) node.toDigit

/-- Get head element -/
def head? (t : FingerTree) : Option Elem :=
  match viewL t with
  | .nil => none
  | .cons a _ => some a

/-- Get tail -/
def tail? (t : FingerTree) : Option FingerTree :=
  match viewL t with
  | .nil => none
  | .cons _ rest => some rest

/-- Get last element -/
def last? (t : FingerTree) : Option Elem :=
  match viewR t with
  | .nil => none
  | .snoc _ a => some a

/-- Get init (all but last) -/
def init? (t : FingerTree) : Option FingerTree :=
  match viewR t with
  | .nil => none
  | .snoc rest _ => some rest

/-! ### Concatenation -/

/-- Convert list of Elems to nodes -/
private def nodes : List Elem → List Node
  | [a, b] => [Node.mk2 a b]
  | [a, b, c] => [Node.mk3 a b c]
  | [a, b, c, d] => [Node.mk2 a b, Node.mk2 c d]
  | a :: b :: c :: rest => Node.mk3 a b c :: nodes rest
  | _ => []

/-- Convert list of Nodes to higher-level nodes -/
private def nodeNodes : List Node → List Node
  | [a, b] => [mkNodeNode2 a b]
  | [a, b, c] => [mkNodeNode3 a b c]
  | [a, b, c, d] => [mkNodeNode2 a b, mkNodeNode2 c d]
  | a :: b :: c :: rest => mkNodeNode3 a b c :: nodeNodes rest
  | _ => []

/-- Append list to tree -/
private partial def appendList : FingerTree → List Elem → FingerTree
  | t, [] => t
  | t, a :: as => appendList (snoc t a) as

/-- Prepend list to tree -/
private partial def prependList : List Elem → FingerTree → FingerTree
  | [], t => t
  | a :: as, t => cons a (prependList as t)

/-- Append list of nodes to spine -/
private partial def appendSpineList : Spine → List Node → Spine
  | sp, [] => sp
  | sp, n :: ns => appendSpineList (spineSnoc sp n) ns

/-- Prepend list of nodes to spine -/
private partial def prependSpineList : List Node → Spine → Spine
  | [], sp => sp
  | n :: ns, sp => spineCons n (prependSpineList ns sp)

/-- Concatenate spines with middle nodes -/
partial def appendSpine3 (sp1 : Spine) (mid : List Node) (sp2 : Spine) : Spine :=
  match sp1, sp2 with
  | .empty, _ => prependSpineList mid sp2
  | _, .empty => appendSpineList sp1 mid
  | .single a, _ => spineCons a (prependSpineList mid sp2)
  | _, .single a => spineSnoc (appendSpineList sp1 mid) a
  | .deep _ pr1 sp1Thunk sf1, .deep _ pr2 sp2Thunk sf2 =>
    let mid' := sf1.toList ++ mid ++ pr2.toList
    mkSpineDeep pr1 (fun _ => appendSpine3 (sp1Thunk ()) (nodeNodes mid') (sp2Thunk ())) sf2

/-- Concatenate with middle elements -/
partial def append3 (t1 : FingerTree) (mid : List Elem) (t2 : FingerTree) : FingerTree :=
  match t1, t2 with
  | empty, _ => prependList mid t2
  | _, empty => appendList t1 mid
  | single a, _ => cons a (prependList mid t2)
  | _, single a => snoc (appendList t1 mid) a
  | deep _ pr1 sp1 sf1, deep _ pr2 sp2 sf2 =>
    let mid' := sf1.toList ++ mid ++ pr2.toList
    mkDeep pr1 (fun _ => appendSpine3 (sp1 ()) (nodes mid') (sp2 ())) sf2

/-- Concatenate two trees -/
def append (t1 t2 : FingerTree) : FingerTree :=
  append3 t1 [] t2

instance : Append FingerTree where
  append := append

/-! ### Splitting -/

/-- Split result -/
structure Split where
  left : FingerTree
  pivot : Elem
  right : FingerTree
  deriving Inhabited

/-- Digit split result -/
private structure DigitSplit where
  left : List Elem
  pivot : Elem
  right : List Elem

/-- Node split result -/
private structure NodeSplit where
  left : List Node
  pivot : Node
  right : List Node

/-- Split a digit -/
private def splitDigit (p : Measure → Bool) (acc : Measure) : Digit → DigitSplit
  | .one a => ⟨[], a, []⟩
  | .two a b =>
    let acc' := acc + a.measure
    if p acc' then ⟨[], a, [b]⟩ else ⟨[a], b, []⟩
  | .three a b c =>
    let acc' := acc + a.measure
    if p acc' then ⟨[], a, [b, c]⟩
    else
      let acc'' := acc' + b.measure
      if p acc'' then ⟨[a], b, [c]⟩ else ⟨[a, b], c, []⟩
  | .four a b c d =>
    let acc' := acc + a.measure
    if p acc' then ⟨[], a, [b, c, d]⟩
    else
      let acc'' := acc' + b.measure
      if p acc'' then ⟨[a], b, [c, d]⟩
      else
        let acc''' := acc'' + c.measure
        if p acc''' then ⟨[a, b], c, [d]⟩ else ⟨[a, b, c], d, []⟩

/-- Split a node digit -/
private def splitNodeDigit (p : Measure → Bool) (acc : Measure) : NodeDigit → NodeSplit
  | .one a => ⟨[], a, []⟩
  | .two a b =>
    let acc' := acc + a.measure
    if p acc' then ⟨[], a, [b]⟩ else ⟨[a], b, []⟩
  | .three a b c =>
    let acc' := acc + a.measure
    if p acc' then ⟨[], a, [b, c]⟩
    else
      let acc'' := acc' + b.measure
      if p acc'' then ⟨[a], b, [c]⟩ else ⟨[a, b], c, []⟩
  | .four a b c d =>
    let acc' := acc + a.measure
    if p acc' then ⟨[], a, [b, c, d]⟩
    else
      let acc'' := acc' + b.measure
      if p acc'' then ⟨[a], b, [c, d]⟩
      else
        let acc''' := acc'' + c.measure
        if p acc''' then ⟨[a, b], c, [d]⟩ else ⟨[a, b, c], d, []⟩

/-- Build tree from list -/
def fromList : List Elem → FingerTree
  | [] => empty
  | as => as.foldl snoc empty

/-- Helper to create a deep tree handling empty prefix for splitting -/
private partial def deepLSplit (pr : Option Digit) (sp : Unit → Spine) (sf : Digit) : FingerTree :=
  match pr with
  | some pr' => mkDeep pr' sp sf
  | none =>
    match spineViewL (sp ()) with
    | .nil => digitToTree sf
    | .cons node rest => mkDeep node.toDigit (fun _ => rest) sf

/-- Helper to create a deep tree handling empty suffix for splitting -/
private partial def deepRSplit (pr : Digit) (sp : Unit → Spine) (sf : Option Digit) : FingerTree :=
  match sf with
  | some sf' => mkDeep pr sp sf'
  | none =>
    match spineViewR (sp ()) with
    | .nil => digitToTree pr
    | .snoc rest node => mkDeep pr (fun _ => rest) node.toDigit

/-- Helper to build spine from node list -/
private def spineFromNodeList : List Node → Spine
  | [] => .empty
  | ns => ns.foldl spineSnoc .empty

/-- Deep spine handling empty prefix -/
private partial def spineDeepLSplit (pr : Option NodeDigit) (sp : Unit → Spine) (sf : NodeDigit) : Spine :=
  match pr with
  | some pr' => mkSpineDeep pr' sp sf
  | none =>
    match spineViewL (sp ()) with
    | .nil => nodeDigitToSpine sf
    | .cons node rest => mkSpineDeep (NodeDigit.one node) (fun _ => rest) sf

/-- Deep spine handling empty suffix -/
private partial def spineDeepRSplit (pr : NodeDigit) (sp : Unit → Spine) (sf : Option NodeDigit) : Spine :=
  match sf with
  | some sf' => mkSpineDeep pr sp sf'
  | none =>
    match spineViewR (sp ()) with
    | .nil => nodeDigitToSpine pr
    | .snoc rest node => mkSpineDeep pr (fun _ => rest) (NodeDigit.one node)

/-- Spine split result -/
private structure SpineSplit where
  left : Spine
  pivot : Node
  right : Spine
  deriving Inhabited

/-- Split spine -/
private partial def splitSpineAux (p : Measure → Bool) (acc : Measure) (sp : Spine) : SpineSplit :=
  match sp with
  | .empty => panic! "splitSpineAux called on empty spine"
  | .single n => ⟨.empty, n, .empty⟩
  | .deep _ pr spThunk sf =>
    let accPr := acc + pr.measure
    if p accPr then
      let ⟨l, x, r⟩ := splitNodeDigit p acc pr
      ⟨spineFromNodeList l, x, spineDeepLSplit (NodeDigit.fromList? r) spThunk sf⟩
    else
      let spTree := spThunk ()
      let accPrSp := accPr + spTree.measure
      if p accPrSp then
        let ⟨spl, node, spr⟩ := splitSpineAux p accPr spTree
        let accNode := accPr + spl.measure
        let nodeDigit := NodeDigit.one node
        let ⟨l, x, r⟩ := splitNodeDigit p accNode nodeDigit
        ⟨spineDeepRSplit pr (fun _ => spl) (NodeDigit.fromList? l), x, spineDeepLSplit (NodeDigit.fromList? r) (fun _ => spr) sf⟩
      else
        let ⟨l, x, r⟩ := splitNodeDigit p accPrSp sf
        ⟨spineDeepRSplit pr spThunk (NodeDigit.fromList? l), x, spineFromNodeList r⟩

/-- Internal split - panics on empty tree -/
private partial def splitTreeAux (p : Measure → Bool) (acc : Measure) (t : FingerTree) : Split :=
  match t with
  | empty => panic! "splitTreeAux called on empty tree"
  | single a => ⟨empty, a, empty⟩
  | deep _ pr sp sf =>
    let accPr := acc + pr.measure
    if p accPr then
      let ⟨l, x, r⟩ := splitDigit p acc pr
      ⟨fromList l, x, deepLSplit (Digit.fromList? r) sp sf⟩
    else
      let spTree := sp ()
      let accPrSp := accPr + spTree.measure
      if p accPrSp then
        let ⟨spl, node, spr⟩ := splitSpineAux p accPr spTree
        let accNode := accPr + spl.measure
        let nodeDigit := node.toDigit
        let ⟨l, x, r⟩ := splitDigit p accNode nodeDigit
        ⟨deepRSplit pr (fun _ => spl) (Digit.fromList? l), x, deepLSplit (Digit.fromList? r) (fun _ => spr) sf⟩
      else
        let ⟨l, x, r⟩ := splitDigit p accPrSp sf
        ⟨deepRSplit pr sp (Digit.fromList? l), x, fromList r⟩

/-- Split tree at predicate -/
def split (p : Measure → Bool) (t : FingerTree) : Option Split :=
  if t.isEmpty then none
  else if !p t.measure then none
  else some (splitTreeAux p Measure.empty t)

/-- Split at byte position -/
def splitAtBytes (n : Nat) (t : FingerTree) : Option Split :=
  if n == 0 then
    match viewL t with
    | .nil => none
    | .cons a rest => some ⟨empty, a, rest⟩
  else
    split (fun m => m.bytes >= n) t

/-- Split at line number -/
def splitAtLine (n : Nat) (t : FingerTree) : Option Split :=
  if n == 0 then
    match viewL t with
    | .nil => none
    | .cons a rest => some ⟨empty, a, rest⟩
  else
    split (fun m => m.lines >= n) t

/-! ### Conversion -/

/-- Convert to list -/
partial def toList (t : FingerTree) : List Elem :=
  match viewL t with
  | .nil => []
  | .cons a rest => a :: toList rest

/-- Fold left -/
def foldl (f : β → Elem → β) (init : β) (t : FingerTree) : β :=
  t.toList.foldl f init

/-- Fold right -/
def foldr (f : Elem → β → β) (init : β) (t : FingerTree) : β :=
  t.toList.foldr f init

end FingerTree

end Lapis.VFS.FingerTree
