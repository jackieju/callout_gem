rm *.gem
echo build..
gem build calloutd.gemspec
echo install..
gem install --local *.gem
# sudo gem install --local calloutd*.gem
