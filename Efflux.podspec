# coding: utf-8
Pod::Spec.new do |spec|
  spec.name          = "Efflux"
  spec.version       = "0.0.2"
  spec.summary       = "Flux implementation having redux-style state management and side effects"
  spec.homepage      = "https://github.com/kumabook/Efflux"
  spec.license       = "MIT"
  spec.author        = { "Hiroki Kumamoto" => "kumabook@live.jp" }
  spec.source        = { :git => "https://github.com/kumabook/Efflux.git", :tag => "#{spec.version}" }
  spec.swift_version = "5.0"
  spec.source_files  = "Sources/**/*.{swift,h,m}"

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.9"
  if spec.respond_to?(:watchos)
    spec.watchos.deployment_target = "2.0"
  end
  if spec.respond_to?(:tvos)
    spec.tvos.deployment_target = "9.0"
  end
end
