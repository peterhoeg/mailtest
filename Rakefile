require 'bundler/gem_tasks'
require 'rake/testtask'

DIRS = %w[lib test].freeze

Rake::TestTask.new(:test) do |t|
  t.libs = DIRS
  t.test_files = FileList['test/**/*_test.rb']
end

Rake::TestTask.new(:bench) do |t|
  t.libs = DIRS
  t.test_files = FileList['test/**/*_benchmark.rb']
end

task default: :test
