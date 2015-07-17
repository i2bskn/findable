module Findable
  module Schema
    class Conversion
      class << self
        FALSE_VALUE = ["false", "0"]

        def for(type)
          return types[:default] if type.nil?
          types[type.to_sym] || add_type!(type)
        end

        def types
          @_types ||= {
            default: Proc.new {|value| value }
          }
        end

        def add_type!(type)
          return type if type.is_a?(Proc)
          types[type.to_sym] = method(type).to_proc
        end

        def clear_types
          @_types = nil
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
            else
              value.in?(FALSE_VALUE) ? false : !!value
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
            (Time.zone || Time).parse(value)
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
