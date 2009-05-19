
Gem::Specification.new do |s|
  s.name = 'giic'
  s.version = '0.0.2'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Tomohiro Nishimura']
  s.date = 2009-05-19
  s.email = 'tomohiro68@gmail.com'
  s.files = %w( lib/giic.rb
                bin/giic
                spec/giic_spec.rb spec/spec_helper.rb
                README.rdoc
                Rakefile )
  s.executable = 'giic'
  s.add_dependency('pauldix-typhoeus', '>= 0.0.8')
  s.homepage = 'http://wiki.github.com/Sixeigh/giic'
  s.has_rdoc = true
  s.rdoc_options = ['--main', 'README.rdoc', '--exclude', 'spec']
  s.extra_rdoc_files = ['README.rdoc']
  s.summary = 'A github-issues API interface client.'
  s.description = 'Giic is a client of github-issues API interface'
  s.rubygems_version = '1.3.1'
end

