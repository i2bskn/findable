module Findable
  module Schema
    class Conversion
      class << self
        FALSE_VALUE = ["false", "0"]

        def for(type)
          return types[:default] if type.nil?
          types[type] || add_type!(type)
        end

        def types
          @_types ||= {
            default: Proc.new {|value| value }
          }
        end

        def add_type!(type)
          return type if type.respond_to?(:call)
          raise ArgumentError unless private_method_defined?(type)
          types[type.to_sym] = method(type)
        end

        private
          # Conversion methods
          def integer(value)
            value.to_i
          end

          def float(value)
            value.to_f
          end

          def decimal(value)
            BigDecimal(value)
          end

          def string(value)
            value.to_s
          end

          def boolean(value)
            if value.is_a?(TrueClass) || value.is_a?(FalseClass)
              value
            elsif value.in?(FALSE_VALUE)
              false
            else
              !!value
            end
          end

          def date(value)
            return value if value.is_a?(Date)
            Date.parse(value)
          end

          def datetime(value)
            if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
              return value
            end
            Time.zone.parse(value)
          end

          def symbol(value)
            value.to_sym
          end

          def inquiry(value)
            value.to_s.inquiry
          end
      end
    end
  end
end
