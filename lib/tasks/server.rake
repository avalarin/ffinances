namespace :server do

  def pid_file
    File.join(Rails.root, 'tmp/pids/server.pid')
  end

  def server_pid
    file = pid_file
    return nil unless File.file?(file)
    pid = File.read(file).to_i
    Process.getpgid( pid )
      return pid
    rescue Errno::ESRCH
      return nil
  end

  def start
    pid = server_pid
    if pid
      puts "Already started."
      return
    end
    puts "Starting server..."
    server_pid = IO.popen('rails server -p 3000 > /dev/null 2> /dev/null').pid
  end

  def stop
    pid = server_pid
    if !pid
      puts "Server is not running."
      return
    end
    puts "Stoping server..."
    `kill -9 #{pid}`
  end

  desc "TODO"
  task start: :environment do
    start
  end

  desc "TODO"
  task stop: :environment do
    stop
  end

  desc "TODO"
  task restart: :environment do
    stop
    sleep 1
    start
  end

  desc "TODO"
  task status: :environment do
    pid = server_pid
    if pid
      puts "Running: #{pid}"
    else
      puts "Stopped"
    end
  end

end