class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string  :title
      t.text    :description
      t.integer :author_id
      t.string  :id_referencia
      t.string  :tipo
      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end
