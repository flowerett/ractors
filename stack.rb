require_relative 'genserver'

class Stack
  def self.start_link(state)
    GenServer.start_link(new(state))
  end

  def initialize(state)
    @state = state
  end

  def self.push(ractor, value)
    GenServer.cast(ractor, [:push, value])
  end

  def self.pop(ractor)
    GenServer.call(ractor, :pop)
  end

  def handle_cast(msg)
    case msg
    in [:push, value]
      push(value)
      [:noreply, self]
    end
  end

  def handle_call(msg, _from)
    case msg
    when :pop
      [:reply, pop(), self]
    end
  end

  def push(value)
    state.unshift(value)
  end

  def pop
    state.shift
  end

  private

  attr_reader :state
end

case Stack.start_link([:world])
  in [:ok, ractor]
    pp Stack.push(ractor, :hello)
    pp Stack.pop(ractor) # => :hello
    pp Stack.pop(ractor) # => :world
end