class CreateElasticsearchGoLinks < ActiveRecord::Migration
  def change
    create_table :elasticsearch_go_links do |t|
      t.integer :clicks
      t.string :email
      t.string :key 
      t.string :url 
      t.string :description
      t.string :permissions
      t.text :fulltext
      t.string :golink_type
      t.string :parse_id
      t.timestamps
    end
  end
end
