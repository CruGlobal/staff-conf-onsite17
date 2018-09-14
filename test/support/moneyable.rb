module Support
  module Moneyable
    extend ActiveSupport::Concern

    included do
      def self.test_money_attr(factory, attr)
        test "#{attr}=" do
          model = instance_variable_get("@#{factory}".to_sym)
          model ||= create(factory)

          model.update(attr => 1)
          assert_equal Money.new(100), model.send(attr)

          model.update(attr => '1')
          assert_equal Money.new(100), model.send(attr)

          model.update(attr => 1.00)
          assert_equal Money.new(100), model.send(attr)

          model.update(attr => '1.00')
          assert_equal Money.new(100), model.send(attr)

          model.update(attr => '$USD 1.00')
          assert_equal Money.new(100), model.send(attr)

          model.update(attr => '$USD 123.45')
          assert_equal Money.new(12345), model.send(attr)

          model.update(attr => '1,234,567.89')
          assert_equal Money.new(123456789), model.send(attr)
        end
      end
    end
  end
end
