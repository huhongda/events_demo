class CreateTodolists < ActiveRecord::Migration[5.0]
  def change
    create_table :todolists do |t|
      t.string :uid, null: false, default: '', limit: 32
      t.string :name, null: false, default: '', limit: 50
      t.references :project, null: false, default: 0
      t.string :project_uid, null: false, default: '', comment: 'redundancy column, project_uid'
      t.references :user,  null: false, default: 0, comment: 'create user'
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :todolists, :deleted_at
  end
end
