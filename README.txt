firescan-ruby
=============

Ruby reference implementation for the Firebind Firescan path scan client This code has been tested to work
with Ruby 1.9.3 and Firebind Reflector 1.0.

Integration
===========

Integrating the Firescan library is straight forward. It uses a single object 'Scan' and a simple callback
mechanism using Ruby's built-in Observer feature. Create a Scan object, pass it your handler (something that
implements the Observer update method) and run the Scan. A handler update method might look like this:

    def update(state)
      case state.current_state
        when :PORT_COMPLETE
          puts "Port #{state.port} #{state.description(state.port_result_code)}"
        when :PORT_START
        when :PORT_TICK
        when :SCAN_START
        when :START_FAILURE
        when :SCAN_COMPLETE
        else
      end
    end


Then create and run a Scan object like this:


    scan = Firebind::Scan.new('scanme.firebind.com','1-10',:UDP)
    scan.add_observer myHandler
    state = scan.scan

See the lib/example.rb script for a simple working example.


