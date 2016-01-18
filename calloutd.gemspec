Gem::Specification.new do |s|
  s.name        = 'calloutd'
  s.version     = '0.0.2'
  s.date        = '2016-01-05'
  s.summary     = "Aynchronized call !"
  s.description = "Aynchronized call !"
  s.authors     = ["Ju Weihua (Jackie Ju)"]
  s.email       = 'jackie.ju@gmail.com'
  s.files       = ["lib/calloutd.rb"]
  s.homepage    =
    'http://rubygems.org/gems/calloutd'
  s.license       = 'MIT'
  # add executables
  s.executables << 'calloutd'
  # dependency
  s.add_dependency 'launch_job'
  s.add_dependency 'rubyutility'
  s.add_dependency 'json'
  
end
