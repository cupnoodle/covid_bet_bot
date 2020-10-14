# frozen_string_literal: true

# vote model
class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :poll
end