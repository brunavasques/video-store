require 'video_store_hooks'

module SpreeSite
  class Engine < Rails::Engine
    def self.activate
      Spree::Config.set(:address_requires_state => false)
      Spree::Config.set(:logo => '/images/logo.png')
      Spree::Config.set(:admin_interface_logo => '/images/logo.png') 

      Order.class_eval do
        # customize the checkout state machine
        Order.state_machines[:state] = StateMachine::Machine.new(Order, :initial => 'cart') do
          after_transition :to => 'complete', :do => :finalize!
        
          event :next do
            transition :from => 'cart', :to => 'address'
            transition :from => 'address', :to => 'payment'
            transition :from => 'payment', :to => 'confirm'
            transition :from => 'confirm', :to => 'complete'
          end
        end
      end
    end
    config.to_prepare &method(:activate).to_proc
  end
end
