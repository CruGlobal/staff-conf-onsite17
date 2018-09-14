class UserVariable < ApplicationRecord
  enum value_type: %i[string money date number html]

  validates :code, :short_name, :value_type, :value, presence: true
  validates :code, :short_name, uniqueness: true

  class << self
    def get(short_name)
      @@variables ||= {}
      @@variables[short_name] ||=
        find_by(short_name: short_name)&.value.tap do |val|
          if val.nil?
            raise ArgumentError, format('Unknown UserVariable, %s (expected: %p)',
                                        short_name, keys)
          end
        end
    end
    alias [] get

    def update(short_name, val)
      var = find_by(short_name: short_name)
      raise ArgumentError, "Unknown UserVariable, '#{short_name}'" if var.nil?

      var.value = val
      var.save!
    end
    alias []= update

    def keys
      pluck(:short_name).map(&:to_sym)
    end
  end

  def value
    @raw_value ||= type_send(:load, self[:value])
  end

  def value=(raw_value)
    @raw_value =
      if type_respond_to?(:parse)
        type_send(:parse, raw_value)
      else
        raw_value
      end

    self[:value] =
      type_respond_to?(:dump) ? type_send(:dump, @raw_value) : @raw_value.to_s
  end

  private

  def type_send(prefix, *args)
    send(:"#{prefix}_#{value_type || 'string'}", *args)
  end

  def type_respond_to?(prefix)
    respond_to?(:"#{prefix}_#{value_type || 'string'}", true)
  end

  def load_string(value)
    value
  end

  def load_money(value)
    Money.new(value)
  end

  def parse_money(value)
    if value.is_a?(Money)
      value
    elsif value.is_a?(Numeric)
      load_money(value)
    else
      # Monetize returns $0.00 if value is a bad string
      raise ArgumentError, 'contains no digits' unless value =~ /\d/
      Monetize.parse!(value)
    end
  rescue StandardError => e
    raise ArgumentError,
          format('%p is not a valid amount of money: %p', value, e)
  end

  def dump_money(value)
    value.fractional
  end

  def load_date(value)
    Date.parse(value)
  end

  def parse_date(value)
    if value.is_a?(Date)
      value
    else
      load_date(value)
    end
  rescue StandardError
    raise ArgumentError, "#{value} is not a valid date"
  end

  def load_number(value)
    num = BigDecimal.new(value.to_s)
    num.frac.zero? ? num.to_i : num.to_f
  end

  def parse_number(value)
    if value.is_a?(Numeric)
      value
    else
      Float(value) # for the exception
      load_number(value)
    end
  rescue StandardError
    raise ArgumentError, "#{value} is not a number"
  end

  def load_html(value)
    value
  end
end
