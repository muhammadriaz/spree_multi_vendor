module Spree
  module Admin
    class VendorsController < ResourceController

      def create
        setGeoCoordinates
        if permitted_resource_params[:image] && Spree.version.to_f >= 3.6
          @vendor.build_image(attachment: permitted_resource_params.delete(:image))
        end

        if permitted_resource_params[:bg_image] && Spree.version.to_f >= 3.6
          @vendor.build_bg_image(attachment: permitted_resource_params.delete(:bg_image))
        end

        super
      end

      def update
        setGeoCoordinates

        if permitted_resource_params[:image] && Spree.version.to_f >= 3.6
          @vendor.create_image(attachment: permitted_resource_params.delete(:image))
        end

        if permitted_resource_params[:bg_image] && Spree.version.to_f >= 3.6
          @vendor.create_bg_image(attachment: permitted_resource_params.delete(:bg_image))
        end

        super
      end

      def update_positions
        params[:positions].each do |id, position|
          vendor = Spree::Vendor.find(id)
          vendor.set_list_position(position)
        end

        respond_to do |format|
          format.js { render plain: 'Ok' }
        end
      end

      private

      def setGeoCoordinates
        params[:vendor][:geo_coordinates] = "POINT(#{params[:vendor][:lng]} #{params[:vendor][:lat]})"
      end

      def find_resource
        Vendor.with_deleted.friendly.find(params[:id])
      end

      def collection
        params[:q] = {} if params[:q].blank?
        vendors = super.order(priority: :asc)
        @search = vendors.ransack(params[:q])

        @collection = @search.result.
                      page(params[:page]).
                      per(params[:per_page])
      end
    end
  end
end
