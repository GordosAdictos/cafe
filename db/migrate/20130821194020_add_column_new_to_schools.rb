class AddColumnNewToSchools < ActiveRecord::Migration
  def change
  	   add_column :schools, :new, :boolean
  end
end
