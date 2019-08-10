module TypedModel
  class Errors
    def initialize
      @errors = Hash.new do |h, k|
        h[k] = []
      end
    end

    def add(key, msg)
      @errors[key] << msg
    end

    def merge!(errors, prefix)
      errors.each_error do |k, msg|
        add("#{prefix}/#{k}", msg)
      end
    end

    def each_error(&blk)
      @errors.each do |(k, msgs)|
        msgs.each { |m| blk.call(k, m) }
      end
    end

    def [](k)
      @errors[k]
    end

    def empty?
      @errors.empty?
    end
  end
end

