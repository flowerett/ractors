class GenServer
  def self.start_link(state)
    r = Ractor.new(state) do |state|
      GenServer.receive(state)
    end
    [:ok, r]
  end

  def self.cast(ractor, msg)
    ractor.send(['$gen_cast', msg])
    :noreply
  end

  def self.call(ractor, msg)
    ractor.send(['$gen_call', Ractor.current, msg])
    case Ractor.receive
      in [:ok, res]
        res
    end
  end

  def self.receive(state)
    case Ractor.receive
      in ['$gen_cast', msg]
        case state.handle_cast(msg)
          in [:noreply, state]
            GenServer.receive(state)
        end
      in ['$gen_call', from, msg]
        case state.handle_call(msg, from)
          in [:reply, reply, state]
            from.send([:ok, reply])
            GenServer.receive(state)
        end
    end
  end
end