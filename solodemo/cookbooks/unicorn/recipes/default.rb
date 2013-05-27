gem_package "unicorn"
directory node[:unicorn][:config_path] do
  mode 0755
end

cookbook_file "/usr/local/bin/unicornctl" do
  mode 0755
end
