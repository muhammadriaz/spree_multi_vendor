module Spree
  class Vendor < Spree::Base
    extend FriendlyId
    # searchkick locations: [:location]

    #def search_data
    #  attributes.merge(location: {lat: lat, lon: lng})
    #end

    acts_as_paranoid
    acts_as_list column: :priority
    friendly_id :name, use: %i[slugged history]

    validates :name,
      presence: true,
      uniqueness: { case_sensitive: false }

    validates :slug, uniqueness: true
    if Spree.version.to_f >= 3.6
      validates_associated :image
      validates_associated :bg_image
    end

    validates :notification_email, email: true, allow_blank: true

    delegate :name, to: :product, prefix: true

    with_options dependent: :destroy do
      if Spree.version.to_f >= 3.6
        has_one :image, as: :viewable, dependent: :destroy, class_name: 'Spree::VendorImage'
        has_one :bg_image, as: :viewable, dependent: :destroy, class_name: 'Spree::VendorBackgroundImage'
      end

      has_many :commissions, class_name: 'Spree::OrderCommission'
      has_many :option_types
      has_many :products
      has_many :properties
      has_many :shipping_methods
      has_many :stock_locations
      has_many :variants
      has_many :vendor_users
    end

    has_many :users, through: :vendor_users

    after_create :create_stock_location
    after_update :update_stock_location_names

    state_machine :state, initial: :pending do
      event :activate do
        transition to: :active
      end

      event :block do
        transition to: :blocked
      end
    end

    scope :active, -> { where(state: 'active') }

    scope :within, -> (latitude, longitude, distance_in_km = 1) {
      where(%{
       ST_Distance(geo_coordinates, 'POINT(%f %f)') < %d
      } % [longitude, latitude, distance_in_km * 1000]) # approx
    }

    self.whitelisted_ransackable_attributes = %w[name state]

    def update_notification_email(email)
      update(notification_email: email)
    end

    private

    def create_stock_location
      stock_locations.where(name: name, country: Spree::Country.default).first_or_create!
    end

    def should_generate_new_friendly_id?
      slug.blank? || name_changed?
    end

    def update_stock_location_names
      if (Spree.version.to_f < 3.5 && self.name_changed?) || (Spree.version.to_f >= 3.5 && saved_changes&.include?(:name))
        stock_locations.update_all({ name: name })
      end
    end
  end
end
