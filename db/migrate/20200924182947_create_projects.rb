class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :project_status_id

      t.timestamps
    end

    add_reference :projects, :client, foreign_key: true
    add_index :projects, :name, unique: true
  end
end
