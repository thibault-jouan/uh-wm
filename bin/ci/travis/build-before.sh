export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

export UHWMTEST_CI=yes
export UHWMTEST_TIMEOUT=8
