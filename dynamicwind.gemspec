# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dynamicwind}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yusuke Endoh"]
  s.date = %q{2008-11-21}
  s.description = %q{An implementation of dynamic-wind for ruby's continuation. See R6RS 11.15 Control features for detail. http://www.r6rs.org/final/html/r6rs/r6rs-Z-H-14.html#node_idx_764}
  s.email = ["mame@tsg.ne.jp"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/dynamicwind.rb", "test/test_dynamicwind.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mame/dynamicwind/tree/master}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{dynamicwind}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An implementation of dynamic-wind for ruby's continuation}
  s.test_files = ["test/test_dynamicwind.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
