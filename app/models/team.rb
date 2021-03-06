# frozen_string_literal: true

class Team < ApplicationUidRecord
  acts_as_paranoid without_default_scope: true

  has_and_belongs_to_many :users
  has_many :projects
  has_many :tags

  has_many :events, as: :resource
  attr_accessor :operator
  after_create ->(obj) { trigger_add_event user_id: obj.operator.try(:id).to_i }

  validates_presence_of :name

  def generate_project!(user, opts = {})
    keep_transaction do
      attrs = { team_uid: uid, user_id: user.id, user_uid: user.uid, operator: user }.merge(opts)
      projects.create!(attrs)
    end
  end
end
