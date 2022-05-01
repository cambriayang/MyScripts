#!/usr/bin/ruby

def remove_reactivecocoa_warning
	file = `find . -type f -name 'NSObject+RACPropertySubscribing.h'`.split("\n").first
	`sed -i '' '/^.*\-Wreceiver\-is\-weak.*$/d' #{file}`
end

remove_reactivecocoa_warning
