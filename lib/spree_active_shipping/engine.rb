module Spree::ActiveShipping
end
module SpreeActiveShippingExtension
  class Engine < Rails::Engine

    initializer "spree.active_shipping.preferences", :before => :load_config_initializers do |app|
      Spree::ActiveShipping::Config = Spree::ActiveShippingConfiguration.new
    end

    def self.activate
      # Make sure the Calculator::ActiveShipping module is required first.  If not, this causes problems
      # in 1.9.3 in production on Heroku.
      require 'spree/calculator/active_shipping/base'

      Dir.glob(File.join(File.dirname(__FILE__), "../../app/models/spree/calculator/**/base.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      #Only required until following active_shipping commit is merged (add negotiated rates).
      #http://github.com/BDQ/active_shipping/commit/2f2560d53aa7264383e5a35deb7264db60eb405a
      ActiveMerchant::Shipping::UPS.send(:include, Spree::ActiveShipping::UpsOverride)
    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.to_prepare &method(:activate).to_proc

    initializer "spree_active_shipping.register.calculators" do |app|
      # Make sure the Calculator::ActiveShipping module is required first.  If not, this causes problems
      # in 1.9.3 in production on Heroku.
      require 'spree/calculator/active_shipping/base'

      Dir.glob(File.join(File.dirname(__FILE__), "../../app/models/spree/calculator/**/*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      app.config.spree.calculators.shipping_methods.concat(
        Spree::Calculator::Fedex::Base.descendants +
        Spree::Calculator::Ups::Base.descendants +
        Spree::Calculator::Usps::Base.descendants
      )
    end
  end

end
