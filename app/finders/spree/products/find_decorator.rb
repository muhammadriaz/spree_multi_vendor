module Spree
  module Products
    class FindDecorator < Spree::Products::Find
      def initialize(scope:, params:, current_currency:)
        super
        @vendor = params.dig(:filter, :vendor)
      end

      def execute
        products = super
        products = by_vendor(products)

        products
      end

      private

      attr_reader :ids, :skus, :price, :currency, :taxons, :name, :options, :option_value_ids, :scope, :sort_by, :deleted, :discontinued, :vendor

      def vendor?
        vendor.present?
      end

      def by_vendor(products)
        return products unless vendor?
        products.where(vendor: vendor)
      end
    end
  end
end
