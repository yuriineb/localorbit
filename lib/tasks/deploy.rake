namespace :deploy do
  desc "Deploy localorbit to staging"
  task :staging do
    app = "localorbit-staging"
    remote = "git@heroku.com:#{app}.git"

    system "git push #{remote} rails:master"
    Bundler.with_clean_env do
      system "heroku run --app #{app} rake db:migrate"
      system "heroku restart --app #{app}"
    end
  end

  desc "Deploy localorbit to production"
  task :production do
    app = "localorbit"
    remote = "git@heroku.com:#{app}.git"

    system "git push #{remote} rails:master"
    Bundler.with_clean_env do
      system "heroku run --app #{app} rake db:migrate"
      system "heroku restart --app #{app}"
    end
  end
end
