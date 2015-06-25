namespace :findable do
  desc "Load seed file of findable."
  task :seeds => :environment do
    if Findable.config.seed_file
      load Findable.config.seed_file
    end
  end
end

