class AddAddresseAndJobDescriptionToProposals < ActiveRecord::Migration[8.0]
  def change
    add_column :proposals, :addresse, :string
    add_column :proposals, :job_description, :text
  end
end
