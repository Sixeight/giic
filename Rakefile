require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.spec_opts = ['-c']
end

desc 'Run specs(default)'
task :default => :spec

namespace :gem do
  desc 'Generate gemspec'
  task :gemspec do |t|
    require 'lib/giic'
    File.open('giic.gemspec', "wb" ) do |file|
      file << <<-EOS.gsub(/^ {8}/, '')

        Gem::Specification.new do |s|
          s.name = 'giic'
          s.version = '#{Giic::VERSION}'

          s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
          s.authors = ['Tomohiro Nishimura']
          s.date = #{Time.now.strftime('%Y-%m-%d')}
          s.email = 'tomohiro68@gmail.com'
          s.files = %w( #{FileList['lib/**/*.rb'].join(' ')}
                        #{FileList['bin/*'].join(' ')}
                        #{FileList['spec/**/*.rb'].join(' ')}
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
          s.rubygems_version = '#{`gem --version`.chomp}'
        end

      EOS
    end
    puts "Generate gemspec"
  end

  desc 'Build the gem'
  task :build => :gemspec do |t|
    system 'gem', 'build', 'giic.gemspec'
  end
end

