class Project < ApplicationUidRecord
  acts_as_paranoid without_default_scope: true

  belongs_to :team
  has_many :todolists
  has_many :todos

  validates_presence_of :name

  has_many :events, as: :resource
  attr_accessor :operator
  after_create -> (obj) {
    trigger_add_event user_id: obj.operator.try(:id).to_i, project_id: obj.id
  }
  after_destroy -> (obj) {
    trigger_remove_event user_id: obj.operator.try(:id).to_i, project_id: obj.id
  }

  def generate_todolist!(name)
    todolists.create! name: name, user_id: operator.id, operator: operator, project_uid: uid
  end
  
  def generate_default_todolist!
    generate_todolist! I18n.t(:default_todolist)
  end
end
