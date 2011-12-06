module Init
  extend self

  DEBUG = false
  Root = File.dirname(__FILE__) + '/..'

  def log(force=false, &message)
    puts yield if block_given? && (force || DEBUG)
  end

  def startup
    log(true) { "Welcome..." }

    libs = []
    lib_dir_glob = "#{Root}/lib/*.rb"
    libs += (Dir[ lib_dir_glob ] - libs)
    log { "loading libs #{libs.inspect}..." }
    libs.each {|f| log{ puts "requiring #{f}"}; require f}

    models = []
    model_dir_glob = "#{Root}/app/models/*.rb"
    models += Dir[ model_dir_glob ]
    log { "loading models #{models}..." }
    models.each {|f| require f}

  end
end

Init.startup
