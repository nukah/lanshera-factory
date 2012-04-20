module Resque
  module Plugins
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
      def constantize(camel_cased_word)
        camel_cased_word = camel_cased_word.to_s

        if camel_cased_word.include?('-')
          camel_cased_word = classify(camel_cased_word)
        end

        names = camel_cased_word.split('::')
        # names.shift if names.empty? || names.first.empty?
  
        until names.last? || names.empty?
          names.shift
        end
        
        klass = Class.const_get(names) if Class.const_defined?(names)
        klass
       end
    end
  end
end