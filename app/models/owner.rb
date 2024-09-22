class Owner < ApplicationRecord
  has_many :books

  before_save do
    self.name = name.downcase
  end
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  after_find :titleize_name

  private

  def titleize_name
    self.name = name.titleize
  end
end
