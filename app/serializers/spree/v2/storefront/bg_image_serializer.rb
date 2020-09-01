module Spree
module V2
  module Storefront
    class BgImageSerializer < BaseSerializer
      set_type :bg_image

      attributes :viewable_type, :viewable_id, :styles
    end
  end
end
end
