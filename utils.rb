require 'open3'
class Utils
	def self.check(command)
		stdout, status = Open3.capture3(command)
	end
	def self.write_file(file, command, opt=nil)
		f = File.open(file, "a")
		f.write(command)
		f.close
		if opt.nil?
			puts "Added #{command.green} to #{file.green}!\n"
		end
	end
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
	def self.snort_config
		[
			"ipvar HOME_NET 169.254.74.118/24\n",
			"ipvar EXTERNAL_NET any\n",
			"var RULE_PATH /etc/snort/rules\n",
			"var PREPROC_RULE_PATH /etc/snort/preproc_rules\n",
			"var WHITE_LIST_PATH /etc/snort/rules\n",
			"var BLACK_LIST_PATH /etc/snort/rules\n",
			"include $RULE_PATH/local.rules\n"
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
end
