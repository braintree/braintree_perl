task :default => :test

desc "update makefile"
task :makefile do
  sh 'perl Makefile.PL'
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

task :package do
  filename = "Net-Braintree-0.1.1"

  sh "git clean -dfx"
  FileUtils.mkdir_p("dist/#{filename}")
  sh "rsync -avz --exclude dist --exclude '.git*' * dist/#{filename}"
  Dir.chdir("dist") do
    sh "tar cf #{filename}.tar --exclude='.git*' #{filename}"
    sh "gzip #{filename}.tar"
  end
end
