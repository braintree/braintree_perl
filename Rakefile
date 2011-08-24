task :default => :test

desc "update makefile"
task :makefile do
  sh 'perl Makefile.PL && make'
end

task :test => ["makefile", "test:unit", "test:integration"]

namespace :test do
  desc "run unit tests"
  task :unit do
    sh "perl -Mlocal::lib=./"
    sh "eval $(perl -Mlocal::lib=./)"
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
