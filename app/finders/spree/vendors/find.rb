module Spree
  module Vendors
    class Find
      def initialize(scope:, params:)
        @scope = scope

        @ids  = String(params.dig(:filter, :ids)).split(',')
        @name = params[:name]
        @lat = params.dig(:filter, :lat)
        @lon = params.dig(:filter, :lng)
      end

      def execute
        where = by_ids(scope)
        where = by_name(where)
        where = by_location(where)

        where
      end

      private

      attr_reader :ids, :name, :scope, :lat, :lon
      attr_accessor :where

      def ids?
        ids.present?
      end

      def name?
        name.present?
      end

      def location?
        lat.present? && lon.present?
      end

      def name_matcher
        Spree::Vendor.arel_table[:name].matches("%#{name}%")
      end

      def by_ids(where)
        return where unless ids?
        where[:id] = ids
        where
      end

      def by_name(where)
        return where unless name?
        where[:name] = name
        where
      end

      def by_location(where)
        return where unless location?

          where.within lat.to_f, lon.to_f, 2
          where
      end

    end
  end
end
