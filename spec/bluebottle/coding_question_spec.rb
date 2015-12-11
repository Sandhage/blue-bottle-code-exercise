require 'bluebottle'
require 'bluebottle/coding_question'

describe BlueBottle::CodingQuestion do
  let(:sally) { BlueBottle::Models::Customer.new(1, 'Sally', 'Fields', 'sally@movies.com') }
  let(:jack) { BlueBottle::Models::Customer.new(2, 'Jack', 'Nickleson', 'jack@movies.com') }
  let(:liv) { BlueBottle::Models::Customer.new(3, 'Liv', 'Tyler', 'liv@movies.com') }
  let(:elijah) { BlueBottle::Models::Customer.new(4, 'Elijah', 'Wood', 'elijah@movies.com') }

  let(:bella_donovan) { BlueBottle::Models::Coffee.new(1, 'Bella Donovan', 'blend') }
  let(:giant_steps) { BlueBottle::Models::Coffee.new(2, 'Giant Steps', 'blend') }
  let(:hayes_valley_espresso) { BlueBottle::Models::Coffee.new(3, 'Hayes Valley Espresso', 'blend') }

  let(:store) { BlueBottle::DataStore.new }
  let(:subscription_service) { BlueBottle::Services::SubscriptionService.new(store) }

  # Test one
  let(:sally_bella_donovan_subscription) { BlueBottle::Models::Subscription.new(1, nil, nil, 'inactive') }

  # Test two
  let(:liv_hayes_valley_espresso_subscription) { BlueBottle::Models::Subscription.new(2, nil, nil, 'inactive') }
  let(:elijah_hayes_valley_espresso_subscription) { BlueBottle::Models::Subscription.new(3, nil, nil, 'inactive') }
  
  # Test three
  let(:liv_bella_donovan_subscription) { BlueBottle::Models::Subscription.new(4, nil, nil, 'inactive') }
  
  # Test four
  let(:jack_bella_donovan_subscription) { BlueBottle::Models::Subscription.new(5, nil, nil, 'inactive') }
  let(:jack_2_bella_donovan_subscription) { BlueBottle::Models::Subscription.new(6, nil, nil, 'inactive') }
  
  before do
    store.add_customer(sally)
    store.add_customer(jack)
    store.add_customer(liv)
    store.add_customer(elijah)

    store.add_coffee(bella_donovan)
    store.add_coffee(giant_steps)
    store.add_coffee(hayes_valley_espresso)
  end

  context 'Sally subscribes to Bella Donovan,' do
    before do
      sally_bella_donovan_subscription.customer_id = sally.id
      sally_bella_donovan_subscription.coffee_id   = bella_donovan.id
      sally_bella_donovan_subscription.status      = 'active'
    end

    it 'Sally should have one active subscription' do
      expect( BlueBottle::Models::Subscription.count_active_subscriptions_by_customer_id(sally.id) ).to eql(1)
    end

    it 'Bella Donovan should have one customer subscribed to it' do
      expect( BlueBottle::Models::Subscription.count_subscriptions_by_coffee_id(bella_donovan.id) ).to eql(1)
    end
  end

  context 'Liv and Elijah subscribe to Hayes Valley Espresso,' do
    before do
      liv_hayes_valley_espresso_subscription.customer_id = liv.id
      liv_hayes_valley_espresso_subscription.coffee_id   = hayes_valley_espresso.id
      liv_hayes_valley_espresso_subscription.status      = 'active'
      
      elijah_hayes_valley_espresso_subscription.customer_id = elijah.id
      elijah_hayes_valley_espresso_subscription.coffee_id   = hayes_valley_espresso.id
      elijah_hayes_valley_espresso_subscription.status      = 'active'
    end

    it 'Liv should have one active subscription' do
      expect( BlueBottle::Models::Subscription.count_active_subscriptions_by_customer_id(liv.id) ).to eql(1)
    end

    it 'Elijah should have one active subscription' do
      expect( BlueBottle::Models::Subscription.count_active_subscriptions_by_customer_id(elijah.id) ).to eql(1)
    end

    it 'Hayes Valley Espresso should have two customers subscribed to it' do
      expect( BlueBottle::Models::Subscription.count_subscriptions_by_coffee_id(hayes_valley_espresso.id) ).to eql(2)
    end
  end

  context 'Pausing:' do
    context 'when Liv pauses her subscription to Bella Donovan,' do
      before do
        liv_bella_donovan_subscription.customer_id = liv.id
        liv_bella_donovan_subscription.coffee_id   = bella_donovan.id
        liv_bella_donovan_subscription.status      = 'active'
        liv_bella_donovan_subscription.status      = 'paused'
      end

      it 'Liv should have zero active subscriptions' do
        expect( BlueBottle::Models::Subscription.count_active_subscriptions_by_customer_id(liv.id) ).to eql(0)
      end

      it 'Liv should have a paused subscription' do
        expect( BlueBottle::Models::Subscription.count_paused_subscriptions_by_customer_id(liv.id) ).to eql(1)
      end

      it 'Bella Donovan should have one customers subscribed to it' do
        expect( BlueBottle::Models::Subscription.count_subscriptions_by_coffee_id(bella_donovan.id) ).to eql(1)
      end
    end
  end

  context 'Cancelling:' do
    context 'when Jack cancels his subscription to Bella Donovan,' do
      before do
        jack_bella_donovan_subscription.customer_id = jack.id
        jack_bella_donovan_subscription.coffee_id   = bella_donovan.id
        jack_bella_donovan_subscription.status      = 'active'
        jack_bella_donovan_subscription.status      = 'cancelled'
      end

      it 'Jack should have zero active subscriptions' do
        expect( BlueBottle::Models::Subscription.count_active_subscriptions_by_customer_id(jack.id) ).to eql(0)
      end

      it 'Bella Donovan should have zero active customers subscribed to it' do
        expect( BlueBottle::Models::Subscription.count_subscriptions_by_coffee_id(bella_donovan.id) ).to eql(0)
      end

      context 'when Jack resubscribes to Bella Donovan' do
        before do
          jack_2_bella_donovan_subscription.customer_id = jack.id
          jack_2_bella_donovan_subscription.coffee_id   = bella_donovan.id
          jack_2_bella_donovan_subscription.status      = 'active'
        end

        it 'Bella Donovan has two subscriptions, one active, one cancelled' do
          expect( BlueBottle::Models::Subscription.count_subscriptions_by_coffee_id(bella_donovan.id) ).to eql(1)
          expect( BlueBottle::Models::Subscription.count_cancelled_subscriptions_by_coffee_id(bella_donovan.id) ).to eql(1)
        end

      end
    end
  end

  context 'Cancelling while Paused:' do
    context 'when Jack tries to cancel his paused subscription to Bella Donovan,' do
      before do
        jack_bella_donovan_subscription.customer_id = jack.id
        jack_bella_donovan_subscription.coffee_id   = bella_donovan.id
        jack_bella_donovan_subscription.status      = 'active'
        jack_bella_donovan_subscription.pause_subscription
      end

      it 'Jack raises an exception preventing him from cancelling a paused subscription' do
        expect(jack_bella_donovan_subscription.cancel_subscription).to eql('Exception!')
      end
    end
  end



end
