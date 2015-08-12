require 'spreadsheet'

describe Spreadsheet do
  Exp = Spreadsheet::Exp

  it 'updates a cell value based on two other cells' do
    # Ruby does not have special syntax for monads.
    #
    # Haskell has special syntax, where since it infers the monad,
    # the monad method `return` does not require qualification.
    #
    # exp_of_three_cells = do
    #   a <- (return 1) & cell_exp
    #   b <- (return 2) & cell_exp
    #   let adder_exp = do
    #     aValue <- a & exp
    #     bValue <- b & exp
    #     return (aValue + bValue)
    #   c <- adder_exp & cell_exp
    #   return (a, b, c)
    #
    # Within the Exp monad:
    # - a is a Cell created from Exp initialized with the value 1
    # - b is a Cell created from Exp initialized with the value 2
    # - adder_exp is an Exp that when run,
    #   - binds aValue to an Exp created from Cell a
    #   - binds bValue to an Exp created from Cell b
    #   - returns sum of aValue and bValue
    # - c is a Cell created from adder Exp
    # - finally, create an Exp collecting the three cells
    exp_of_three_cells =
      Exp.create(1).cell_exp >= ->(a) {
      Exp.create(2).cell_exp >= ->(b) {
      adder_exp =
        a.exp >= ->(aValue) {
        b.exp >= ->(bValue) {
        Exp.create(aValue + bValue)
        }}
      adder_exp.cell_exp >= ->(c) {
      Exp.create([a, b, c])
    }}}

    # Run the Exp to create three Cells.
    a, b, c = exp_of_three_cells.run

    # c = a + b, when run,
    #   => 1 + 2
    #   => 3
    expect(c.exp.run).to eq(3)

    # Set a = 100
    # So c = a + b, when run,
    #      => 100 + 2
    #      => 102
    a.exp = Exp.create(100)
    expect(c.exp.run).to eq(102)

    # This is the cool part.
    #
    # Set a = b * b (an unevaluated expression)
    # Set b = 4
    # So c = a + b, when run,
    #      => (b * b) + b
    #      => (4 * 4) + 4
    #      => 16 + 4
    #      => 20
    b_doubler_exp =
      b.exp >= ->(bValue) {
      Exp.create(bValue * bValue)
    }
    a.exp = b_doubler_exp
    b.exp = Exp.create(4)

    expect(c.exp.run).to eq(20)
  end

  it 'updates a cell value based on cells of other types' do
    exp_of_three_cells = Exp.create("hello").cell_exp >= ->(a) {
      Exp.create(2).cell_exp >= ->(b) {
        (
          a.exp >= ->(aValue) {
            b.exp >= ->(bValue) {
              Exp.create(aValue.length + bValue)
            }
          }
        ).cell_exp >= ->(c) {
          Exp.create([a, b, c])
        }
      }
    }

    a, b, c = exp_of_three_cells.run

    expect(c.exp.run).to eq(7)

    b.exp = Exp.create(3)
    a.exp = Exp.create("no")
    expect(c.exp.run).to eq(5)
  end

end
