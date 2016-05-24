class OpenGov::Util::ThreadPool
  class << self
    attr_accessor :concurrency_limit
  end

  # Default Value
  @concurrency_limit = Float::INFINITY.to_f

  def self.parallel(items, opts = {})
    fail 'No block provided' unless block_given?
    opts = {
      timeout: 5,
      concurrency_limit: @concurrency_limit,
      return_key: :id.to_proc
    }.merge(opts)

    thread_returns = {}
    pool = new(opts[:concurrency_limit])
    items.each do |item|
      pool.push do
        return_key = opts[:return_key].call(item)
        begin
          Timeout.timeout(opts[:timeout]) do
            thread_returns[return_key] = yield(item)
          end
        rescue Timeout::Error => e
          thread_returns[return_key] = e
        end
      end
    end
    pool.join
    thread_returns
  end

  def initialize(concurrency_limit = nil)
    @pool = []
    @limit = concurrency_limit || self.class.concurrency_limit
  end

  def push(*args, &block)
    fail 'No block provided' unless block_given?
    if @limit == 1
      yield(*args)
    else
      @pool << Thread.new(*args, &block)
      join if @pool.size >= @limit
    end
  end

  def each(&block)
    @pool.each(&block)
  end

  def join
    @pool.each(&:join)
    @pool.clear
  end
end
