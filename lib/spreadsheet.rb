require 'spreadsheet/version'

require 'set'

# Spreadsheet
module Spreadsheet
  # Cell[A]
  # We use Ruby's built-in object identity rather than our own ID.
  class Cell
    protected
    attr_reader :observers

    # Use object identity.
    public
    def eql?(other)
      self.equal?(other)
    end

    # Too restrictive.
    #private_class_method :new

    private
    def initialize(code, value, reads, observers)
      @code = code
      @value = value
      @reads = reads
      @observers = observers
    end

    # Convert a Cell into an Expression.
    public
    def exp
      Exp.new -> {
        if @value.equal?(Unevaluated)
          v, ds = @code.force

          @value = v
          @reads = ds

          ds.each { |d| d.observers << self }

          [v, [self].to_set]
        else
          [@value, [self].to_set]
        end
      }
    end

    # Set a Cell to a different expression.
    public
    def exp=(e)
      @code = e
      invalidate
    end

    # Remove o from our set of observers.
    protected
    def remove_observer(o)
      @observers.select! { |observer| observer.equal?(o) }
    end

    # Recursively invalidate all our observers.
    protected
    def invalidate
      os = @observers
      rs = @reads

      @observers = Set.new
      @value = Unevaluated
      @reads = Set.new

      rs.each { |r| r.remove_observer(self) }
      os.each { |o| o.invalidate }
    end
  end

  # Exp[A]
  class Exp
    # Too restrictive.
    #private_class_method :new

    private
    def initialize(thunk)
      @thunk = thunk
    end

    # Not really public!! But Cell.exp needs this and Ruby's access
    # control mechanism is limited.
    public
    def force
      @thunk.call
    end

    # Factory constructor for an Exp.
    public
    def self.create(v)
      Exp.new -> { [v, Set.new] }
    end

    # Haskell uses >>= for monadic bind, but Ruby does not allow
    # using that operator, so we just use something that looks like it
    # instead. There should be no confusion with greater-than-or-equal.
    public
    def >=(f)
      Exp.new -> {
        a, cs = force
        b, ds = f.call(a).force

        [b, cs.union(ds)]
      }
    end

    # Run the expression to give a result.
    public
    def run
      result = force
      result[0]
    end

    # Create a new Expression that creates a new Cell underneath.
    public
    def cell_exp
      Exp.new -> {
        c = Cell.new(self,
                     Unevaluated,
                     Set.new,
                     Set.new)
        [c, Set.new]
      }
    end
  end

  # Dummy object used internally for simulating Option type.
  private
  module Unevaluated
  end
end
