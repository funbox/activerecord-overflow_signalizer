require 'activerecord/overflow_signalizer/version'
require 'active_record'

module ActiveRecord
  class OverflowSignalizer
    class UnsupportedType < StandardError
      attr_reader :type

      def initialize(type = nil)
        @type = type
      end
    end

    DAY = 24 * 60 * 60

    def initialize(logger: nil, models: nil, days_count: 60, signalizer: nil)
      @logger = logger || ActiveRecord::Base.logger
      @models = models || ActiveRecord::Base.descendants
      @days_count = days_count
      @signalizer = signalizer
    end

    def analyse!
      @models.group_by(&:table_name).each do |table, models|
        model = models.first
        pk = model.columns.select { |c| c.name == model.primary_key }.first
        next if model.last.nil?
        if overflow_soon?(pk, model)
          signalize(table, model.last.public_send(pk.name), max_value(pk.sql_type))
        end
      end
    end

    private

    def overflow_soon?(pk, model)
      (max_value(pk.sql_type) - model.last.id) / avg(model) <= @days_count
    end

    def avg(model)
      yesterday = Time.now
      week_records = (1..7).map do |t|
        from = yesterday - DAY * t
        to = from + DAY
        model.where(created_at: from..to).count
      end
      week_records.reduce(:+) / week_records.keep_if { |v| v > 0 }.size
    end

    def max_value(type)
      case type
      when 'integer'
        2_147_483_647
      when 'bigint'
        9_223_372_036_854_775_807
      else
        raise UnsupportedType, type
      end
    end

    def signalize(table, current_value, max_value)
      if current_value == max_value
        msg = "Primary key in table #{table} overflowed! #{current_value} from #{max_value}"
      else
        msg = "Primary key in table #{table} will overflow soon! #{current_value} from #{max_value}"
      end
      if @logger && @logger.respond_to?(:warn)
        @logger.warn(msg)
      end
      if @signalizer && @signalizer.respond_to?(:signalize)
        @signalizer.signalize(msg)
      end
    end
  end
end
