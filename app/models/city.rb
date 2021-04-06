class City < ApplicationRecord
  belongs_to :state
  has_many :addresses

  validates :name, presence: true

  scope :city_name, -> (name) do
    joins(state: :country).where(
      'remove_accents(cities.name) ilike remove_accents(?)',
      "%#{name}%"
    ).order(order_by)
  end

  scope :state_name, -> (name) do
    joins(state: :country).where(
      'remove_accents(states.name) ilike remove_accents(?)',
      "%#{name}%"
    ).order(order_by)
  end

  scope :country_name, -> (name) do
    joins(state: :country).where(
      'remove_accents(countries.name) ilike remove_accents(?)',
      "%#{name}%"
    ).order(order_by)
  end

  scope :state, -> (state_id) { joins(:state).where('states.id = ?', state_id).order('cities.name ASC') }
  scope :city_state_name, -> (name) { city_name(name).or(state_name(name)) }
  scope :city_country_name, -> (name) { city_name(name).or(country_name(name)) }
  scope :country_state_name, -> (name) { state_name(name).or(country_name(name)) }
  scope :city_country_state_name, -> (name) { city_name(name).or(state_name(name)).or(country_name(name)) }

  def state_initials
    self.state.initials
  end

  def country
    self.state.country.name
  end

  private
    def self.order_by
      'upper(countries."name"), upper(states."name"), upper(cities."name")'
    end
end
