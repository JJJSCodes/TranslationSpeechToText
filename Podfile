# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TranslationSpeechToText' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TranslationSpeechToText
  pod 'GoogleMLKit/Translate', '4.0.0'
  pod 'GoogleMLKit/LanguageID', '4.0.0'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
         end
    end
  end
end
