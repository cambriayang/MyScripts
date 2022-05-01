#!/usr/bin/ruby

require 'json'
require 'xcodeproj'

@configs = JSON.parse(File.read "./Configs/compiling_configs.json")

def change_to_manual(project_name)
  project_path = `find . -type d -name '#{project_name}.xcodeproj'`.split("\n").first
  return if project_path == nil

  project = Xcodeproj::Project.open(project_path)
  project.root_object.attributes["TargetAttributes"].each do |uuid, settings|
    settings["ProvisioningStyle"] = "Manual"
    settings["DevelopmentTeam"] = ""
  end

  project.save
end

def change_build_settings(project_name, target_names)
  project_path = `find . -type d -name '#{project_name}.xcodeproj'`.split("\n").first
  return if project_path == nil

  project = Xcodeproj::Project.open(project_path)
  project.targets.select {|target| target_names.include? target.name}.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEVELOPMENT_TEAM'] = ''
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
      config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
    end
  end

  project.save
end

projects = @configs['common']['code_sign_projects']
targets = @configs['common']['code_sign_targets']

projects.each do |project|
  change_to_manual(project)
  change_build_settings(project, targets)
end
