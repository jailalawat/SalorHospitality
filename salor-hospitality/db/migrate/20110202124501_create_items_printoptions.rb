class CreateItemsPrintoptions < ActiveRecord::Migration
  def self.up
    create_table :items_printoptions, :id => false do |t|
      t.references :item
      t.references :option
      t.timestamps
    end
  end

  def self.down
    drop_table :items_printoptions
  end
end
