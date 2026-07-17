class Room < ApplicationRecord
  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :available, inclusion: { in: [ true, false ] }

  scope :available, -> { where(available: true) }
  scope :with_min_capacity, ->(min) { where("capacity >= ?", min) }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{sanitize_sql_like(query)}%") }

  # Composes the filtering scopes based on the params that are actually present (ADR-010).
  # Named filter_by (not filter) to avoid colliding with Enumerable#filter on relations.
  def self.filter_by(params = {})
    scope = all
    scope = scope.available if ActiveModel::Type::Boolean.new.cast(params[:available])
    scope = scope.with_min_capacity(params[:min_capacity]) if params[:min_capacity].present?
    scope = scope.search_by_name(params[:name]) if params[:name].present?
    scope
  end

  private

  def normalize_name
    self.name = name.to_s.strip
  end
end
