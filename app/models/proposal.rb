class Proposal < ApplicationRecord
  belongs_to :user
  before_save :create_title_if_absent

  validates :addresse, presence: true
  validates :body, presence: true

  private

  def create_title_if_absent
    title = "Proposal Created For #{addresse} on #{DateTime.now}" unless title.present?
  end
end
