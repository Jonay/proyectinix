class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string   :title
      t.text     :description
      t.date     :start_date
      t.date     :end_date
      t.time     :start_time
      t.time     :end_time 
      t.string   :url          #link to event website
      t.string   :venue        #name of event's location
      t.string   :venue_link   #link to location
      t.string   :lat          #lat to location
      t.string   :lng         #long to location
      t.integer  :user_id
      t.string   :id_referencia
      t.string   :tipo
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
