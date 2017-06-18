class Event < ApplicationUidRecord
  delegate :url_helpers, to: 'Rails.application.routes'

  belongs_to :user
  belongs_to :project
  has_one :event_assigner

  ROUTES_RELATION = {todo: :project_todo_path, todolist: :project_todolist_path, project: :team_project_path, team: :team_projects}.freeze

  belongs_to :resource, polymorphic: true
  enum action: %i(add move remove close reopen assign rename edit reply)

  scope :by_team, -> (team_uid, user) do
    where(project_id: Project.with_deleted.where(team_uid: team_uid).pluck(:id))
  end

  scope :search, -> (opts) do
    [User, Project].each do |model|
      core_key = model.to_s.downcase
      opts["#{core_key}_id"] = mode.find_by(uid: opts["#{core_key}_uid"]) if opts["#{core_key}_uid"].present?
    end
    where(opts.slice(:user_id, :project_id))
  end

  def action_display
    send("#{resource_type.downcase}_#{action}_action_display")
  end

  def resource_name_display
    send("#{resource_type.downcase}_resource_name")
  end
  
  def resource_detail
    send("#{resource_type.downcase}_resource_detail")
  end

  private

  def comment_add_action_display
    Event.actions_i18n[:reply]
  end

  # TODO
  def todo_assign_action_display

  end

  def comment_resource_name
    resource.todo.model_name.human
  end

  def comment_resource_detail
    url = url_helpers.project_todo_path(resource.todo.project_uid, resource.todo)
    {
      name: resource.todo.name,
      content: resource.content,
      link: "#{url}##{resource.uid}"
    }
  end

  def todo_resource_detail
    default_detail.merge(link: url_helpers.project_todo_path(resource.project_uid, resource))
  end

  def todolist_resource_detail
    default_detail.merge(link: url_helpers.project_todolist_path(resource.project_uid, resource))
  end

  def team_resource_detail
    default_detail.merge(link: url_helpers.team_projects_path(resource))
  end

  def project_resource_detail
    default_detail.merge(link: url_helpers.team_project_path(resource.team_uid, resource))
  end

  def default_detail
    {name: resource.name, content: nil}
  end

  # NOTE: if the resource has special display, need generate a special method,
  #       such as: comment_add_action_display or todo_assign_resource_display
  %i(todo todolist project team).each do |type|

    # resource model name
    define_method "#{type}_resource_name" do
      resource_type.constantize.model_name.human
    end

    # resource action name
    %i(add remove close edit).each do |action|
      define_method "#{type}_#{action}_action_display" do
        action_i18n
      end
    end
  end

end
