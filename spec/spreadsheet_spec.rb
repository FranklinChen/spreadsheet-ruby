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
    #   c <- (do
    #           aValue <- a & exp
    #           bValue <- b & exp
    #           return (aValue + bValue)
    #        ) & cell_exp
    #   return (a, b, c)
    exp_of_three_cells = Exp.create(1).cell_exp >= ->(a) {
      Exp.create(2).cell_exp >= ->(b) {
        (
          a.exp >= ->(aValue) {
            b.exp >= ->(bValue) {
              Exp.create(aValue + bValue)
            }
          }
        ).cell_exp >= ->(c) {
          Exp.create([a, b, c])
        }
      }
    }

    a, b, c = exp_of_three_cells.run

    expect(c.exp.run).to eq(3)

    a.exp = Exp.create(100)
    expect(c.exp.run).to eq(102)

    a.exp = b.exp >= ->(bValue) {
      Exp.create(bValue * bValue)
    }
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
