module Findable
  # Record collection class
  class Collection
    include Enumerable

    attr_reader :model, :records

    def initialize(model, records)
      raise ArgumentError unless records.is_a?(Array)
      @model = model
      @records = records
    end

    delegate :size, :first, :last, to: :records
    delegate :empty?, :blank?, :present?, to: :records
    alias_method :length, :size
    alias_method :count, :size
    alias_method :take, :first
    alias_method :to_a, :records

    def presence
      present? ? self : nil
    end

    def each
      if block_given?
        records.each {|record| yield(record) }
      else
        records.to_enum
      end
    end

    def find(ids)
      if ids.is_a?(Array)
        if refined = records.select {|record| record.id.in?(ids) }
          regenerate(refined)
        else
          raise not_found(id: ids)
        end
      else
        records.detect {|record| record.id == ids } || (raise not_found(id: ids))
      end
    end

    def find_by(conditions)
      records.detect {|record|
        conditions.all? {|k, v| record.public_send(k) == v }
      }
    end

    def find_by!(conditions)
      find_by(conditions.dup) || (raise not_found(conditions))
    end

    def where(conditions)
      regenerate(records.select {|record|
        conditions.all? {|k, v| record.public_send(k) == v }
      })
    end

    def order(*columns)
      columns.flatten!
      raise ArgumentError, "Must contain arguments" if columns.empty?

      regenerate(records.sort_by {|record|
        columns.map {|column| record.public_send(column) }
      })
    end

    def ordered_find(*_ids)
      _ids.flatten!
      records.index_by(&:id).values_at(*_ids)
    end

    def pluck(*columns)
      columns.flatten!
      return records.map {|record| record.attributes.values } if columns.empty?
      single = (columns.size == 1)

      records.map {|record|
        values = columns.map {|column| record.public_send(column) }
        single ? values.first : values
      }
    end

    def inspect
      "[#{records.map(&:inspect).join(",\n")}]"
    end

    private
      def regenerate(records)
        self.class.new(model, records)
      end

      def not_found(params)
        RecordNotFound.new(model, params)
      end
  end
end
