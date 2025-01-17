#!/usr/bin/env ruby
#
# Author:: Lance Albertson <lance@osuosl.org>
# Copyright:: Copyright 2019, Cinc Project
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This parses the Gemfile.lock file to find out which ref omnibus-software was
# locked at. Once found it will check out omnibus-software at that specific ref.
# This works in tandem with patches to ensure that we're using the same version
# that Chef was locked at.

require "bundler"
require "mixlib/shellout"

gemfile = File.read("Gemfile.lock")
sources = Bundler::LockfileParser.new(gemfile).sources
sources.each do |source|
  if source.to_s =~ /omnibus-software/
    origin = source.to_s.split(" ")[0]
    ref = source.to_s.gsub(/[()]/, "").split(" ")[2].split("@")[1]
    # puts "git clone --depth=1 -b #{ref} #{origin}"
    git_clone = Mixlib::ShellOut.new("git clone #{origin}", cwd: "../../")
    git_checkout = Mixlib::ShellOut.new("git checkout #{ref}", cwd: "../../omnibus-software/")
    git_clone.run_command
    git_clone.error!
    git_checkout.run_command
    git_checkout.error!
  end
end
