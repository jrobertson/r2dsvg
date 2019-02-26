Gem::Specification.new do |s|
  s.name = 'r2dsvg'
  s.version = '0.3.2'
  s.summary = 'Experimental gem to render SVG within a Ruby2D application.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/r2dsvg.rb']
  s.add_runtime_dependency('svgle', '~> 0.4', '>=0.4.5')
  s.add_runtime_dependency('ruby2d', '~> 0.8', '>=0.8.1')
  s.add_runtime_dependency('dom_render', '~> 0.3', '>=0.3.2')
  s.signing_key = '../privatekeys/r2dsvg.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/r2dsvg'
end
