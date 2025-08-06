class Proposal < ApplicationRecord
  belongs_to :user
  before_save :create_title_if_absent

  validates :addresse, presence: true
  validates :body, presence: true

  private

  def create_title_if_absent
    self.title = "Proposal Created For #{addresse} on #{Date.today}" if title.blank?
  end
end
