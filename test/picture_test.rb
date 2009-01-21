require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class PictureTest < Test::Unit::TestCase
  # load all fixtures Pictures
  def setup
    @pictures = []
    %w[files/picture1.jpg files/picture2.jpg].each do |picture|
      @pictures << RailsCommerce::Picture.create( :uploaded_data => fixture_file_upload(picture,'image/jpeg'))
    end
  end
  
  # remove all RailsCommerce::Pictures after each test
  def teardown
    RailsCommerce::Picture.destroy_all
  end

  # test if all fixtures pictures are well loaded
  def test_pictures_loaded
    assert_equal 2, RailsCommerce::Picture.find(:all, :conditions => 'parent_id IS NULL').size
  end

  # test RailsCommerce::Product Picture create
  def test_product_parent_picture_creation
    product = rails_commerce_products(:phone)
    product.pictures.create(:uploaded_data => fixture_file_upload('files/picture1.jpg','image/jpeg'))
    assert_equal 1, product.pictures.count
  end

  # test RailsCommerce::Product Pictures sorting
  def test_product_picture_sort
    product = rails_commerce_products(:phone)
    product.pictures.create(:uploaded_data => fixture_file_upload('files/picture1.jpg','image/jpeg'))
    product.pictures.create(:uploaded_data => fixture_file_upload('files/picture2.jpg','image/jpeg'))

    first_picture = product.pictures[0]
    second_picture = product.pictures[1]

    assert_equal first_picture, product.sortable_pictures.first.picture
    product.sortable_pictures[0].update_attribute('position',2)
    product.sortable_pictures[1].update_attribute('position',1)

    product.reload

    assert_equal first_picture, product.pictures.last
    assert_equal second_picture, product.pictures.first
  end

  # test RailsCommerce::Category Picture create
  def test_category_picture_creation
    category = rails_commerce_categories(:category_high_tech)
    category.pictures.create(:uploaded_data => fixture_file_upload('files/picture1.jpg','image/jpeg'))
    assert_equal 1, category.pictures.count
    assert_equal 'picture1.jpg', category.pictures.first.filename
  end

  # test RailsCommerce::Category Pictures sorting
  def test_category_picture_sort
    category = rails_commerce_categories(:category_high_tech)
    category.pictures.create(:uploaded_data => fixture_file_upload('files/picture1.jpg','image/jpeg'))
    category.pictures.create(:uploaded_data => fixture_file_upload('files/picture2.jpg','image/jpeg'))

    first_picture = category.pictures[0]
    second_picture = category.pictures[1]

    assert_equal first_picture, category.sortable_pictures.first.picture
    category.sortable_pictures[0].update_attribute('position',2)
    category.sortable_pictures[1].update_attribute('position',1)

    category.reload

    assert_equal first_picture, category.pictures.last
    assert_equal second_picture, category.pictures.first
  end

  # test RailsCommerce::Picture creation
  def test_picture_create
    RailsCommerce::Picture.create( :uploaded_data => fixture_file_upload('files/picture1.jpg','image/jpeg')).id
    assert_equal 3, RailsCommerce::Picture.count(:conditions => 'parent_id IS NULL')
  end
  
  # test RailsCommerce::Picture destroy and there associated comments
  def test_picture_destroy
    picture_id = @pictures.first.id
    @pictures.first.comments.create(:comment => 'test_picture_destroy', :title => 'test')
    assert_not_equal nil, @pictures.first.destroy
    assert_equal 1, RailsCommerce::Picture.count(:conditions => 'parent_id IS NULL')
    assert_equal 0, Comment.find_all_by_commentable_type_and_commentable_id('RailsCommerce::Picture', picture_id).size
  end
  
  # test RailsCommerce::Picture comments creation
  def test_picture_add_comment
    picture = @pictures.first
    assert_equal 0, picture.comments.count
    picture.comments.create(:comment => 'test_picture_add_comment', :title => 'test')
    assert_equal 1, picture.comments.count
    assert_equal 0, picture.comments.first.user_id
    assert_equal 'test', picture.comments.first.title
    assert_equal 'test_picture_add_comment', picture.comments.first.comment
  end

  # test RailsCommerce::Picture comments destroy
  def test_picture_destroy_comment
    picture = @pictures.first
    picture.comments.create(:comment => 'test_picture_add_comment', :title => 'test')
    assert_not_equal nil, picture.comments.destroy_all
    assert_equal 0, picture.comments.count
  end
end
