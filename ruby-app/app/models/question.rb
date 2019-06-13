class Question < ApplicationRecord
  has_many :votes, dependent: :destroy
end
