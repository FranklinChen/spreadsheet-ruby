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
    #   a <- (return 1) & new_cell
    #   b <- (return 2) & new_cell
    #   c <- (do
    #           aValue <- a & exp
    #           bValue <- b & exp
    #           return (aValue + bValue)
    #        ) & new_cell
    #   return (a, b, c)
    exp_of_three_cells = Exp.return(1).new_cell >= ->(a) {
      Exp.return(2).new_cell >= ->(b) {
        (
          a.exp >= ->(aValue) {
            b.exp >= ->(bValue) {
              Exp.return(aValue + bValue)
            }
          }
        ).new_cell >= ->(c) {
          Exp.return([a, b, c])
        }
      }
    }

    a, b, c = exp_of_three_cells.run

    expect(c.exp.run).to eq(3)

    a.exp = Exp.return(100)
    expect(c.exp.run).to eq(102)

    a.exp = b.exp >= ->(bValue) {
      Exp.return(bValue * bValue)
    }
    b.exp = Exp.return(4)

    expect(c.exp.run).to eq(20)
  end

  it 'updates a cell value based on cells of other types' do
    exp_of_three_cells = Exp.return("hello").new_cell >= ->(a) {
      Exp.return(2).new_cell >= ->(b) {
        (
          a.exp >= ->(aValue) {
            b.exp >= ->(bValue) {
              Exp.return(aValue.length + bValue)
            }
          }
        ).new_cell >= ->(c) {
          Exp.return([a, b, c])
        }
      }
    }

    a, b, c = exp_of_three_cells.run

    expect(c.exp.run).to eq(7)

    b.exp = Exp.return(3)
    a.exp = Exp.return("no")
    expect(c.exp.run).to eq(5)
  end

end
