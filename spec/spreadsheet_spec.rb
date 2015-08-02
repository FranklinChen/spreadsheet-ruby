require 'spreadsheet'

describe Spreadsheet do
  Exp = Spreadsheet::Exp

  it 'updates a cell value based on two other cells' do
    # Sorry about the horrible syntax.
    # Using monads is painful in Ruby.
    exp_of_three_cells =
      Exp.pure(1).new_cell.and_then(
      lambda do |a|
        Exp.pure(2).new_cell.and_then(
          lambda do |b|
            a.exp.and_then(
              lambda do |aValue|
                b.exp.and_then(
                  lambda do |bValue|
                    Exp.pure(aValue + bValue)
                  end
                )
              end
            ).new_cell.and_then(
              lambda do |c|
                Exp.pure([a, b, c])
              end
            )
          end
        )
      end
    )

    a, b, c = exp_of_three_cells.run

    expect(c.exp.run).to eq(3)

    a.exp = Exp.pure(100)
    expect(c.exp.run).to eq(102)

    a.exp = b.exp.and_then(
      lambda do |bValue|
        Exp.pure(bValue * bValue)
      end
    )
    b.exp = Exp.pure(4)

    expect(c.exp.run).to eq(20)
  end

  it 'updates a cell value based on cells of other types' do
    # Using monads is painful in Ruby.
    exp_of_three_cells =
      Exp.pure("hello").new_cell.and_then(
      lambda do |a|
        Exp.pure(2).new_cell.and_then(
          lambda do |b|
            a.exp.and_then(
              lambda do |aValue|
                b.exp.and_then(
                  lambda do |bValue|
                    Exp.pure(aValue.length + bValue)
                  end
                )
              end
            ).new_cell.and_then(
              lambda do |c|
                Exp.pure([a, b, c])
              end
            )
          end
        )
      end
    )

    a, b, c = exp_of_three_cells.run

    expect(c.exp.run).to eq(7)

    b.exp = Exp.pure(3)
    a.exp = Exp.pure("no")
    expect(c.exp.run).to eq(5)
  end

end
