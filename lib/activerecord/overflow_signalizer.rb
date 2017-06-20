require 'activerecord/overflow_signalizer/version'
require 'active_record'

module ActiveRecord
  class OverflowSignalizer
    class Overflow < StandardError; end

    class UnsupportedType < StandardError
      attr_reader :type

      def initialize(type = nil)
        @type = type
      end
    end

    DAY = 24 * 60 * 60
    DEFAULT_AVG = 100_000

    MAX_VALUE = {
      'integer' => 2_147_483_647,
      'bigint' => 9_223_372_036_854_775_807
    }.freeze

    def initialize(logger: nil, models: nil, days_count: 60, signalizer: nil)
      @logger = logger || ActiveRecord::Base.logger
      @models = models || ActiveRecord::Base.descendants
      @days_count = days_count
      @signalizer = signalizer
    end

    def analyse!
      @models.group_by(&:table_name).each do |table, models|
        model = models.first
        next if model.abstract_class? || model.last.nil?
        pk = model.columns.select { |c| c.name == model.primary_key }.first
        max = MAX_VALUE.fetch(pk.sql_type) { |type| raise UnsupportedType, type }
        if overflow_soon?(max, model)
          raise Overflow, overflow_message(table, model.last.public_send(pk.name), max)
        end
      end
    end

    def analyse
      analyse!
    rescue Overflow => e
      signalize(e.message)
    end

    private

    def overflow_soon?(max, model)
      if model.columns.select { |c| c.name == 'created_at' }.empty?
        (max - model.last.id) / DEFAULT_AVG <= @days_count
      else
        (max - model.last.id) / avg(model) <= @days_count
      end
    end

    def avg(model)
      now = model.last.created_at
      week_records = (1..7).map do |t|
        from = now - DAY * t
        to = from + DAY
        model.where(created_at: from..to).count
      end
      week_records.reduce(:+) / week_records.keep_if { |v| v > 0 }.size
    end

    def overflow_message(table, current_value, max_value)
      if current_value == max_value
        "Primary key in table #{table} overflowed! #{current_value} from #{max_value}"
      else
        "Primary key in table #{table} will overflow soon! #{current_value} from #{max_value}"
      end
    end

    def signalize(msg)
      if @logger && @logger.respond_to?(:warn)
        @logger.warn(msg)
      end
      if @signalizer && @signalizer.respond_to?(:signalize)
        @signalizer.signalize(msg)
      end
    end
  end
end
