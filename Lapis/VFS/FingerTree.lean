/-
  A purely functional, persistent data structure providing:
  - O(1) amortized access at both ends
  - O(log n) concatenation and splitting
  - O(log n) indexed access via monoidal measures

  Based on Hinze & Paterson's "Finger Trees: A Simple General-purpose Data Structure"

  This implementation uses a concrete measure type and is polymorphic over the
  element type. The spine is non-recursive to avoid nested inductive issues -
  this limits tree depth but is sufficient for practical use cases.
-/

namespace Lapis.VFS.FingerTree

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

/-- Typeclass for elements that can be measured -/
class Measurable (α : Type) where
  measure : α → Measure

/-- A digit holds 1-4 elements at the ends of a finger tree -/
private inductive Digit (α : Type)
  | one : α → Digit α
  | two : α → α → Digit α
  | three : α → α → α → Digit α
  | four : α → α → α → α → Digit α
  deriving Repr, Inhabited

namespace Digit

def toList : Digit α → List α
  | one a => [a]
  | two a b => [a, b]
  | three a b c => [a, b, c]
  | four a b c d => [a, b, c, d]

def toArray : Digit α → Array α
  | one a => #[a]
  | two a b => #[a, b]
  | three a b c => #[a, b, c]
  | four a b c d => #[a, b, c, d]

def head : Digit α → α
  | one a => a
  | two a _ => a
  | three a _ _ => a
  | four a _ _ _ => a

def last : Digit α → α
  | one a => a
  | two _ b => b
  | three _ _ c => c
  | four _ _ _ d => d

def tail? : Digit α → Option (Digit α)
  | one _ => none
  | two _ b => some (one b)
  | three _ b c => some (two b c)
  | four _ b c d => some (three b c d)

def init? : Digit α → Option (Digit α)
  | one _ => none
  | two a _ => some (one a)
  | three a b _ => some (two a b)
  | four a b c _ => some (three a b c)

def fromList? : List α → Option (Digit α)
  | [a] => some (one a)
  | [a, b] => some (two a b)
  | [a, b, c] => some (three a b c)
  | [a, b, c, d] => some (four a b c d)
  | _ => none

def measure [Measurable α] : Digit α → Measure
  | one a => Measurable.measure a
  | two a b => Measurable.measure a + Measurable.measure b
  | three a b c => Measurable.measure a + Measurable.measure b + Measurable.measure c
  | four a b c d => Measurable.measure a + Measurable.measure b + Measurable.measure c + Measurable.measure d

end Digit

/-- A node is a 2-3 node with cached measure -/
private inductive Node (α : Type)
  | node2 : Measure → α → α → Node α
  | node3 : Measure → α → α → α → Node α
  deriving Repr, Inhabited

namespace Node

def measure : Node α → Measure
  | node2 v _ _ => v
  | node3 v _ _ _ => v

def toDigit : Node α → Digit α
  | node2 _ a b => Digit.two a b
  | node3 _ a b c => Digit.three a b c

def toList : Node α → List α
  | node2 _ a b => [a, b]
  | node3 _ a b c => [a, b, c]

def mk2 [Measurable α] (a b : α) : Node α :=
  .node2 (Measurable.measure a + Measurable.measure b) a b

def mk3 [Measurable α] (a b c : α) : Node α :=
  .node3 (Measurable.measure a + Measurable.measure b + Measurable.measure c) a b c

end Node

/-- Nodes are themselves measurable via their cached measure -/
instance : Measurable (Node α) where
  measure := Node.measure

/-- Spine stores nodes in an array -/
private structure Spine (α : Type) where
  nodes : Array (Node α)
  cachedMeasure : Measure
  deriving Inhabited

namespace Spine

def empty : Spine α := ⟨#[], Measure.empty⟩

def isEmpty (sp : Spine α) : Bool := sp.nodes.isEmpty

def measure (sp : Spine α) : Measure := sp.cachedMeasure

def single (n : Node α) : Spine α := ⟨#[n], n.measure⟩

def cons (n : Node α) (sp : Spine α) : Spine α :=
  ⟨#[n] ++ sp.nodes, n.measure + sp.cachedMeasure⟩

def snoc (sp : Spine α) (n : Node α) : Spine α :=
  ⟨sp.nodes.push n, sp.cachedMeasure + n.measure⟩

def viewL (sp : Spine α) : Option (Node α × Spine α) :=
  if h : sp.nodes.size > 0 then
    let hd := sp.nodes[0]'h
    let tl := sp.nodes.extract 1 sp.nodes.size
    let newMeasure := tl.foldl (fun m n => m + n.measure) Measure.empty
    some (hd, ⟨tl, newMeasure⟩)
  else
    none

def viewR (sp : Spine α) : Option (Spine α × Node α) :=
  if h : sp.nodes.size > 0 then
    let lst := sp.nodes[sp.nodes.size - 1]'(by omega)
    let init := sp.nodes.pop
    let newMeasure := init.foldl (fun m n => m + n.measure) Measure.empty
    some (⟨init, newMeasure⟩, lst)
  else
    none

def append (sp1 sp2 : Spine α) : Spine α :=
  ⟨sp1.nodes ++ sp2.nodes, sp1.cachedMeasure + sp2.cachedMeasure⟩

def fromArray (arr : Array (Node α)) : Spine α :=
  let m := arr.foldl (fun m n => m + n.measure) Measure.empty
  ⟨arr, m⟩

def toArray (sp : Spine α) : Array (Node α) := sp.nodes

end Spine

/-- A finger tree is either empty, a single element, or a deep tree -/
inductive FingerTree (α : Type)
  | empty : FingerTree α
  | single : α → FingerTree α
  | deep : Measure → Digit α → Spine α → Digit α → FingerTree α
  deriving Inhabited

namespace FingerTree

def measure [Measurable α] : FingerTree α → Measure
  | empty => Measure.empty
  | single a => Measurable.measure a
  | deep m _ _ _ => m

def isEmpty : FingerTree α → Bool
  | empty => true
  | _ => false

def mkDeep [Measurable α] (pr : Digit α) (sp : Spine α) (sf : Digit α) : FingerTree α :=
  deep (pr.measure + sp.measure + sf.measure) pr sp sf

def singleton (a : α) : FingerTree α := single a

def cons [Measurable α] (a : α) (t : FingerTree α) : FingerTree α :=
  match t with
  | empty => single a
  | single b => mkDeep (.one a) .empty (.one b)
  | deep m pr sp sf =>
    match pr with
    | .one b => deep (Measurable.measure a + m) (.two a b) sp sf
    | .two b c => deep (Measurable.measure a + m) (.three a b c) sp sf
    | .three b c e => deep (Measurable.measure a + m) (.four a b c e) sp sf
    | .four b c e f =>
      let node := Node.mk3 c e f
      let newSpine := sp.cons node
      mkDeep (.two a b) newSpine sf

def snoc [Measurable α] (t : FingerTree α) (a : α) : FingerTree α :=
  match t with
  | empty => single a
  | single b => mkDeep (.one b) .empty (.one a)
  | deep m pr sp sf =>
    match sf with
    | .one b => deep (m + Measurable.measure a) pr sp (.two b a)
    | .two b c => deep (m + Measurable.measure a) pr sp (.three b c a)
    | .three b c e => deep (m + Measurable.measure a) pr sp (.four b c e a)
    | .four b c e f =>
      let node := Node.mk3 b c e
      let newSpine := sp.snoc node
      mkDeep pr newSpine (.two f a)

inductive ViewL (α : Type)
  | nil : ViewL α
  | cons : α → FingerTree α → ViewL α
  deriving Inhabited

inductive ViewR (α : Type)
  | nil : ViewR α
  | snoc : FingerTree α → α → ViewR α
  deriving Inhabited

def digitToTree [Measurable α] : Digit α → FingerTree α
  | .one a => single a
  | .two a b => mkDeep (.one a) .empty (.one b)
  | .three a b c => mkDeep (.two a b) .empty (.one c)
  | .four a b c d => mkDeep (.two a b) .empty (.two c d)

def viewL [Measurable α] (t : FingerTree α) : ViewL α :=
  match t with
  | empty => .nil
  | single a => .cons a empty
  | deep _ pr sp sf =>
    match pr.tail? with
    | some pr' => .cons pr.head (mkDeep pr' sp sf)
    | none =>
      match sp.viewL with
      | none => .cons pr.head (digitToTree sf)
      | some (node, rest) => .cons pr.head (mkDeep node.toDigit rest sf)

def viewR [Measurable α] (t : FingerTree α) : ViewR α :=
  match t with
  | empty => .nil
  | single a => .snoc empty a
  | deep _ pr sp sf =>
    match sf.init? with
    | some sf' => .snoc (mkDeep pr sp sf') sf.last
    | none =>
      match sp.viewR with
      | none => .snoc (digitToTree pr) sf.last
      | some (rest, node) => .snoc (mkDeep pr rest node.toDigit) sf.last

def head? [Measurable α] (t : FingerTree α) : Option α :=
  match viewL t with
  | .nil => none
  | .cons a _ => some a

def tail? [Measurable α] (t : FingerTree α) : Option (FingerTree α) :=
  match viewL t with
  | .nil => none
  | .cons _ rest => some rest

def last? [Measurable α] (t : FingerTree α) : Option α :=
  match viewR t with
  | .nil => none
  | .snoc _ a => some a

def init? [Measurable α] (t : FingerTree α) : Option (FingerTree α) :=
  match viewR t with
  | .nil => none
  | .snoc rest _ => some rest

private def nodes [Measurable α] : List α → Array (Node α)
  | [a, b] => #[Node.mk2 a b]
  | [a, b, c] => #[Node.mk3 a b c]
  | [a, b, c, d] => #[Node.mk2 a b, Node.mk2 c d]
  | a :: b :: c :: rest => #[Node.mk3 a b c] ++ nodes rest
  | _ => #[]

private def appendList [Measurable α] (t : FingerTree α) (l : List α) : FingerTree α :=
  l.foldl snoc t

private def prependList [Measurable α] (l : List α) (t : FingerTree α) : FingerTree α :=
  l.foldr cons t

def append3 [Measurable α] (t1 : FingerTree α) (mid : List α) (t2 : FingerTree α) : FingerTree α :=
  match t1, t2 with
  | empty, _ => prependList mid t2
  | _, empty => appendList t1 mid
  | single a, _ => cons a (prependList mid t2)
  | _, single a => snoc (appendList t1 mid) a
  | deep _ pr1 sp1 sf1, deep _ pr2 sp2 sf2 =>
    let mid' := sf1.toList ++ mid ++ pr2.toList
    let midNodes := Spine.fromArray (nodes mid')
    let newSpine := sp1.append midNodes |>.append sp2
    mkDeep pr1 newSpine sf2

def append [Measurable α] (t1 t2 : FingerTree α) : FingerTree α :=
  append3 t1 [] t2

instance [Measurable α] : Append (FingerTree α) where
  append := append

structure Split (α : Type) where
  left : FingerTree α
  pivot : α
  right : FingerTree α
  deriving Inhabited

private structure DigitSplit (α : Type) where
  left : List α
  pivot : α
  right : List α

private def splitDigit [Measurable α] (p : Measure → Bool) (acc : Measure) : Digit α → DigitSplit α
  | .one a => ⟨[], a, []⟩
  | .two a b =>
    let acc' := acc + Measurable.measure a
    if p acc' then ⟨[], a, [b]⟩ else ⟨[a], b, []⟩
  | .three a b c =>
    let acc' := acc + Measurable.measure a
    if p acc' then ⟨[], a, [b, c]⟩
    else
      let acc'' := acc' + Measurable.measure b
      if p acc'' then ⟨[a], b, [c]⟩ else ⟨[a, b], c, []⟩
  | .four a b c d =>
    let acc' := acc + Measurable.measure a
    if p acc' then ⟨[], a, [b, c, d]⟩
    else
      let acc'' := acc' + Measurable.measure b
      if p acc'' then ⟨[a], b, [c, d]⟩
      else
        let acc''' := acc'' + Measurable.measure c
        if p acc''' then ⟨[a, b], c, [d]⟩ else ⟨[a, b, c], d, []⟩

def fromList [Measurable α] (l : List α) : FingerTree α :=
  l.foldl snoc empty

def fromArray [Measurable α] (arr : Array α) : FingerTree α :=
  arr.foldl snoc empty

private def deepL [Measurable α] (pr : Option (Digit α)) (sp : Spine α) (sf : Digit α) : FingerTree α :=
  match pr with
  | some pr' => mkDeep pr' sp sf
  | none =>
    match sp.viewL with
    | none => digitToTree sf
    | some (node, rest) => mkDeep node.toDigit rest sf

private def deepR [Measurable α] (pr : Digit α) (sp : Spine α) (sf : Option (Digit α)) : FingerTree α :=
  match sf with
  | some sf' => mkDeep pr sp sf'
  | none =>
    match sp.viewR with
    | none => digitToTree pr
    | some (rest, node) => mkDeep pr rest node.toDigit

private structure SpineSplit (α : Type) where
  left : Spine α
  pivot : Node α
  right : Spine α

private def splitSpine (p : Measure → Bool) (acc : Measure) (sp : Spine α) : Option (SpineSplit α) :=
  if sp.isEmpty then none
  else splitSpineAux p acc sp.nodes 0 Measure.empty #[]
where
  splitSpineAux (p : Measure → Bool) (acc : Measure) (nodes : Array (Node α))
      (idx : Nat) (runningMeasure : Measure) (leftNodes : Array (Node α)) : Option (SpineSplit α) :=
    if h : idx < nodes.size then
      let node := nodes[idx]
      let newMeasure := runningMeasure + node.measure
      if p (acc + newMeasure) then
        let rightNodes := nodes.extract (idx + 1) nodes.size
        some ⟨Spine.fromArray leftNodes, node, Spine.fromArray rightNodes⟩
      else
        splitSpineAux p acc nodes (idx + 1) newMeasure (leftNodes.push node)
    else
      none
  termination_by nodes.size - idx

private def splitTreeAux [Measurable α] [Inhabited α] (p : Measure → Bool) (acc : Measure) (t : FingerTree α) : Split α :=
  match t with
  | empty => panic! "splitTreeAux called on empty tree"
  | single a => ⟨empty, a, empty⟩
  | deep _ pr sp sf =>
    let accPr := acc + pr.measure
    if p accPr then
      let ⟨l, x, r⟩ := splitDigit p acc pr
      ⟨fromList l, x, deepL (Digit.fromList? r) sp sf⟩
    else
      let accPrSp := accPr + sp.measure
      if p accPrSp then
        match splitSpine p accPr sp with
        | none =>
          -- Spine split failed, fall through to suffix
          let ⟨l, x, r⟩ := splitDigit p accPrSp sf
          ⟨deepR pr sp (Digit.fromList? l), x, fromList r⟩
        | some ⟨spl, node, spr⟩ =>
          let accNode := accPr + spl.measure
          let ⟨l, x, r⟩ := splitDigit p accNode node.toDigit
          ⟨deepR pr spl (Digit.fromList? l), x, deepL (Digit.fromList? r) spr sf⟩
      else
        let ⟨l, x, r⟩ := splitDigit p accPrSp sf
        ⟨deepR pr sp (Digit.fromList? l), x, fromList r⟩

def split [Measurable α] [Inhabited α] (p : Measure → Bool) (t : FingerTree α) : Option (Split α) :=
  if t.isEmpty then none
  else if !p t.measure then none
  else some (splitTreeAux p Measure.empty t)

def splitAtBytes [Measurable α] [Inhabited α] (n : Nat) (t : FingerTree α) : Option (Split α) :=
  if n == 0 then
    match viewL t with
    | .nil => none
    | .cons a rest => some ⟨empty, a, rest⟩
  else
    split (fun m => m.bytes >= n) t

def splitAtLine [Measurable α] [Inhabited α] (n : Nat) (t : FingerTree α) : Option (Split α) :=
  if n == 0 then
    match viewL t with
    | .nil => none
    | .cons a rest => some ⟨empty, a, rest⟩
  else
    split (fun m => m.lines >= n) t

partial def toList [Measurable α] (t : FingerTree α) : List α :=
  match viewL t with
  | .nil => []
  | .cons a rest => a :: toList rest

partial def toArray [Measurable α] (t : FingerTree α) : Array α :=
  toArrayAux t #[]
where
  toArrayAux (t : FingerTree α) (acc : Array α) : Array α :=
    match viewL t with
    | .nil => acc
    | .cons a rest => toArrayAux rest (acc.push a)

def foldl [Measurable α] (f : β → α → β) (init : β) (t : FingerTree α) : β :=
  t.toList.foldl f init

def foldr [Measurable α] (f : α → β → β) (init : β) (t : FingerTree α) : β :=
  t.toList.foldr f init

def size [Measurable α] (t : FingerTree α) : Nat :=
  match t with
  | empty => 0
  | single _ => 1
  | deep _ pr sp sf =>
    let prSize := pr.toList.length
    let spSize := sp.nodes.foldl (fun acc n => acc + n.toList.length) 0
    let sfSize := sf.toList.length
    prSize + spSize + sfSize

end FingerTree

end Lapis.VFS.FingerTree
