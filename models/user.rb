# frozen_string_literal: true

# user model
class User < ActiveRecord::Base
  has_many :votes
end