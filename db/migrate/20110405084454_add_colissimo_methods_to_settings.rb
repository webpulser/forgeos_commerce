class AddColissimoMethodsToSettings < ActiveRecord::Migration
  def self.up
    begin
      add_column :settings, :colissimo_methods, :text, :force => true
    rescue
      p "already exists"
    end
  end

  def self.down
    remove_column :settings, :colissimo_methods
  end
end
