#!/usr/bin/env ruby

pathToDocuments = `xcrun simctl get_app_container booted com.adamtecle.tomatotimer data`.strip + '/Documents'
mostRecentlyUpdatedRealm = Dir.entries(pathToDocuments).filter { |f| f.end_with? ".realm" }.sort_by { |f| File.mtime("#{pathToDocuments}/#{f}") }.last
system(`open "#{pathToDocuments}/#{mostRecentlyUpdatedRealm}"`)
