class CreateTogForumTables < ActiveRecord::Migration
  def self.up
    create_table :tog_forum_forums do |t|
      t.string   :title
      t.integer  :user_id
      t.string   :id_referencia
      t.string   :tipo
      t.timestamps
    end

    create_table :tog_forum_topics do |t|
      t.integer  :forum_id, :references => :tog_forum_forums
      t.integer  :user_id
      t.string   :title
      t.text     :body
      t.boolean  :sticky
      t.boolean  :locked
      t.datetime :last_post_at
      t.integer  :last_post_by
      t.timestamps
    end

    create_table :tog_forum_posts do |t|
      t.integer  :topic_id, :references => :tog_forum_topics
      t.integer  :user_id
      t.text     :body
      t.timestamps
    end

  end

  def self.down
    drop_table :tog_forum_posts
    drop_table :tog_forum_topics
    drop_table :tog_forum_forums
  end
end
