$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'mailtest'

require 'minitest/autorun'
require 'minitest/benchmark' if ENV['BENCH']
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
