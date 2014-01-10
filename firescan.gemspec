Gem::Specification.new do |s|

  s.name = 'firescan'
  s.summary = 'Perform network path scanning'
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.txt'))
  s.requirements = 'none'
  s.version = '0.08'
  s.author = 'Jay Houghton'
  s.email = 'jay@firebind.com'
  s.homepage = 'http://www.firebind.com'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9'
  s.files = Dir['**/**']
  s.executables = ['firescan']
  s.test_files = Dir['test/test*.rb']
  s.has_rdoc = false

end
