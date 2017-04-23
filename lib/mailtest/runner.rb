require 'ap'
require 'mail'
require 'progress_bar'
require 'rainbow'
require 'random-word'
require 'yaml'

class Runner
  TOKENS = %w[count index receiver timestamp word].freeze
  TOKENS.each { |t| attr_reader t }

  def initialize(params)
    extract_params!(params)
    @logger = Logger.new(STDOUT)
    @timestamp = Time.now
    @receivers = {}
    begin
      @receivers = YAML.load_file(params['file'].value)
    rescue StandardError => e
      @logger.error e.message
    end
    @count = @receivers.length
    @messages = []
    @word = RandomWord.nouns(not_shorter_than: params['word_length'].value).next
    @bar = ProgressBar.new(@count)

    create_emails!(params)
  end

  def run
    return if @dry_run

    @logger.info "Starting run for '#{@word}"

    errors = []
    success = 0

    @messages.each do |m|
      begin
        m.deliver
        success += 1
      rescue StandardError => e
        r = m.to.join(', ')
        errors << r
        @logger.error Rainbow(e.message).red
      ensure
        @bar.increment!
      end
    end

    show_result!(success, errors)
  end

  def debug
    @messages.each do |m|
      ap m
    end
  end

  private

  def create_emails!(params)
    Mail.defaults do
      delivery_method :smtp,
                      address: params['host'].value,
                      port: params['port'].value
    end

    @receivers.each_with_index do |r, i|
      @index = i + 1
      receiverp = add_domain(r, @domain)
      @receiver = receiverp # we need this for replace_tokens
      subjectp = replace_tokens(params['subject'].value)
      bodyp = replace_tokens(params['body'].value)
      @messages << Mail.new do
        from    params['from'].value
        to      receiverp
        subject subjectp
        body    bodyp
        cc      params['cc'].value
      end
    end
  end

  def color_number(number, color, color_zero = false)
    return number.to_s if number == 0 && !color_zero
    Rainbow(number.to_s).color(color)
  end

  def extract_params!(params)
    %w[dry-run domain host port].each do |a|
      eval "@#{a.tr('-', '_')}=params['#{a}'].value"
    end
  end

  def show_result!(success, errors)
    success_str = color_number(success, :green, true)
    errors_str = color_number(errors.length, :red)

    @logger.info "Finished: [#{success_str}/#{errors_str}/#{@count}]"
    if errors.empty?
      @logger.info Rainbow('Success!').green
    else
      @logger.error Rainbow("Errors: #{errors.join(', ')}").red
    end
  end

  def add_domain(receiver, domain)
    return receiver if receiver =~ /@/
    return [receiver, domain].join('@') unless domain.nil?
    raise ArgumentError, 'You must specify receiver and domain'
  end

  def replace_tokens(str)
    s = str
    TOKENS.each do |t|
      s = s.gsub("@#{t}@", send(t).to_s)
    end
    s
  end
end
