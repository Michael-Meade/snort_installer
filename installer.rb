require 'colorize'
require 'open3'
def self.install_snort
	[
		"wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz", 
		"tar -xvzf daq-2.0.6.tar.gz", 
		"cd daq-2.0.6", 
		"./configure && make && sudo make install", 
		"./configure && make && sudo make install",
		"wget https://www.snort.org/downloads/snort/snort-2.9.11.1.tar.gz",
		"tar -xvzf snort-2.9.11.1.tar.gz",
		"cd snort-2.9.11.1",
		"./configure --enable-sourcefire && make && sudo make install",
	]
end
def self.create_user
	[
		"sudo ldconfig",
		"sudo ln -s /usr/local/bin/snort /usr/sbin/snort",
		"sudo groupadd snort",
		"sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort"
	]
end
def self.create_folder
	[
		"sudo mkdir -p /etc/snort/rules",
		"sudo mkdir /var/log/snort",
		"sudo mkdir /usr/local/lib/snort_dynamicrules"
	]
end
def self.permissions
	[
		"sudo chmod -R 5775 /etc/snort",
		"sudo chmod -R 5775 /var/log/snort",
		"sudo chmod -R 5775 /usr/local/lib/snort_dynamicrules",
		"sudo chown -R snort:snort /etc/snort",
		"sudo chown -R snort:snort /var/log/snort",
		"sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules",
		"sudo touch /etc/snort/rules/white_list.rules",
		"sudo touch /etc/snort/rules/black_list.rules",
		"sudo touch /etc/snort/rules/local.rules",
		"sudo cp ~/snort_src/snort-2.9.11.1/etc/*.conf* /etc/snort",
		"sudo cp ~/snort_src/snort-2.9.11.1/etc/*.map /etc/snort"
	]
end
def self.install_rules
	[
		"sudo tar -xvf ~/community.tar.gz -C ~/",
		"sudo cp ~/community-rules/* /etc/snort/rules",
		"sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf"
	]
end
install_snort.each do |install|
	system(install)
end
create_user.each do |user|
	system(user)
end
begin
	stdout, status = Open3.capture2('getent passwd snort')
	# check if user was not created
	if !stdout.nil? || !stdout.to_s.strip.empty?
		create_folder.each do |folder|
			system(folder)
		end
	else
		puts "User not created".red
	end
rescue => e
	puts e.red
end

permissions.each do |permissions|
	system(permissions)
end
install_rules.each do |rules|
	system(rules)
end
