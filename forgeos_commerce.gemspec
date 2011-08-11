Gem::Specification.new do |s|
  s.add_dependency 'forgeos_cms', '>= 1.9.4'
  s.add_dependency 'aasm', '>= 2.2.0'
  s.add_dependency 'ruleby', '0.6'
  s.name = 'forgeos_commerce'
  s.version = '1.9.0'
  s.date = '2011-08-10'

  s.summary = 'Commerce of Forgeos plugins suite'
  s.description = 'Forgeos Commerce provide products, cart, wishlist, orders'

  s.authors = ['Cyril LEPAGNOT', 'Jean Charles Lefrancois']
  s.email = 'dev@webpulser.com'
  s.homepage = 'http://github.com/webpulser/forgeos_commerce'

  s.files = Dir['{app,lib,config,db,recipes}/**/*', 'README*', 'LICENSE', 'COPYING*']
end
