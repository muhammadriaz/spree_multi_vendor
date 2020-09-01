module Spree
  module V2
    module Storefront
      class VendorProductSerializer < ProductSerializer
        belongs_to :vendor,
        id_method_name: :vendor_id,
        serializer: :vendor
      end
    end
  end
end
