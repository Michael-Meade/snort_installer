require 'open3'
require 'colorize'
def self.install
	[
			"apt-get install openssh-server ethtool build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev liblzma-dev openssl libssl-dev",
			"wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz",
			"tar -zxvf daq-2.0.6.tar.gz",
			"cd daq-2.0.6",
			"./daq-2.0.6/configure && make && make install",
			"wget https://www.snort.org/downloads/snort/snort-2.9.15.tar.gz",
			"tar -xvzf snort-2.9.15.tar.gz",
			"cd snort-2.9.15.tar.gz",
			"./snort-2.9.15/configure --enable-sourcefire  --disable-open-appid && make && make install",
			"ldconfig",
			"ln -s /usr/local/bin/snort /usr/sbin/snort"
	]
end
def self.configure
	[
		"mkdir /etc/snort",
		"mkdir /etc/snort/preproc_rules",
 		"mkdir /etc/snort/rules",
 		"mkdir /var/log/snort",
 		"mkdir /usr/local/lib/snort_dynamicrules",
 		"touch /etc/snort/rules/white_list.rules",
 		"touch /etc/snort/rules/black_list.rules",
 		"touch /etc/snort/rules/local.rules",
 		"chmod -R 5775 /etc/snort/",
 		"chmod -R 5775 /var/log/snort/",
 		"chmod -R 5775 /usr/local/lib/snort",
 		"chmod -R 5775 /usr/local/lib/snort_dynamicrules/",
 		"cd snort-2.9.8.3",
 		"cp -avr *.conf *.map *.dtd /etc/snort/",
 		"cp -avr src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor/* /usr/local/lib/snort_dynamicpreprocessor/",
 		'sed -i "s/include \$RULE\_PATH/#include \$RULE\_PATH/" /etc/snort/snort.conf'
 	]
end
def self.check(command)
	stdout, status = Open3.capture2(command)
end
def self.write_file(file, command)
	f = File.open(file, "a")
	f << command
	f.close
	puts "Added #{command} to #{file}!\n"
end
install.each do |install|
	system(install)
end
# check if installed
stdout = check("snort -V")

if !stdout.include?("Version") || !stdout.include?("Snort")
	# it didnt :/
	puts "is snort installed?".red
end


configure.each do |config|
	system(config)
	puts "open => nano /etc/snort/snort.conf"
	puts "change ipvar HOME_NET && ipvar EXTERNAL_NET"
end

stdout = check("snort -T -i eth0 -c /etc/snort/snort.conf")
if stdout.include?("Snort successfully validated the configuration!")
	puts "BOOMSHAKALAKA! Its all set up!".green
	# edit the local rules
	write_file("/etc/snort/rules/local.rules", "Alert icmp any any -> $HOME_NET any (msg:”Someone is pinging”; itype:8; sid:1000001;) #This will alert you to ping attempts")
	write_file("/etc/snort/rules/local.rules", "Alert tcp any any -> $HOME_NET 22 (msg:”SSH connection detected”; sid:1000002;) #This will alert you to any incoming SSH connections")
	# enters ifconfig
	puts check("ifconfig")
end
