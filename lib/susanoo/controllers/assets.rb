require 'rack'
require 'uglifier'
require 'yui/compressor'

class Susanoo::Application

  # This controller is responsible for serving/building assets files
  class Assets < Susanoo::Controller
    def call(env)
      # Environment is a sprockets environment instance
      environment.call env
    end

    def build(generator, options)
      platform = options[:platform]

      Sprockets::Helpers.configure do |config|
        config.prefix      = "/#{platform}_asset/www/assets"
        config.debug       = false
        config.environment = @environment
      end

      @environment.append_path File.join(project_root,
                                   'src/assets/javascripts')
      @environment.append_path File.join(project_root,
                             'src/assets/stylesheets')

      @environment.append_path File.join(project_root,
                                   'src/assets/fonts')
      @environment.append_path File.join(project_root,
                                   'src/assets/sounds')

      @environment.append_path File.join(project_root,
                                   'src/assets/audios')
      @environment.append_path File.join(project_root,
                                   'src/assets/videos')

      unless Susanoo::Project.debug
        puts ">>>>>>>>>>>>>" * 100
        @environment.js_compressor  = :uglify
        @environment.css_compressor = :scss
      end

      func = lambda do |path, filename|
        filename !~ %r~assets~  && !%w[.js .css].include?(File.extname(path))
      end

      precompile = [func, /(?:\/|\\|\A)application\.(css|js)$/]
      @environment.each_logical_path(*precompile).each {|path|
        case File.extname(path)
        when '.js'
          dir = 'javascripts'
        when '.css'
          dir = 'stylesheets'
        end
        @environment[path].write_to "www/assets/#{path}"
        #@environment[path].write_to "www/assets/#{dir}/#{path}"
      }

      if File.exist? File.join(project_root,
                               'src/assets/images')
        generator.say_status 'copy', 'src/assets/images'
        `cp #{project_root}/src/assets/images #{project_root}/www/assets/images -r`
      end

      if File.exist? File.join(project_root,
                               'src/assets/fonts')
        generator.say_status 'copy', 'src/assets/fonts'
        `cp #{project_root}/src/assets/fonts #{project_root}/www/assets/fonts -r`
      end

      if File.exist? File.join(project_root,
                               'src/assets/sounds')
        generator.say_status 'copy', 'src/assets/sounds'
        `cp #{project_root}/src/assets/sounds #{project_root}/www/assets/sounds -r`
      end

      if File.exist? File.join(project_root,
                               'src/assets/audios')
        generator.say_status 'copy', 'src/assets/audios'
        `cp #{project_root}/src/assets/audios #{project_root}/www/assets/audios -r`
      end

      if File.exist? File.join(project_root,
                               'src/assets/videos')
        generator.say_status 'copy', 'src/assets/videos'
        `cp #{project_root}/src/assets/videos #{project_root}/www/assets/videos -r`
      end

    end
  end
end
