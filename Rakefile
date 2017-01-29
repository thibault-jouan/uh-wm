require 'tempfile'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

XEPHYR_DISPLAY  = ':42'
XEPHYR_CMD      = "$(command -v Xephyr) #{XEPHYR_DISPLAY} -ac -br -noreset".freeze
XEPHYR_SCREENS  = '-screen 1436x400'.freeze
XEPHYR_SCREENS_XINERAMA =
  '+xinerama -origin 0,0 -screen 1920x400 -origin 1920,0 -screen 1920x400'.freeze

task default: %i[features spec]

Cucumber::Rake::Task.new :features do |t|
  if ENV.key? 'TRAVIS'
    t.profile       = 'quiet'
    t.cucumber_opts = %w[
      --tags ~@kqueue
      --tags ~@rc_mod
      --tags ~@other_wm_running
    ]
  end
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--format progress' if ENV.key? 'TRAVIS'
end

desc 'Run uhwm in a Xephyr X server'
task :run do
  uhwm_args = ARGV.include?('--') ?
    ARGV.drop_while { |e| e != '--' }.drop(1) :
    %w[-d]
  Tempfile.create('uhwm_xinitrc') do |xinitrc|
    xinitrc.write <<-eoh
[ -f $HOME/.Xdefaults ] && xrdb $HOME/.Xdefaults
#xkbcomp #{ENV['DISPLAY']} #{XEPHYR_DISPLAY}
xmodmap -display #{ENV['DISPLAY']} -pke | xmodmap -
xsetroot -solid SpringGreen
echo "######## UHWM START ########"
./bin/uhwm #{uhwm_args.join ' '}
echo "######## UHWM END ##########"
    eoh
    xinitrc.flush
    sh "xinit #{xinitrc.path} --  %s" % [
      XEPHYR_CMD,
      ENV.key?('UHWM_XINERAMA') ?
        XEPHYR_SCREENS_XINERAMA :
        XEPHYR_SCREENS
    ].join(' ')
  end
end
