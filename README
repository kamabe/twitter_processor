# Requirements
- Ubuntu 12.04
- Postgres 9.1
- RabbitMQ 2.7.1
- supervisor 3.1.3 (installed via apt, not pip, and uses the built in Python)
- All gems in Gemfile

# Before Running
- Set the postgres user's password
- Create a database named twitter
- Pull down code into /opt/twitter
- Make sure supervisord.conf from application directory is put in /etc/supervisord.conf
- Run the sequel migration in application directory (/vagrant) via `sequel -E -m migrations postgres://localhost/twitter?password=postgres&user=postgres`

# To Run
- Start supervisor with `sudo start supervisord` (if not already running on startup)
- Run `ruby /opt/twitter/report_worker.rb` to see report output
