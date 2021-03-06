class Todo < ApplicationUidRecord
  acts_as_paranoid without_default_scope: true

  belongs_to :project
  belongs_to :tag
  has_many :comments
  belongs_to :user
  belongs_to :todolist
  belongs_to :assignee, class_name: 'User', foreign_key: :assignee_id

  has_many :events, as: :resource
  attr_accessor :operator
  after_create lambda { |obj|
    trigger_add_event user_id: obj.operator.try(:id).to_i, project_id: project_id
  }
  after_destroy lambda { |obj|
    trigger_remove_event user_id: obj.operator.try(:id).to_i, project_id: project_id
  }

  enum status: { add: 0, close: 1 }

  def to_reopen!
    keep_transaction do
      add!
      events.reopen.build(user_id: operator.try(:id).to_i, project_id: project_id).save!
    end
  end

  # special action
  def to_close!
    keep_transaction do
      close!
      events.close.build(user_id: operator.try(:id).to_i, project_id: project_id).save!
    end
  end

  def to_assign!(assigner_id, assignee_id)
    keep_transaction do
      update assignee_id: assignee_id
      events.assign.create!(
        user_id: operator.try(:id).to_i, project_id: project_id,
        extras: { assigner_id: assigner_id, assignee_id: assignee_id }.to_json
      )
    end
  end

  def to_move!(direct_todolist_id)
    keep_transaction do
      update todolist_id: direct_todolist_id
      events.move.build(user_id: operator.try(:id).to_i, project_id: project_id).save!
    end
  end

  def to_change_deadline!(from, to)
    keep_transaction do
      update deadline: to
      events.change_deadline.create!(
        user_id: operator.try(:id).to_i, project_id: project_id,
        extras: { from: from, to: to }.to_json
      )
    end
  end

  def generate_comments!(user, opts = {})
    comments.create!(opts.merge(user_id: user.id, operator: user))
  end
end
