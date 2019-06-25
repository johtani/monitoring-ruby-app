class Question < ApplicationRecord
  has_many :votes, dependent: :destroy
  validates :author, length: { minimum: 2, message: '何か入力してください' }
  validates :title, length: { minimum: 2, message: '何か入力してください' }
end
