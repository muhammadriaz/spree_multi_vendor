module Spree
  module Api
    module V2
      module Storefront
        class VendorsController < ::Spree::Api::V2::BaseController
           include Spree::Api::V2::CollectionOptionsHelpers

          def index
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def departments
            taxons = ActiveRecord::Base.connection.execute("
              SELECT taxon_id id FROM spree_taxonomies spt
                    JOIN spree_taxons spta on spt.id = spta.taxonomy_id
                    JOIN spree_products_taxons sppt on sppt.taxon_id = spta.id
                    JOIN spree_products  spp on spp.id = sppt.product_id
                    WHERE spp.vendor_id = #{params[:vendor]}
                    AND spt.name = 'Departments'
                    group by taxon_id;
              ")
               #byebug

              results = []

              taxons = Spree::Taxon.where(id: taxons.values.map { |x| x.first}).page(params.has_key?(:page) ? params[:page] : 1)

               taxons.each do |taxon|
                taxon.self_and_ancestors.each do |t|
                  if t.depth == 1
                    results << {
                        :id => t.id,
                        :name => t.name,
                        :path => api_v2_storefront_products_path({"filter[taxons]" => t.id})
                      }
                  end
                end
              end

              render_serialized_payload {{data: results, meta: {total: taxons.total_pages}}}
          end

          private

          def paginated_collection
            # collection_paginator.new(collection, params).call
            query = scope.search('*', where: collection, execute: false)
            query.execute
            # query.where_filters(_id: 1)
            # query.execute
            # collection_paginator.new(scope.search('*'), params).call
          end

          def collection
            collection_finder.new(scope: scope, params: params).execute
          end

          def resource
            scope.search "*", where: {_id: params[:id]}, load: false
          end

          def collection_finder
            Spree::Vendors::Find
          end

          def collection_serializer
            Spree::V2::Storefront::VendorSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::VendorSerializer
          end

          def scope
            Spree::Vendor.accessible_by(current_ability, :show).includes(scope_includes)
          end

          def scope_includes
            {
              # master: :default_price,
              # variants: [],
              # variant_images: [],
              # taxons: [],
              # product_properties: :property,
              # option_types: :option_values,
              # variants_including_master: %i[default_price option_values]
            }
          end
        end
      end
    end
  end
end
