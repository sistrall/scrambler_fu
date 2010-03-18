# desc "Explaining what the task does"
# task :scrambler_fu do
#   # Task goes here
# end

namespace :db do
  desc "Scrambles everything!"
  task :scramble => :environment do
    Dir["#{RAILS_ROOT}/app/models/**/*.rb"].each do |file|
      require file
    end

    Scrambler.scramble!
  end
end
  