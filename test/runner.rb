require_relative '../lib/firebind/client'

class Runner
  client = Firebind::Client.new(ARGV)
  client.run

end
