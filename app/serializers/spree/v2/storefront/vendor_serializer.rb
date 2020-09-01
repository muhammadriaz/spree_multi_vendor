module Spree
  module V2
    module Storefront
      class VendorSerializer < BaseSerializer
      set_type :vendor
      attributes :name, :state

       has_one :image
       has_one :bg_image
      end
    end
  end
end
