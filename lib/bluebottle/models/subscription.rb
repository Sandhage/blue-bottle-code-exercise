# implement this
require 'active_support/all'

module BlueBottle
  module Models
    class Subscription
      attr_accessor :id,
                    :customer_id,
                    :coffee_id,
                    :status

      def initialize(id, customer_id, coffee_id, status)
        @id = id
        @customer_id = customer_id
        @coffee_id = coffee_id
        @status = status
      end

      def self.count_active_subscriptions_by_customer_id(customer_id)
          GC.start
          subscriptions = ObjectSpace.each_object(self).to_a
          
          count = 0
          subscriptions.each do |subscription|
            count += 1 if subscription.customer_id == customer_id && subscription.status == 'active'
          end
          
          return count
      end
      
      def self.count_paused_subscriptions_by_customer_id(customer_id)
          GC.start
          subscriptions = ObjectSpace.each_object(self).to_a
          
          count = 0
          subscriptions.each do |subscription|
            count += 1 if subscription.customer_id == customer_id && subscription.status == 'paused'
          end
          
          return count
      end
      
      def self.count_subscriptions_by_coffee_id(coffee_id)
          GC.start
          subscriptions = ObjectSpace.each_object(self).to_a
          
          count = 0
          subscriptions.each do |subscription|
            count += 1 if subscription.coffee_id == coffee_id && ( subscription.status == 'active' || subscription.status == 'paused' )
          end
          
          return count
      end
    end
  end
end
