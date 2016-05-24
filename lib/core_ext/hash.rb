require 'set'

class Hash
  #
  # symbolize_keys!
  #
  unless instance_methods.include? :symbolize_keys!
    def symbolize_keys!
      changed = false
      keys.each do |k|
        next if k.is_a? Symbol
        self[k.to_sym] = delete(k)
        changed = true
      end
      changed ? self : nil
    end
  end

  #
  # select_keys!
  #
  unless instance_methods.include? :select_keys!
    def select_keys!(other = nil, &block)
      fail ArgumentError, 'Must provide exactly one argument or a block' if other && block_given?
      fail ArgumentError, 'Must provide one argument or a block' unless other || block_given?

      unless block_given?
        # type_assert(other, Array, Hash, Set, Regexp)
        if other.is_a? Regexp
          block = ->(k) { k =~ other }
        else
          block = ->(k) { other.include?(k) }
        end
      end
      self.reject! { |key, _val| !block[key] }
    end
  end

  #
  # reject_keys!
  #
  unless instance_methods.include? :reject_keys!
    def reject_keys!(other, &block)
      fail ArgumentError, 'Must provide exactly one argument or a block' if other && block_given?
      fail ArgumentError, 'Must provide one argument or a block' unless other || block_given?

      unless block_given?
        # type_assert(other, Array, Hash, Set, Regexp)
        if other.is_a? Regexp
          block = ->(k) { k =~ other }
        else
          block = ->(k) { other.include?(k) }
        end
      end
      self.reject! { |key, _val| block[key] }
    end
  end

  #
  # symbolize_keys
  #
  unless instance_methods.include? :symbolize_keys
    def symbolize_keys
      dup.tap(&:symbolize_keys!)
    end
  end

  #
  # select_keys
  #
  unless instance_methods.include? :select_keys
    def select_keys(other = nil, &block)
      fail ArgumentError, 'Must provide exactly one argument or a block' if other && block_given?
      fail ArgumentError, 'Must provide one argument or a block' unless other || block_given?

      dup.tap { |h| h.select_keys!(other, &block) }
    end
  end

  #
  # reject_keys
  #
  unless instance_methods.include? :reject_keys
    def reject_keys(other = nil, &block)
      fail ArgumentError, 'Must provide exactly one argument or a block' if other && block_given?
      fail ArgumentError, 'Must provide one argument or a block' unless other || block_given?

      dup.tap { |h| h.reject_keys!(other, &block) }
    end
  end

  #
  # slice
  #
  unless instance_methods.include? :slice
    def slice(*args)
      dup.tap { |h| h.select_keys!(args) }
    end
  end

  #
  # slice!
  #
  unless instance_methods.include? :slice!
    def slice!(*args)
      select_keys!(args)
    end
  end

  #
  # Aliases
  #
  unless instance_methods.include? :&
    alias_method :&, :select_keys
  end

  unless instance_methods.include? :-
    alias_method :-, :reject_keys
  end
end
