class Message
  attr_reader :type, :content, :header, :allow_close

  def initialize options = {}
    @type = options[:type] || :info
    @content = options[:content] || ''
    @header = options[:header]
    @allow_close = options[:allow_close] != false
  end

  class << self
    def success options
      create_custom :success, options
    end

    def info options
      create_custom :info, options
    end

    def warning options
      create_custom :warning, options
    end

    def danger options
      create_custom :danger, options
    end

    private

    def create_custom type, options
      return Message.new({ type: type }) if options.nil?
      return Message.new({ type: type, content: options }) if options.is_a? String
      options[:type] = type
      return Message.new options
    end

  end

end