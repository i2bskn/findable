module Findable
  module Associations
    class Utils
      def self.model_for(name, options = {})
        unless model_name = options[:class_name].presence
          name = options[:collection] ? name.to_s.singularize : name.to_s
          model_name = name.camelize
        end

        if options[:safe]
          model_name.try(:safe_constantize)
        else
          model_name.constantize
        end
      end

      def self.parse_args(args)
        copied = args.dup
        options = copied.extract_options!
        [copied.first, options]
      end
    end
  end
end
