class AddWorkExperienceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :work_experience, :text
  end
end
