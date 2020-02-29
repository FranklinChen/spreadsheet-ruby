# Spreadsheet simulation in Ruby, translated from OCaml

[![Build Status](https://travis-ci.org/FranklinChen/spreadsheet-ruby.svg)](https://travis-ci.org/FranklinChen/spreadsheet-ruby)

This is a Ruby translation of a highly imperative dataflow system given in ["How to implement a spreadsheet"](http://semantic-domain.blogspot.com/2015/07/how-to-implement-spreadsheet.html).

## Run

```
$ bundle install
$ rake
```

## Compare different implementations

- [OCaml](https://github.com/FranklinChen/spreadsheet-ocaml)
- [Scala](https://github.com/FranklinChen/spreadsheet-scala)
- [Haskell](https://github.com/FranklinChen/spreadsheet-haskell)
- [Ruby](https://github.com/FranklinChen/spreadsheet-ruby)

## Implementation notes

### API

Ruby does not have types or module signatures (interfaces), so there
is no equivalent to the OCaml [explicit module signature](https://github.com/FranklinChen/spreadsheet-ocaml/blob/master/src/Spreadsheet.ml)

```ocaml
module type CELL = sig
  type 'a cell
  type 'a exp

  val return : 'a -> 'a exp
  val (>>=) : 'a exp -> ('a -> 'b exp) -> 'b exp

  val cell : 'a exp -> 'a cell exp

  val get :  'a cell -> 'a exp
  val set : 'a cell -> 'a exp -> unit

  val run : 'a exp -> 'a
end
```

OO-style is used, turning `Cell` and `Exp` into classes with
methods. The public API is:

- `Exp.create` creates an expression from an ordinary value (`return`
  is just too confusing a name).
- `Exp.>=` is the monadic bind operator syntax I chose (we cannot
  overload `>>=` as in OCaml).
- `Exp.cell_exp` creates a cell expression from an expression.
- `Cell.exp` (corresponding to `get`) creates an expression from a cell.
- `Cell.exp=` (corresponding to `set`) is Ruby syntactic sugar for setting a cell to a new expression.
- `Exp.run` runs an expression.

A globally unique dummy `Unevaluated` value is used to simulate the
OCaml `option` type (`nil` is a bad choice because a cell could
legitimately evaluate to `nil`).

### Object identity

Instead of manually creating a unique ID for each cell for comparing
object identity, we just use Ruby's built-in `equal?` method.

### Heterogeneous list

For keeping track of observers and reads, OCaml used an existential
type. There is no such thing in Ruby and we just duck-type instead.
