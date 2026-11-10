# Arithmetic state and ownership

This map describes psh's Zsh 5.9.2 evaluator in `Src/math.c`. It records existing
behavior; it does not promise independent parser instances or thread safety.

## Three different boundaries

| State | Lifetime and restoration rule |
| --- | --- |
| `ptr`, `yyval`, `yylval` | Current lexer position and token payload; saved/restored by nested `mathevall()` |
| `sp`, `stack` | Current operand-stack index and borrowed pointer to that invocation's C-frame array; saved/restored by nested `mathevall()` |
| `prec` | Selected precedence table; saved/restored across nested calls, even when an inner callback uses another option setting |
| `lastbase` | Reset to -1 on evaluation entry, restored on nested exit; outermost evaluation leaves it available to parameter conversion |
| `noeval`, `unary` | Parse-only nesting and operator/operand expectation; saved/restored on nested exit; entry resets `unary` but inherits `noeval` |
| `mtok` | Current token; restored by `matheval()`/`mathevalarg()`, not by `mathevall()`; function-argument parsing needs the terminating comma token |
| `lastmathval` | Last computed result; deliberately published across levels and used by user-defined arithmetic functions |
| `outputradix`, `outputunderscore` | Shared formatting result; reset by outermost `matheval()` and retained across nested evaluation |
| `mlevel` | Recursion counter, checked before increment; a rejected over-limit call does not increment/decrement it |
| `errflag`, options, locale, parameters | Shell state with its existing owners; not private parser state and not restored wholesale by an arithmetic frame |
| `math_c_locale` | Immutable conversion locale retained for process lifetime, when that API is configured |

`MATH_EVAL_SAVE_FIELDS` pairs only the nine fields already restored by nested
`mathevall()`. The same private list emits both assignment sequences, so adding
a save without its matching restore requires changing that mechanism explicitly.
Active globals and flat C-frame locals retain their identities, types and access
paths. There is no runtime context object or context-pointer lookup in the lexer
or operator loop. Save, initialization and restore statements retain their
original order. Outermost calls keep the old explicit initialization of the
otherwise unused save slots. The helper macros are undefined after this routine.

Error exits require the same care as successful evaluation. The recursion-limit
path returns integer zero and reports the original input endpoint before any
new frame is entered; that early return does not publish a new `lastmathval`.
Ordinary parse errors still pass through the existing
result/restoration tail. The final `getmathparam()` may itself recurse before
restoration; moving the restore earlier would invalidate its evaluation state.

## Values and borrowing

Each evaluation has its own fixed C-frame operand array. `push()` initializes a
slot; a parameter reference may carry an unevaluated `lval` until an operator
needs its value. Reading all variables at parse time would change expressions
such as `i + (i=5)` and side-effecting subscripts.

`mathvalue.lval` borrows text whose storage belongs to the surrounding
evaluation/heap. `getmathparam()` obtains its cached `Value` descriptor through
the shell heap allocator. That descriptor references a parameter; it does not
own that parameter. `setmathvar()` rechecks the current parameter identity before
reusing a cached descriptor for assignment. Unset/redeclare and custom callbacks
are therefore lifetime boundaries, not opportunities to retain a raw pointer
indefinitely. This modernization changes none of those allocations or checks.

`callmathfunc()` obtains argument descriptors, argument vectors and list nodes
from the existing shell heap. Arguments are evaluated in sequence through
`mathevall(..., MPREC_ARG, ...)`; native numeric functions, native string functions
and shell-defined math functions use different interfaces. The `mtok` comma
protocol and `lastmathval` result channel connect those interfaces to the parser.

## Constraints on later changes

A future evaluation context must distinguish nested parser state, wrapper-owned
token state, shared result channels and shell-owned state. An execution plan
must preserve lazy reads, callback-driven changes, parse/error ordering,
precedence selection and locale/option behavior. A new ownership scheme must
cover recursive getters, setters, native functions, shell functions and failure
unwinding before changing allocation lifetimes. The paired state list is a
bounded first step, not an implementation of any of those larger designs.
