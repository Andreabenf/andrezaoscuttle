class Country < ApplicationRecord
  has_many :states

  validates :name, presence: true

  scope :country_name, -> (name) { where('countries.name ilike ?', "%#{name}%") }
end
