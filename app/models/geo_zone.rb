class GeoZone < ActiveRecord::Base
  has_many :vouchers
  
  def to_jstree
    hash = {}
    hash[:attributes] = { :id => "#{self.class.to_s.underscore}_#{id}", :type => 'folder' }
    hash[:data] = { :title => "#{name}<span>#{TransporterRule.count(:all,:conditions => ['conditions LIKE ?', '%m.geo_zone_id.==('+id.to_s+')%'])}</span>", :attributes => { :class => 'big-icons', :style => 'category_picture' }}
    unless children.empty?
     hash[:children] = children.collect(&:to_jstree)
    end
    hash
  end
    
end
