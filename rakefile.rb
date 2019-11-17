require_relative 'utils'
require 'colorize'
task :install do 
	begin
		stdout = Utils.check("snort -V")
		if stdout.to_s.include?("Snort")
			puts "Already Installed".red
		else
			Utils.install.each do |install|
				system(install)
			end
			Utils.snort_config.each do |config|
				Utils.write_file("/etc/snort/snort.conf", config, 1)
			end
		end
	rescue => e
		Utils.install.each do |install|
			system(install)
		end
		Utils.snort_config.each do |config|
			Utils.write_file("/etc/snort/snort.conf", config, 1)
		end
	end
	 Rake::Task[:config].invoke
end
task config: "install"  do 
	stdout = Utils.check("snort -V")
	if stdout.to_s.include?("Snort")
		puts "Already Installed".red
	else
		Utils.configure.each do |config|
			system(config)
		end
	end
	# edit the config
	
	Rake::Task[:rules].invoke
end
task rules: "config" do
	stdout = Utils.check("snort -T -i eth0 -c /etc/snort/snort.conf")
	if stdout.to_s.include?("Snort successfully validated the configuration!")
		puts "BOOMSHAKALAKA! Its all set up!".green
		# edit the local rules
		if File.zero?("/etc/snort/rules/local.rules")
			Utils.write_file("/etc/snort/rules/local.rules", "Alert icmp any any -> $HOME_NET any (msg:”Someone is pinging”; itype:8; sid:1000001;)\n")
			Utils.write_file("/etc/snort/rules/local.rules", "Alert tcp any any -> $HOME_NET 22 (msg:”SSH connection detected”; sid:1000002;)\n")
		end
		#puts Utils.check("ifconfig")
	else
		stdout = Utils.check("snort -T -i eth0 -c /etc/snort/snort.conf")
		if stdout.to_s.include?("Snort successfully validated the configuration!")
			Utils.write_file("/etc/snort/rules/local.rules", "Alert icmp any any -> $HOME_NET any (msg:”Someone is pinging”; itype:8; sid:1000001;)\n")
			Utils.write_file("/etc/snort/rules/local.rules", "Alert tcp any any -> $HOME_NET 22 (msg:”SSH connection detected”; sid:1000002;)\n")
		end
	end
	Rake::Task[:createuser].invoke
end
task :createuser do
	stdout = Utils.check("id -u snort").to_s
	if stdout.include?("no")
		puts "Creating user....."
		system("useradd -m -p 'password' snort")
	end
	Rake::Task[:start].invoke
end
task :start do
			#sudo snort -A console -i ens3 -u snort -g snort -c /etc/snort/snort.conf
	system("snort -A console -i eth0 -u snort -g snort -c /etc/snort/snort.conf")
end
