#!/usr/bin/ruby

require 'optparse'
require 'yaml'

def print_module(name,type,data,description=nil,min_critical=nil,max_critical=nil,min_warning=nil,max_warning=nil,units=nil)
    puts "<module>"
    puts "<name><![CDATA["+name+"]]></name>"
    puts "<description><![CDATA["+description+"]]></description>"
    puts "<type>"+type+"</type>"
    puts "<data><![CDATA["+data.to_s+"]]></data>"
    if min_critical != nil
    	puts "<min_critical>"+min_critical.to_s+"</min_critical>"
    end
    if max_critical != nil
	puts "<max_critical>"+max_critical.to_s+"</max_critical>"
    end
    if min_warning != nil
	puts "<min_warning>"+min_warning.to_s+"</min_warning>"
    end
    if max_warning != nil
	puts "<max_warning>"+max_warning.to_s+"</max_warning>"
    end
    puts "</module>"
end
    

opt = OptionParser.new

summaryfile = ""

opt.on("--summary-file [FILE]", "-s", "Location of the summary file, default #{summaryfile}") do |f|
    summaryfile = f
end

opt.parse!

if summaryfile == ""
	puts "Please specify --summary-file argument"
    	exit 3
end


if not File.exists?(summaryfile)
    puts "Summary file does not exist"
    exit 4
end

summary = YAML.load_file(summaryfile)

#Timing stuff
lastrun = summary["time"]["last_run"]
time_since_last_run = Time.now.to_i - lastrun # In seconds

#Resources stuff
resources_out_of_sync = summary["resources"]["out_of_sync"]
resources_changed = summary["resources"]["changed"]
resources_failed = summary["resources"]["failed"]
resources_failed_to_restart = summary["resources"]["failed_to_restart"]
resources_restarted = summary["resources"]["restarted"]
resources_scheduled = summary["resources"]["scheduled"]
resources_skipped = summary["resources"]["skipped"]

#Events stuff
events_failure = summary["events"]["failure"]
events_success = summary["events"]["success"]

#Changes stuff
changes_total = summary["changes"]["total"]

print_module("Last run","generic_data_string",lastrun,description="Last run timestamp")
print_module("Time since last run","generic_data",time_since_last_run,description="Time since last run in seconds")
print_module("Resources out of sync","generic_data",resources_out_of_sync,description="How many resources were out of sync",min_critical=1)
print_module("Resources changed","generic_data",resources_changed,description="How many resources were changed")
print_module("Resources failed","generic_data",resources_failed,description="How many resources were not successfully fixed",min_critical=1)
print_module("Resources failed to restart","generic_data",resources_failed_to_restart,description="How many resources could not be restarted",min_critical=1)
print_module("Resources restarted","generic_data",resources_restarted,description="How many resources were restarted because their dependencies changed")
print_module("Resources scheduled","generic_data",resources_scheduled,description="How many resources met any scheduling restrictions")
print_module("Resources skipped","generic_data",resources_skipped,description="How many resources were skipped, because of either tagging or scheduling restrictions",min_critical=5)
print_module("Events failed","generic_data",events_failure,description="How many events failed",min_critical=1)
print_module("Events succeeded","generic_data",events_success,description="How many events succeeded")
print_module("Total changes","generic_data",changes_total,description="The total number of changes in the transaction")
