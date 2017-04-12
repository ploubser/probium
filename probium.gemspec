Gem::Specification.new do |s|
  s.name          = 'probium'
  s.version       = '0.0.1'
  s.date          = Date.today.to_s
  s.summary       = 'CLI policy checking tool'
  s.description   = 'A CLI tool that uses Puppet resources to validate YAML or JSON policies.'
  s.authors       = ['Pieter Loubser']
  s.email         = 'ploubser@gmail.com'

  s.files         = Dir.glob("lib/**/**")
  s.require_paths = ['lib']
  s.executable    = 'probium'

  s.homepage      =
    'https://github.com/ploubser/probium'
  s.license       = 'Apache-2.0'

  s.add_runtime_dependency('rainbow', '~>2.2','>= 2.2.1')
  s.add_runtime_dependency('puppet', '~>4.3','>= 4.3.2')
end
