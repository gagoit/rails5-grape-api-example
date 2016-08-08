class ApiException < StandardError
  attr_reader :http_status, :error

  def initialize(options)
    super()
    options = options.with_indifferent_access
    @http_status = options[:http_status]

    @error = Error.new(
          code: options[:code],
          message: options[:message],
          debug_info: options[:debug_info]
      )
  end

  class Error
    attr_reader :code, :message, :debug_info

    def initialize(*args)
      options = (args.first || {}).with_indifferent_access
      @code = options[:code]
      @message = options[:message]

      @debug_info = options[:debug_info] || ""
    end
  end
end