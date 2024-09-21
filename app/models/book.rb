class Book < ApplicationRecord
  belongs_to :owner
  belongs_to :author
end
