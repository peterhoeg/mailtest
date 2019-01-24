require 'active_support/hash_with_indifferent_access'
require 'ap'
require 'mail'
require 'progress_bar'
require 'rainbow'
require 'random-word'
require 'yaml'

class Runner
  def initialize(params)
    params = ActiveSupport::HashWithIndifferentAccess.new params
    setup_logger!(params[:debug].value)
    setup_mail!(params)
    setup_receivers!(params)
    setup_tokens!(params)
    @bar = ProgressBar.new(@receivers.count)
    @dry_run = params['dry-run'].value
    @messages = []

    create_emails!(params)
  end

  def run
    errors = []
    success = 0

    @logger.info "Sending '#{@tokens[:word]}' to #{@tokens[:count]} recipient(s)"

    @messages.each_with_index do |m, i|
      receivers = m.to.join(', ')
      @logger.debug "Sending to: #{receivers} #{x_of_y(i)}"
      begin
        m.deliver unless @dry_run
        success += 1
      rescue StandardError => e
        errors << receivers
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

  def setup_logger!(debug)
    @logger = Logger.new(STDOUT)
    @logger.level = debug ? Logger::DEBUG : Logger::INFO
  end

  def setup_mail!(params)
    Mail.defaults do
      delivery_method :smtp,
        address: params[:host].value,
        port: params[:port].value
    end
  end

  def setup_receivers!(params)
    @logger.debug 'Creating receiver list'
    receivers = []
    receiver = params[:receiver].value
    if File.exist?(receiver)
      begin
        receivers = YAML.load_file(receiver)
      rescue StandardError => e
        @logger.error e.message
      end
      @logger.debug "#{receiver} is a file with email addresses"
    elsif receiver =~ /,/
      receivers = receiver.split(',')
      @logger.debug "#{receiver} is a list of email addresses"
    elsif valid_email?(receiver)
      # we expect an array
      receivers << receiver
      @logger.debug "#{receiver} is a valid email address"
    else
      raise "#{receiver} is neither an email address nor a file with addresses"
    end

    @logger.error "Empty receiver list" if receivers.nil? || receivers.empty?

    @receivers = receivers.sort.map do |r|
      add_or_replace_domain(r, params[:domain].value)
    end

    @logger.debug "Receivers: #{@receivers}"
    @count = @receivers.length
  end

  def setup_tokens!(params)
    @logger.debug 'Creating tokens'
    length = params[:word_length].value
    @tokens = ActiveSupport::HashWithIndifferentAccess.new(
      count: @receivers.count,
      index: 0,
      receiver: nil,
      timestamp: Time.now,
      word: RandomWord.nouns(not_shorter_than: length).next
    )
  end

  def create_emails!(params)
    @logger.debug 'Creating mails'
    @receivers.each_with_index do |receiver, i|
      @tokens[:index] = i + 1
      @tokens[:receiver] = receiver
      subjectp = replace_tokens(params[:subject].value)
      bodyp = replace_tokens(params[:body].value)
      @messages << Mail.new do
        from    params[:from].value
        to      receiver
        subject subjectp
        body    bodyp
        cc      params[:cc].value
      end
    end
  end

  def color_number(number, color, color_zero = false)
    return number.to_s if number.zero? && !color_zero
    Rainbow(number.to_s).color(color)
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

  def valid_email?(str)
    !str !~ /@/
  end

  def add_or_replace_domain(receiver, domain)
    if valid_email?(receiver) && domain
      user = receiver.split('@')[0]
      return [user, domain].join('@')
    elsif valid_email?(receiver)
      return receiver
    elsif domain
      return [receiver, domain].join('@')
    end
    @logger.error "Receiver: #{receiver}, domain: #{domain}"
    raise ArgumentError, 'Unable to read/generate email address'
  end

  def replace_tokens(str)
    s = str
    pad = @tokens[:count].to_s.length
    %i[count receiver timestamp word].each do |t|
      s = s.gsub("@#{t}@", @tokens[t].to_s)
    end
    %i[index].each do |t|
      s = s.gsub("@#{t}@", @tokens[t].to_s.rjust(pad, '0'))
    end
    s
  end

  def x_of_y(x)
    "[#{x + 1}/#{@tokens[:count]}]"
  end
end
