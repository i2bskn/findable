namespace :findable do
  desc "Load seed file of findable."
  task :seed => :environment do
    if Findable.config.seed_file
      load Findable.config.seed_file
    end
  end
end
