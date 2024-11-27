class TestMigration < ActiveRecord::Migration[8.0]
  def change
    create_table :some_models do |t|
      t.string :some_text

      # This was added after the first db:migrate was called,
      # then db:drop db:create
      # running db:migrate again will not recognize this new line
      t.string :some_other_text
    end
  end
end
