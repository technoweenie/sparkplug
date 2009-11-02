# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sparkplug}
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["rick"]
  s.date = %q{2009-11-01}
  s.email = %q{technoweenie@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "demos/simple/public/temps/portland/2007.csv",
     "demos/simple/sparkplug_demo.rb",
     "demos/simple/views/readme.erb",
     "lib/spark_pr.rb",
     "lib/sparkplug.rb",
     "lib/sparkplug/cachers/abstract.rb",
     "lib/sparkplug/cachers/filesystem.rb",
     "lib/sparkplug/cachers/memory.rb",
     "lib/sparkplug/handlers/abstract_data.rb",
     "lib/sparkplug/handlers/csv_data.rb",
     "lib/sparkplug/handlers/stubbed_data.rb",
     "sparkplug.gemspec",
     "test/sparkplug_test.rb"
  ]
  s.homepage = %q{http://github.com/technoweenie/sparkplug}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Rack module that dynamically generates sparkline graphs from a set of numbers.}
  s.test_files = [
    "test/sparkplug_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
