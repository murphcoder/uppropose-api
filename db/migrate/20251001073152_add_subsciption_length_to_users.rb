class AddSubsciptionLengthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :subscription_length, :string
  end
end
