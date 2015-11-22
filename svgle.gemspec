Gem::Specification.new do |s|
  s.name = 'svgle'
  s.version = '0.1.0'
  s.summary = 'svgle'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.signing_key = '../privatekeys/svgle.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/svgle'
end
