require 'spreadsheet/version'

# Spreadsheet
module Spreadsheet
  # Cell[A]
  # We use Ruby's built-in object identity rather than our own ID.
  class Cell
    attr_reader :code, :value, :reads, :observers

    # Warning: do not create Cell except through Exp.new_cell!!
    def initialize(code, value, reads, observers)
      @code = code
      @value = value
      @reads = reads
      @observers = observers
    end

    # Convert a Cell into an Expression.
    def exp
      Exp.new -> {
        if @value.equal?(Unevaluated)
          v, ds = @code.call

          @value = v
          @reads = ds

          ds.each { |d| d.observers << self }

          [v, [self]]
        else
          [@value, [self]]
        end
      }
    end

    # Set a Cell to a different expression.
    def exp=(e)
      @code = e
      invalidate
    end

    # Remove o from our set of observers.
    def remove_observer(o)
      @observers.select! { |observer| observer.equal?(o) }
    end

    # Recursively invalidate all our observers.
    def invalidate
      os = @observers
      rs = @reads

      @observers = []
      @value = Unevaluated
      @reads = []

      rs.each { |r| r.remove_observer(self) }
      os.each { |o| o.invalidate }
    end
  end

  # Exp[A]
  class Exp
    # Warning: do not create Exp except through Exp.new_cell!!
    def initialize(thunk)
      @thunk = thunk
    end

    # Warning: only used internally!!
    def call
      @thunk.call
    end

    def self.return(v)
      Exp.new -> { [v, []] }
    end

    # Haskell uses >>= for monadic bind, but Ruby does not allow
    # using that operator, so we just use something that looks like it
    # instead. There should be no confusion with greater-than-or-equal.
    def >=(f)
      Exp.new -> {
        a, cs = @thunk.call
        b, ds = f.call(a).call

        [b, Exp.union(cs, ds)]
      }
    end

    def run
      result = @thunk.call
      result[0]
    end

    # The only public way to create a new Cell.
    def new_cell
      Exp.new -> {
        c = Cell.new(self,
                     Unevaluated,
                     [],
                     [])
        [c, []]
      }
    end

    # Utility function.
    # Use object identity.
    def self.union(xs, ys)
      result = Array.new(xs)

      ys.each do |y|
        result << y unless xs.any? { |x| x.equal?(y) }
      end

      result
    end
  end

  private

  # Dummy object used internally for simulating Option type.
  module Unevaluated
  end
end
