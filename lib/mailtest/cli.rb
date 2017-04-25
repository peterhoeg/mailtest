$stdout.sync = true
$stderr.sync = true

require 'main'
require 'mailtest'

Main do
  argument('receiver') do
    required
    description 'An email address or the file with the list of receivers'
  end

  argument('from') do
    required
    description 'The sender of the email'
  end

  option('body') do
    argument :required
    default <<-EOF
This is an email test. You can safely ignore this message.

This word does not mean anything: @word@
    EOF
    description 'The body of the message'
  end

  option('subject') do
    argument :required
    default '[@index@/@count@]: @word@ test for @receiver@, @timestamp@'
    description 'The subject of the message'
  end

  option('cc') do
    argument :required
    cast :list_of_string
    description 'A comma separated list of addresses to keep in CC'
  end

  option('bcc') do
    argument :required
    cast :list_of_string
    description 'A comma separated list of addresses to keep in BCC'
  end

  option('domain') do
    argument :required
    description 'The domain to add to or replace in the receiver list'
  end

  option('host') do
    argument :required
    default 'localhost'
    description 'The mail hosts through which we send'
  end

  option('port') do
    argument :required
    cast :int
    default 25
    description 'The mail host port through which we send'
  end

  option('word_length') do
    argument :required
    cast :int
    default 20
    description 'Minimum length of the random word used'
  end

  option('debug') do
    cast :bool
    description 'Enter debugging mode'
  end

  option('dry-run') do
    cast :bool
    description 'Do we actually send the messages'
  end

  def run
    runner = Runner.new(params)
    runner.run
    exit_success!
  end
end
