Pod::Spec.new do |s|
  s.name     = 'ADBStateMachine'
  s.version  = '1.0.0'
  s.platform = :ios, '7.0'
  s.summary  = 'A proper thread-safe state machine for Objective-C.'
  s.homepage = 'https://github.com/albertodebortoli/ADBStateMachine'
  s.author   = { 'Alberto De Bortoli' => 'albertodebortoli.website@gmail.com' }
  s.source   = { :git => 'https://github.com/albertodebortoli/ADBStateMachine.git', :tag => s.version.to_s }
  s.license      = { :type => 'New BSD License', :file => 'LICENSE' }
  s.source_files = 'ADBStateMachine/Classes/*.{h,m}'
  s.requires_arc = true
end
