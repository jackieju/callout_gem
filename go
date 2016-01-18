rm *.gem
gem build calloutd.gemspec
gem install *.gem
# sudo gem install --local calloutd*.gem
