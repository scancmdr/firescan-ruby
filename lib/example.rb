require 'firebind/scan'

class Example
  def update(state)
    case state.current_state
      when :PORT_COMPLETE
        puts "#{state.transport} port #{state.port} #{state.description(state.port_result_code)}"
      when :PORT_START
      when :PORT_TICK
      when :SCAN_START
      when :START_FAILURE
      when :SCAN_COMPLETE
      else
    end
  end
end

scan = Firebind::Scan.new('scanme.firebind.com','1-10',:UDP)
scan.add_observer Example.new
state = scan.scan
