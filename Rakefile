task :default => :ci

desc "update makefile"
task :makefile do
  sh 'perl Makefile.PL && make'
end

desc "Run all tests"
task :test  => ["strict_check", "test:unit", "test:integration"]

desc "Build dependencies"
task :build_deps => ["strict_check", "makefile"]

desc "Build dependencies, and run tests"
task :ci => ["build_deps", "test"]

namespace :test do
  desc "run unit tests"
  task :unit do
    sh "make test"
  end

  desc "run integration tests"
  task :integration do
    sh "make integration"
  end
end

task :clean do
  rm_rf "blib"
  rm_rf "pm_to_blib"
  rm_f "MYMETA*"
end

task :strict_check do
  Dir.glob(["lib/Net/**/*.pm"]) do |file|
    unless File.read(file) =~ /Moose|strict/
      puts "#{file} is not using Moose or strict"
    end
  end
end

task :package do
  version = File.read('lib/Net/Braintree.pm')[/\$VERSION = '([^']+)'/, 1]
  filename = "Net-Braintree-#{version}"

  sh "git clean -dfx"
  FileUtils.mkdir_p("dist/#{filename}")
  sh "rsync -avz --exclude dist --exclude '.git*' --exclude lib/perl5 * dist/#{filename}"
  Dir.chdir("dist") do
    sh "tar cf #{filename}.tar --exclude='.git*' #{filename}"
    sh "gzip #{filename}.tar"
  end
end
