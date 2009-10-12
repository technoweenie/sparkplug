# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-sparklines}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["rick"]
  s.date = %q{2009-10-11}
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
     "demo/public/temps/portland/2007.csv",
     "demo/sparkline_demo.rb",
     "demo/views/readme.erb",
     "lib/rack-sparklines.rb",
     "lib/rack-sparklines/cachers/abstract.rb",
     "lib/rack-sparklines/cachers/filesystem.rb",
     "lib/rack-sparklines/cachers/memory.rb",
     "lib/rack-sparklines/handlers/abstract_data.rb",
     "lib/rack-sparklines/handlers/csv_data.rb",
     "lib/rack-sparklines/handlers/stubbed_data.rb",
     "lib/spark_pr.rb",
     "rack-sparklines.gemspec",
     "test/rack-sparklines_test.rb"
  ]
  s.homepage = %q{http://github.com/technoweenie/rack-sparklines}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Rack module that dynamically generates sparkline graphs from a set of numbers.}
  s.test_files = [
    "test/rack-sparklines_test.rb"
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
