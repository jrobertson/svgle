Gem::Specification.new do |s|
  s.name = 'svgle'
  s.version = '0.4.0'
  s.summary = 'Svgle (SVG + Domle) generates an SVG Document Object Model from the given SVG. Suitable for accessing, or modifying SVG elements as objects.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/svgle.rb']
  s.add_runtime_dependency('domle', '~> 0.1', '>=0.1.0')
  s.signing_key = '../privatekeys/svgle.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/svgle'
end
