require 'test_helper'

require 'main'

describe 'MailTest' do
  it 'has a version number' do
    value(::Mailtest::VERSION).wont_be_nil
  end
end
