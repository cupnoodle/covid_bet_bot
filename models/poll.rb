# frozen_string_literal: true

# poll model
class Poll < ActiveRecord::Base
  has_many :votes
  belongs_to :winner, class_name: "User"
end