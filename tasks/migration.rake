namespace :rails_commerce do
  desc 'Create RailsCommerce database tables'
  task :setup => [ :create_tables ]

  desc "Load fixtures (from test/fixtures) into the current environment's database." 
  task :load_fixtures => :environment do
    require 'active_record/fixtures'

    # Associate fixtures/models
    class_names = {
      :rails_commerce_shipping_method_details => RailsCommerce::ShippingMethodDetail,
      :rails_commerce_attributes              => RailsCommerce::Attribute,
      :rails_commerce_categories              => RailsCommerce::Category,
      :rails_commerce_addresses               => RailsCommerce::Address,
      :rails_commerce_products                => RailsCommerce::Product,
    }

    DIR = "#{RAILS_ROOT}/vendor/plugins/rails_commerce/test/fixtures"
    tables = ENV['FIXTURES'] ? (ENV['FIXTURES'] + '.yml' ).gsub(',','.yml,').split(',') : Dir.glob("#{DIR}/*.yml")
    tables.each do |file|
      file_name = File.basename(file, '.*')
      puts "Load #{file_name} fixtures"
      Fixtures.create_fixtures(DIR, file_name, class_names)
    end
  end
  
  task :migration_down => :environment do
    # TODO - if schema_info not installed
    id = RailsCommerce::SchemaInfo.find(:first).version

    version = ENV['VERSION'].to_i + 1
    if version.to_i > id || id == 0
      puts "No migration..."
    else
      (version..id).to_a.reverse.each do |version|
        puts "Executing down migration #{version}"
        `rake rails_commerce:down_migration_#{version}`
      end
    end
  end
  task :migration => :environment do
    # TODO - globalize MAX
    MAX = 14
    # TODO - if schema_info not installed
    id = RailsCommerce::SchemaInfo.find(:first).version + 1
    unless MAX >= id
      puts "No migration..."
    else
      (id..MAX).each do |version|
        puts "Executing migration #{version}"
        puts `rake rails_commerce:migration_#{version}`
      end
    end
  end

  desc 'Migrate the database through scripts of RailsCommerce'
  task :migrate => :environment do
    puts `rake rails_commerce:setup` unless RailsCommerce::SchemaInfo.table_exists?

    if ENV['VERSION']
      puts `rake rails_commerce:migration_down VERSION=#{ENV['VERSION']}`
    else
      puts `rake rails_commerce:migration`
    end
    `rake db:schema:dump`
    puts "complete..."
  end

# => TODO - multilinguism (Globalize2, I18n)
#  task :init_translation => :environment do
#    ActiveRecord::Base.silence do
#      path = File.join File.dirname( __FILE__ ), '../data', "translation_data.csv"
#      reader = CSV::Reader.create File.open( path ).read
#
#      reader.each do |row|
#        view_translation = ViewTranslation.find_by_tr_key_and_language_id(row[0], 1930)
#        if view_translation
#          view_translation.update_attributes(:text => row[1], :pluralization_index => true)
#        else
#          ViewTranslation.create(:tr_key => row[0], :text => row[1], :language_id => 1930, :pluralization_index => true)
#        end
#      end
#    end
#  end

  desc 'Create RailsCommerce database tables'
  task :create_tables => :environment do
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?
    puts "Create RailsCommerce database tables"

    ActiveRecord::Base.connection.create_table :rails_commerce_products, :force => @force do |t|
      t.string :name
      t.string :description
      t.float :price
      t.float :rate_tax
      t.boolean :offer_month
      t.boolean :on_first_page
      t.integer :product_id
      t.string :type
      t.timestamps
    end
    
    ActiveRecord::Base.connection.create_table :rails_commerce_carts, :force => @force do |t|
      t.integer :user_id
      t.timestamps
    end
    
    ActiveRecord::Base.connection.create_table :rails_commerce_carts_products, :force => @force do |t|
      t.integer :cart_id
      t.integer :product_id
      t.integer :quantity
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_products, :id => false, :force => @force do |t|
      t.integer :product_id
      t.integer :picture_id
    end
    
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures, :force => @force do |t|
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer

      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string

      # required for images only
      t.column "width", :integer  
      t.column "height", :integer

      # required for db-based files only
      t.column "db_file_id", :integer
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_attributes_groups, :force => @force do |t|
      t.string :name
      t.timestamps
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_attributes, :force => @force do |t|
      t.string :name
      t.integer :attributes_group_id
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_attributes_groups_products, :id => false, :force => @force do |t|
      t.integer :attributes_group_id
      t.integer :product_id
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_attributes_products, :id => false, :force => @force do |t|
      t.integer :attribute_id
      t.integer :product_id
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_currencies, :force => @force do |t|
      t.string :name
      t.string :html
      t.boolean :default
      t.timestamps
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_currencies_exchanges_rates, :force => @force do |t|
      t.integer :from_currency_id
      t.integer :to_currency_id
      t.float :rate
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_schema_info, :force => @force do |t|
      t.integer :version
    end
    RailsCommerce::SchemaInfo.create :version => 0
  end
  
  task :migration_1 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_categories, :force => @force do |t|
      t.string :name
      t.integer :parent_id
      t.timestamps
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_categories_products, :id => false, :force => @force do |t|
      t.integer :category_id, :product_id
      t.timestamps
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 1)
  end
  task :down_migration_1 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_categories
    ActiveRecord::Base.connection.drop_table :rails_commerce_categories_products
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 0)
  end

  task :migration_2 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_orders, :force => @force do |t|
      t.integer :user_id, :address_delivery_id, :address_invoice_id
      t.string :status
      t.timestamps
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_orders_details, :force => @force do |t|
      t.string :name, :description
      t.float :price, :rate_tax
      t.integer :order_id, :quantity
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_namables, :force => @force do |t|
      t.string :name, :type
      t.timestamps
    end

    ActiveRecord::Base.connection.create_table :rails_commerce_addresses, :force => @force do |t|
      t.string :civility_id, :country_id, :name, :firstname, :address, :address_2, :zip_code, :city, :type
      t.integer :user_id
      t.timestamps
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_addresses_users, :force => @force do |t|
      t.integer :address_id, :user_id, :address_type
      t.timestamps
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 2)
  end
  task :down_migration_2 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_orders
    ActiveRecord::Base.connection.drop_table :rails_commerce_orders_details
    ActiveRecord::Base.connection.drop_table :rails_commerce_namables
    ActiveRecord::Base.connection.drop_table :rails_commerce_addresses
    ActiveRecord::Base.connection.drop_table :rails_commerce_addresses_users
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 1)
  end

  task :migration_3 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_shipping_methods, :force => @force do |t|
      t.string :name, :description
      t.timestamps
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_shipping_method_details, :force => @force do |t|
      t.string :name
      t.float :weight_min, :weight_max, :price
      t.integer :shipping_method_id
      t.timestamps
    end
    ActiveRecord::Base.connection.add_column :rails_commerce_products, :weight, :float, :default => 0
    ActiveRecord::Base.connection.add_column :rails_commerce_orders, :shipping_method, :string
    ActiveRecord::Base.connection.add_column :rails_commerce_orders, :shipping_method_price, :float
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 3)
  end
  task :down_migration_3 => :environment do
    ActiveRecord::Base.connection.remove_column :rails_commerce_products, :weight
    ActiveRecord::Base.connection.drop_table :rails_commerce_shipping_methods
    ActiveRecord::Base.connection.drop_table :rails_commerce_shipping_method_details
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 2)
  end

  task :migration_4 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_vouchers, :force => @force do |t|
      t.string :name, :code
      t.float :value, :total_min
      t.date :date_start, :date_end
      t.timestamps
    end
    ActiveRecord::Base.connection.add_column :rails_commerce_orders, :voucher, :string
    ActiveRecord::Base.connection.add_column :rails_commerce_currencies, :code, :string
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 4)
  end
  task :down_migration_4 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_vouchers
    ActiveRecord::Base.connection.remove_column :rails_commerce_orders, :voucher
    ActiveRecord::Base.connection.remove_column :rails_commerce_currencies, :code
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 3)
  end
  task :migration_5 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_cross_sellings_product_parents, :id => false, :force => @force do |t|
      t.integer :cross_selling_id,:product_parent_id
    end
    ActiveRecord::Base.connection.rename_table :rails_commerce_attributes_products, :rails_commerce_attributes_product_details
    ActiveRecord::Base.connection.rename_column :rails_commerce_attributes_product_details, :product_id, :product_detail_id
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 5)
  end
  task :down_migration_5 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_cross_sellings_product_parents
    ActiveRecord::Base.connection.rename_table :rails_commerce_attributes_product_details, :rails_commerce_attributes_products
    ActiveRecord::Base.connection.rename_column :rails_commerce_attributes_products, :product_detail_id, :product_id
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 4)
  end
  # remove rails_commerce_addresses_users table
  task :migration_6 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_addresses_users
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 6)
  end
  task :down_migration_6 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_addresses_users, :force => @force do |t|
      t.integer :address_id, :user_id, :address_type
      t.timestamps
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 5)
  end
  task :migration_7 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_attributes, :id => false, :force => @force do |t|
      t.integer :picture_id, :attribute_id
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_attributes_groups, :id => false, :force => @force do |t|
      t.integer :picture_id, :attributes_group_id
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 7)
  end
  task :down_migration_7 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_attributes
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_attributes_groups
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 6)
  end
  task :migration_8 => :environment do
    ActiveRecord::Base.connection.create_table :comments, :force => @force do |t|
      t.string :title, :limit => 50, :default => ''
      t.text :comment, :default => ''
      t.datetime :created_at, :null => false
      t.integer :commentable_id, :default => 0, :null => false
      t.string :commentable_type, :default => '', :null => false
      t.integer :user_id, :default => 0, :null => false
    end

    ActiveRecord::Base.connection.add_index :comments, :user_id, :name => 'fk_comments_user'
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 8)
  end
  task :down_migration_8 => :environment do
    ActiveRecord::Base.connection.drop_table :comments
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 7)
  end

  task :migration_9 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_dynamic_attributes, :force => @force do |t|
      t.integer :attributes_group_id, :product_detail_id
      t.string :value
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 9)
  end
  task :down_migration_9 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_dynamic_attributes
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 8)
  end

  task :migration_10 => :environment do
    ActiveRecord::Base.connection.add_column :rails_commerce_products, :selling_date, :date, :force => @force
    ActiveRecord::Base.connection.add_column :rails_commerce_products, :reference, :string, :force => @force
    ActiveRecord::Base.connection.add_column :rails_commerce_products, :barcode, :string, :force => @force
    ActiveRecord::Base.connection.add_column :rails_commerce_products, :keywords, :text, :force => @force
    ActiveRecord::Base.connection.add_column :rails_commerce_products, :stock, :string, :force => @force
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 10)
  end
  task :down_migration_10 => :environment do
    ActiveRecord::Base.connection.remove_column :rails_commerce_products, :selling_date
    ActiveRecord::Base.connection.remove_column :rails_commerce_products, :reference
    ActiveRecord::Base.connection.remove_column :rails_commerce_products, :barcode
    ActiveRecord::Base.connection.remove_column :rails_commerce_products, :keywords
    ActiveRecord::Base.connection.remove_column :rails_commerce_products, :stock
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 9)
  end

  task :migration_11 => :environment do
    ActiveRecord::Base.connection.add_column :rails_commerce_attributes_groups, :dynamic, :boolean, :force => @force
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 11)
  end
  task :down_migration_11 => :environment do
    ActiveRecord::Base.connection.remove_column :rails_commerce_attributes_groups, :dynamic, :force => @force
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 10)
  end

  task :migration_12 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_categories, :id => false, :force => @force do |t|
      t.integer :picture_id, :category_id
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 12)
  end
  task :down_migration_12 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_categories
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 11)
  end

  task :up_migration_13 => :environment do
    ActiveRecord::Base.connection.create_table :rails_commerce_countries, :force => @force do |t|
      t.string :iso, :size => 2
      t.string :iso3, :size => 3
      t.string :name,:printable_name, :size => 80
      t.integer :numcode
    end
  
    ActiveRecord::Base.connection.change_column(:rails_commerce_addresses, :country_id, :integer)
    ActiveRecord::Base.connection.change_column(:rails_commerce_addresses, :civility_id, :integer)
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 13)
  end

  task :migration_13 => [ :up_migration_13, :fill_countries ]

  task :down_migration_13 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_countries
    ActiveRecord::Base.connection.change_column(:rails_commerce_addresses, :country_id, :string)
    ActiveRecord::Base.connection.change_column(:rails_commerce_addresses, :civility_id, :string)
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 12)
  end

  task :migration_14 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_products
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_attributes
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_attributes_groups
    ActiveRecord::Base.connection.drop_table :rails_commerce_pictures_categories
    ActiveRecord::Base.connection.create_table :rails_commerce_sortable_pictures, :force => @force do |t|
      t.integer :product_id, :picture_id, :category_id, :attributes_group_id, :attribute_id, :position
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 14)
  end
  task :down_migration_14 => :environment do
    ActiveRecord::Base.connection.drop_table :rails_commerce_sortable_pictures
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_products, :id => false, :force => @force do |t|
      t.integer :product_id
      t.integer :picture_id
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_attributes, :id => false, :force => @force do |t|
      t.integer :tattribute_id
      t.integer :picture_id
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_attributes_groups, :id => false, :force => @force do |t|
      t.integer :attributes_group_id
      t.integer :picture_id
    end
    ActiveRecord::Base.connection.create_table :rails_commerce_pictures_categories, :id => false, :force => @force do |t|
      t.integer :category_id
      t.integer :picture_id
    end
    RailsCommerce::SchemaInfo.find(:first).update_attribute(:version, 13)
  end

end
