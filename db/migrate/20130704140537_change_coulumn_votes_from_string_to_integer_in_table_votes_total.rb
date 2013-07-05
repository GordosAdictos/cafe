class ChangeCoulumnVotesFromStringToIntegerInTableVotesTotal < ActiveRecord::Migration
  def change
    change_column :votes_totals, :votes, :integer
  end
end
