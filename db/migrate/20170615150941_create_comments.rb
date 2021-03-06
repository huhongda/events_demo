class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.string :uid, null: false, default: '', limit: 32, comment: 'unique id'
      t.references :user, null: false, default: 0
      t.references :todo, null: false, default: 0
      t.text :content
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :comments, :deleted_at
  end
end
