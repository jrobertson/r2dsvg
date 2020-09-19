Gem::Specification.new do |s|
  s.name = 'r2dsvg'
  s.version = '0.5.2'
  s.summary = 'Experimental gem to render SVG within a Ruby2D application.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/r2dsvg.rb','lib/r2dsvg/r2dsvg_module.rb']
  s.add_runtime_dependency('svgle', '~> 0.4', '>=0.4.7')
  s.add_runtime_dependency('onedrb', '~> 0.1', '>=0.1.0')
  s.add_runtime_dependency('ruby2d', '~> 0.9', '>=0.9.4')
  s.add_runtime_dependency('dom_render', '~> 0.4', '>=0.4.1')
  s.signing_key = '../privatekeys/r2dsvg.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/r2dsvg'
end
