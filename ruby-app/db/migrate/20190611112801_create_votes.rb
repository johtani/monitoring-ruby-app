class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.references :question, foreign_key: true
      t.string :session_key

      t.timestamps
    end
  end
end
