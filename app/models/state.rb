class State < ApplicationRecord
  belongs_to :country
  has_many :cities

  validates :name, presence: true

  scope :state_name, -> (name) { where('states.name ilike ?', "%#{name}%") }
  scope :country, -> (country_id) do
    joins(:country).where('countries.id = ?', country_id).order('states.name ASC')
  end
end
